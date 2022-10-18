import 'package:cw_core/crypto_currency.dart';
import 'package:cw_core/wallet_type.dart';

CryptoCurrency? currencyForWalletType(WalletType? type) {
  switch (type) {
    case WalletType.bitcoin:
      return CryptoCurrency.btc;
    case WalletType.monero:
      return CryptoCurrency.xmr;
    case WalletType.moneroTestNet:
      return CryptoCurrency.txmr;
    case WalletType.moneroStageNet:
      return CryptoCurrency.sxmr;
    case WalletType.litecoin:
      return CryptoCurrency.ltc;
    case WalletType.haven:
      return CryptoCurrency.xhv;
    case WalletType.wownero:
      return CryptoCurrency.wow;
    case WalletType.wowneroTestNet:
      return CryptoCurrency.twow;
    case WalletType.wowneroStageNet:
      return CryptoCurrency.swow;
    default:
      return null;
  }
}
