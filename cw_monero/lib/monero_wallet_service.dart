import 'dart:io';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:cw_core/wallet_base.dart';
import 'package:cw_core/monero_wallet_utils.dart';
import 'package:hive/hive.dart';
import 'package:stackwallet/hive/db.dart';
import 'package:cw_monero/api/wallet_manager.dart' as monero_wallet_manager;
import 'package:cw_monero/api/wallet.dart' as monero_wallet;
import 'package:cw_monero/api/exceptions/wallet_opening_exception.dart';
import 'package:cw_monero/monero_wallet.dart';
import 'package:cw_core/wallet_credentials.dart';
import 'package:cw_core/wallet_service.dart';
import 'package:cw_core/pathForWallet.dart';
import 'package:cw_core/wallet_info.dart';
import 'package:cw_core/wallet_type.dart';

class MoneroNewWalletCredentials extends WalletCredentials {
  MoneroNewWalletCredentials({String? name, String? password, this.language})
      : super(name: name, password: password);

  final String? language;
}

class MoneroRestoreWalletFromSeedCredentials extends WalletCredentials {
  MoneroRestoreWalletFromSeedCredentials(
      {String? name, String? password, int? height, this.mnemonic})
      : super(name: name, password: password, height: height);

  final String? mnemonic;
}

class MoneroWalletLoadingException implements Exception {
  @override
  String toString() => 'Failure to load the wallet.';
}

class MoneroRestoreWalletFromKeysCredentials extends WalletCredentials {
  MoneroRestoreWalletFromKeysCredentials(
      {String? name,
      String? password,
      this.language,
      this.address,
      this.viewKey,
      this.spendKey,
      int? height})
      : super(name: name, password: password, height: height);

  final String? language;
  final String? address;
  final String? viewKey;
  final String? spendKey;
}

