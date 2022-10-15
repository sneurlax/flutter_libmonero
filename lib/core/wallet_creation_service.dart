// import 'package:flutter_libmonero/di.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_libmonero/core/key_service.dart';
import 'package:cw_core/wallet_base.dart';
import 'package:cw_core/wallet_credentials.dart';
import 'package:cw_core/wallet_service.dart';
import 'package:cw_core/wallet_type.dart';
import 'package:stack_wallet_backup/generate_password.dart';

class WalletCreationService {
  WalletService? walletService;
  WalletCreationService(
      {this.secureStorage,
      this.keyService,
      this.sharedPreferences,
      this.walletService}) {
    if (type != null) {
      changeWalletType();
    }
  }

  WalletType type = WalletType.monero;
  final dynamic? secureStorage;
  final SharedPreferences? sharedPreferences;
  final KeyService? keyService;
  WalletService? _service;

  void changeWalletType([int nettype = 0]) {
    this.type = WalletType.monero;
    if (nettype == 0) {
      this.type = WalletType.monero;
    } else if (nettype == 1) {
      this.type = WalletType.moneroTestNet;
    } else if (nettype == 2) {
      this.type = WalletType.moneroStageNet;
    }
    _service = walletService;
  }

  Future<WalletBase> create(WalletCredentials credentials,
      [int? nettype = 0]) async {
    final password = generatePassword();
    credentials.password = password;
    if (nettype != credentials.nettype && credentials.nettype != null) {
      nettype = credentials.nettype;
    }
    if (nettype != credentials.walletInfo?.nettype &&
        credentials.walletInfo?.nettype != null) {
      nettype = credentials.walletInfo?.nettype;
    }
    await keyService!
        .saveWalletPassword(password: password, walletName: credentials.name);
    return await _service!.create(credentials, nettype ?? 0);
  }

  Future<WalletBase> restoreFromKeys(WalletCredentials credentials,
      [int? nettype = 0]) async {
    final password = generatePassword();
    credentials.password = password;
    if (nettype != credentials.nettype && credentials.nettype != null) {
      nettype = credentials.nettype;
    }
    if (nettype != credentials.walletInfo?.nettype &&
        credentials.walletInfo?.nettype != null) {
      nettype = credentials.walletInfo?.nettype;
    }
    await keyService!
        .saveWalletPassword(password: password, walletName: credentials.name);
    return await _service!.restoreFromKeys(credentials, nettype ?? 0);
  }

  Future<WalletBase> restoreFromSeed(WalletCredentials credentials,
      [int? nettype = 0]) async {
    final password = generatePassword();
    credentials.password = password;
    if (nettype != credentials.nettype && credentials.nettype != null) {
      nettype = credentials.nettype;
    }
    if (nettype != credentials.walletInfo?.nettype &&
        credentials.walletInfo?.nettype != null) {
      nettype = credentials.walletInfo?.nettype;
    }
    await keyService!
        .saveWalletPassword(password: password, walletName: credentials.name);
    return await _service!.restoreFromSeed(credentials, nettype ?? 0);
  }
}
