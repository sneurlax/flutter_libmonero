import 'package:cw_core/wallet_base.dart';
import 'package:cw_core/wallet_credentials.dart';
import 'package:cw_core/wallet_type.dart';

abstract class WalletService<N extends WalletCredentials,
    RFS extends WalletCredentials, RFK extends WalletCredentials> {
  WalletType getType();

  Future<WalletBase> create(N credentials, [int nettype = 0]);

  Future<WalletBase> restoreFromSeed(RFS credentials, [int nettype = 0]);

  Future<WalletBase> restoreFromKeys(RFK credentials, [int nettype = 0]);

  Future<WalletBase> openWallet(String name, String password,
      [int nettype = 0]);

  Future<bool> isWalletExit(String name, [int nettype = 0]);

  Future<void> remove(String wallet, [int nettype = 0]);
}
