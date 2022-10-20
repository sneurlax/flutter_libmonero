import 'package:cw_core/wallet_info.dart';

abstract class WalletCredentials {
  WalletCredentials(
      {this.name, this.password, this.height, this.nettype, this.walletInfo});

  final String? name;
  final int? height;
  final int? nettype;
  String? password;
  WalletInfo? walletInfo;
}
