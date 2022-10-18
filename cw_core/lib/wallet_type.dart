import 'package:cw_core/crypto_currency.dart';
import 'package:hive/hive.dart';

part 'wallet_type.g.dart';

const walletTypes = [
  WalletType.monero,
  WalletType.moneroTestNet,
  WalletType.moneroStageNet,
  WalletType.bitcoin,
  WalletType.litecoin,
  WalletType.haven,
  WalletType.wownero,
  WalletType.wowneroTestNet,
  WalletType.wowneroStageNet
];
const walletTypeTypeId = 5;

@HiveType(typeId: walletTypeTypeId)
enum WalletType {
  @HiveField(0)
  monero,

  @HiveField(1)
  none,

  @HiveField(2)
  bitcoin,

  @HiveField(3)
  litecoin,

  @HiveField(4)
  haven,

  @HiveField(5)
  wownero,

  @HiveField(6)
  moneroTestNet,

  @HiveField(7)
  moneroStageNet
}

int serializeToInt(WalletType? type) {
  switch (type) {
    case WalletType.monero:
      return 0;
    case WalletType.bitcoin:
      return 1;
    case WalletType.litecoin:
      return 2;
    case WalletType.haven:
      return 3;
    case WalletType.wownero:
      return 4;
    case WalletType.moneroTestNet:
      return 5;
    case WalletType.moneroStageNet:
      return 6;
    case WalletType.wowneroTestNet:
      return 7;
    case WalletType.wowneroStageNet:
      return 8;
    default:
      return -1;
  }
}

WalletType? deserializeFromInt(int? raw) {
  switch (raw) {
    case 0:
      return WalletType.monero;
    case 1:
      return WalletType.bitcoin;
    case 2:
      return WalletType.litecoin;
    case 3:
      return WalletType.haven;
    case 4:
      return WalletType.wownero;
    case 5:
      return WalletType.moneroTestNet;
    case 6:
      return WalletType.moneroStageNet;
    default:
      return null;
  }
}

String walletTypeToString(WalletType type) {
  switch (type) {
    case WalletType.monero:
      return 'Monero';
    case WalletType.moneroTestNet:
      return 'Monero Testnet';
    case WalletType.moneroStageNet:
      return 'Monero Stagenet';
    case WalletType.bitcoin:
      return 'Bitcoin';
    case WalletType.litecoin:
      return 'Litecoin';
    case WalletType.haven:
      return 'Haven';
    case WalletType.wownero:
      return 'Wownero';
    case WalletType.wowneroTestNet:
      return 'Wownero Testnet';
    case WalletType.wowneroStageNet:
      return 'Wownero Stagenet';
    default:
      return '';
  }
}

String walletTypeToDisplayName(WalletType type) {
  switch (type) {
    case WalletType.monero:
      return 'Monero';
    case WalletType.moneroTestNet:
      return 'Monero Testnet';
    case WalletType.moneroStageNet:
      return 'Monero Stagenet';
    case WalletType.bitcoin:
      return 'Bitcoin (Electrum)';
    case WalletType.litecoin:
      return 'Litecoin (Electrum)';
    case WalletType.haven:
      return 'Haven';
    case WalletType.wownero:
      return 'Wownero';
    case WalletType.wowneroTestNet:
      return 'Wownero Testnet';
    case WalletType.wowneroStageNet:
      return 'Wownero Stagenet';
    default:
      return '';
  }
}

CryptoCurrency? walletTypeToCryptoCurrency(WalletType type) {
  switch (type) {
    case WalletType.monero:
      return CryptoCurrency.xmr;
    case WalletType.moneroTestNet:
      return CryptoCurrency.txmr;
    case WalletType.moneroStageNet:
      return CryptoCurrency.sxmr;
    case WalletType.bitcoin:
      return CryptoCurrency.btc;
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