class MoneroWalletService extends WalletService<
    MoneroNewWalletCredentials,
    MoneroRestoreWalletFromSeedCredentials,
    MoneroRestoreWalletFromKeysCredentials> {
  MoneroWalletService(this.walletInfoSource);

  final Box<WalletInfo> walletInfoSource;
  
  static bool walletFilesExist(String path) =>
      !File(path).existsSync() && !File('$path.keys').existsSync();

  @override
  WalletType getType([int nettype = 0]) {
    if (nettype == 1) {
      return WalletType.moneroTestNet;
    } else if (nettype == 2) {
      return WalletType.moneroStageNet;
    } else {
      return WalletType.monero;
    }
  }

  @override
  Future<MoneroWallet> create(MoneroNewWalletCredentials credentials,
      {int nettype = 0}) async {
    if (credentials.walletInfo?.type == WalletType.moneroTestNet) {
      nettype = 1;
    } else if (credentials.walletInfo?.type == WalletType.moneroStageNet) {
      nettype = 2;
    }

    try {
      final path =
          await pathForWallet(name: credentials.name!, type: getType(nettype));
      await monero_wallet_manager.createWallet(
          path: path,
          password: credentials.password,
          language: credentials.language,
          nettype: nettype);
      final wallet = MoneroWallet(walletInfo: credentials.walletInfo!);
      await wallet.init();

      return wallet;
    } catch (e) {
      // TODO: Implement Exception for wallet list service.
      print('MoneroWalletsManager Error: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<bool> isWalletExit(String name) async {
    try {
      final path = await pathForWallet(name: name, type: getType());
      return monero_wallet_manager.isWalletExist(path: path);
    } catch (e) {
      // TODO: Implement Exception for wallet list service.
      print('MoneroWalletsManager Error: $e');
      rethrow;
    }
  }

  @override
  Future<MoneroWallet> openWallet(String name, String password,
      [int nettype = 0]) async {
    try {
      final path = await pathForWallet(
          name: name,
      // Find coin name for nettype (monero, moneroStageNet, moneroTestNet, etc) by calling the database for all wallet names and use the name param to find the coin ... Not a good solution, hacky, need to find better way to find the coin/nettype here
      final _names = DB.instance.get<dynamic>(
          boxName: DB.boxNameAllWalletsData, key: 'names') as Map?;

      Map<String, dynamic> names;
      if (_names == null) {
        names = {};
      } else {
        names = Map<String, dynamic>.from(_names);
      }

      var type = WalletType.monero;

      if (names[name]['coin'] == 'moneroStageNet') {
        nettype = 2;
        type = WalletType.moneroStageNet;
      } else if (names[name]['coin'] == 'moneroTestNet') {
        nettype = 1;
        type = WalletType.moneroTestNet;
      }

      final path = await pathForWallet(name: name, type: type);

      if (walletFilesExist(path)) {
        await repairOldAndroidWallet(name);
      }

      await monero_wallet_manager.openWalletAsync(
          {'path': path, 'password': password, 'nettype': nettype});
      final walletInfo = walletInfoSource.values
          .firstWhereOrNull((info) => info.id == WalletBase.idFor(name, type))!;
      final wallet = MoneroWallet(walletInfo: walletInfo);
      final isValid = wallet.walletAddresses.validate();

      if (!isValid) {
        await restoreOrResetWalletFiles(name);
        wallet.close();
        return openWallet(name, password, nettype);
      }

      await wallet.init();

      return wallet;
    } catch (e) {
      // TODO: Implement Exception for wallet list service.

      if ((e.toString().contains('bad_alloc') ||
          (e is WalletOpeningException &&
              (e.message == 'std::bad_alloc' ||
                  e.message!.contains('bad_alloc')))) ||
          (e.toString().contains('does not correspond') ||
          (e is WalletOpeningException &&
            e.message!.contains('does not correspond')))) {
        await restoreOrResetWalletFiles(name);
        return openWallet(name, password, nettype);
      }

      rethrow;
    }
  }

  @override
  Future<void> remove(String wallet) async {
    final path = await pathForWalletDir(name: wallet, type: getType());
    final file = Directory(path);
    final isExist = file.existsSync();

    if (isExist) {
      await file.delete(recursive: true);
    }
  }

  @override
  Future<MoneroWallet> restoreFromKeys(
      MoneroRestoreWalletFromKeysCredentials credentials,
      {int nettype = 0}) async {
    try {
      final path =
          await pathForWallet(name: credentials.name!, type: getType(nettype));
      await monero_wallet_manager.restoreFromKeys(
          path: path,
          password: credentials.password,
          language: credentials.language,
          restoreHeight: credentials.height,
          address: credentials.address,
          viewKey: credentials.viewKey,
          spendKey: credentials.spendKey,
          nettype: nettype);
      final wallet = MoneroWallet(walletInfo: credentials.walletInfo!);
      await wallet.init();

      return wallet;
    } catch (e) {
      // TODO: Implement Exception for wallet list service.
      print('MoneroWalletsManager Error: $e');
      rethrow;
    }
  }

  @override
  Future<MoneroWallet> restoreFromSeed(
      MoneroRestoreWalletFromSeedCredentials credentials,
      {int nettype = 0}) async {
    try {
      final path =
          await pathForWallet(name: credentials.name!, type: getType(nettype));
      await monero_wallet_manager.restoreFromSeed(
          path: path,
          password: credentials.password,
          seed: credentials.mnemonic,
          restoreHeight: credentials.height,
          nettype: nettype);
      final wallet = MoneroWallet(walletInfo: credentials.walletInfo!);
      await wallet.init();

      return wallet;
    } catch (e) {
      // TODO: Implement Exception for wallet list service.
      print('MoneroWalletsManager Error: $e');
      rethrow;
    }
  }

  Future<void> repairOldAndroidWallet(String name) async {
    try {
      if (!Platform.isAndroid) {
        return;
      }

      final oldAndroidWalletDirPath =
          await outdatedAndroidPathForWalletDir(name: name);
      final dir = Directory(oldAndroidWalletDirPath);

      if (!dir.existsSync()) {
        return;
      }

      final newWalletDirPath =
          await pathForWalletDir(name: name, type: getType());

      dir.listSync().forEach((f) {
        final file = File(f.path);
        final name = f.path.split('/').last;
        final newPath = newWalletDirPath + '/$name';
        final newFile = File(newPath);

        if (!newFile.existsSync()) {
          newFile.createSync();
        }
        newFile.writeAsBytesSync(file.readAsBytesSync());
      });
    } catch (e) {
      print(e.toString());
    }
  }
}
