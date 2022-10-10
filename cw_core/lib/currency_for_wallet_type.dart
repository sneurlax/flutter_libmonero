import 'package:cw_core/crypto_currency.dart';
import 'package:cw_core/wallet_type.dart';

CryptoCurrency? currencyForWalletType(WalletType? type) {
  switch (type) {
    case WalletType.bitcoin:
      return CryptoCurrency.btc;
    case WalletType.monero:
      return CryptoCurrency.xmr;
    case WalletType.litecoin:
      return CryptoCurrency.ltc;
    case WalletType.haven:
      return CryptoCurrency.xhv;
    case WalletType.wownero:
      return CryptoCurrency.wow;
    case WalletType.moneroStageNet:
      return CryptoCurrency.sxmr;
    case WalletType.moneroTestNet:
      return CryptoCurrency.txmr;
    default:
      return null;
  }
}
