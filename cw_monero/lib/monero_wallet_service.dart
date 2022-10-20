import 'dart:io';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:cw_core/wallet_base.dart';
import 'package:cw_core/monero_wallet_utils.dart';
import 'package:hive/hive.dart';
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
  MoneroNewWalletCredentials(
      {String? name, String? password, this.language, int? nettype})
      : super(name: name, password: password);

  final String? language;
}

class MoneroRestoreWalletFromSeedCredentials extends WalletCredentials {
  MoneroRestoreWalletFromSeedCredentials(
      {String? name,
      String? password,
      int? nettype,
      int? height,
      this.mnemonic})
      : super(name: name, password: password, height: height, nettype: nettype);

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
      int? nettype,
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
  WalletType getType() => WalletType.monero;

  @override
  int getNettype() => 0;

  @override
  WalletType getWalletType(int nettype) {
    if (nettype == 0) {
      return WalletType.monero;
    } else if (nettype == 1) {
      return WalletType.moneroTestNet;
    } else {
      return WalletType.moneroStageNet;
    }
  }

  @override
  Future<MoneroWallet> create(MoneroNewWalletCredentials credentials) async {
    try {
      final path = await pathForWallet(
          name: credentials.name!,
          type: getWalletType(credentials.nettype ?? 0));
      await monero_wallet_manager.createWallet(
          path: path,
          password: credentials.password,
          language: credentials.language,
          nettype: credentials.nettype);
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
  Future<bool> isWalletExit(String name, [int nettype = 0]) async {
    try {
      final path =
          await pathForWallet(name: name, type: getWalletType(nettype));
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
      final path =
          await pathForWallet(name: name, type: getWalletType(nettype));

      if (walletFilesExist(path)) {
        await repairOldAndroidWallet(name, nettype);
      }

      await monero_wallet_manager.openWalletAsync(
          {'path': path, 'password': password, 'nettype': nettype});
      final walletInfo = walletInfoSource.values.firstWhereOrNull(
          (info) => info.id == WalletBase.idFor(name, getType()))!;
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
  Future<void> remove(String wallet, [int nettype = 0]) async {
    final path =
        await pathForWalletDir(name: wallet, type: getWalletType(nettype));
    final file = Directory(path);
    final isExist = file.existsSync();

    if (isExist) {
      await file.delete(recursive: true);
    }
  }

  @override
  Future<MoneroWallet> restoreFromKeys(
      MoneroRestoreWalletFromKeysCredentials credentials) async {
    try {
      final path = await pathForWallet(
          name: credentials.name!,
          type: getWalletType(credentials.nettype ?? 0));
      await monero_wallet_manager.restoreFromKeys(
          path: path,
          password: credentials.password,
          language: credentials.language,
          restoreHeight: credentials.height,
          address: credentials.address,
          viewKey: credentials.viewKey,
          spendKey: credentials.spendKey,
          nettype: credentials.nettype);
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
      MoneroRestoreWalletFromSeedCredentials credentials) async {
    try {
      final path = await pathForWallet(
          name: credentials.name!,
          type: getWalletType(credentials.nettype ?? 0));
      await monero_wallet_manager.restoreFromSeed(
          path: path,
          password: credentials.password,
          seed: credentials.mnemonic,
          restoreHeight: credentials.height,
          nettype: credentials.nettype);
      final wallet = MoneroWallet(walletInfo: credentials.walletInfo!);
      await wallet.init();

      return wallet;
    } catch (e) {
      // TODO: Implement Exception for wallet list service.
      print('MoneroWalletsManager Error: $e');
      rethrow;
    }
  }

  Future<void> repairOldAndroidWallet(String name, int nettype) async {
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
          await pathForWalletDir(name: name, type: getWalletType(nettype));

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
