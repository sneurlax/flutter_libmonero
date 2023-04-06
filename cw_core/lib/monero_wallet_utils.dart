import 'dart:io';

import 'package:cw_core/pathForWallet.dart';
import 'package:cw_core/wallet_type.dart';

String backupFileName(String originalPath) {
  final pathParts = originalPath.split('/');
  final newName = '#_${pathParts.last}';
  pathParts.removeLast();
  pathParts.add(newName);
  return pathParts.join('/');
}

Future<void> backupWalletFiles({
  required String name,
  required WalletType type,
}) async {
  final path = await pathForWallet(name: name, type: type);
  final cacheFile = File(path);
  final keysFile = File('$path.keys');
  final addressListFile = File('$path.address.txt');
  final newCacheFilePath = backupFileName(cacheFile.path);
  final newKeysFilePath = backupFileName(keysFile.path);
  final newAddressListFilePath = backupFileName(addressListFile.path);

  if (cacheFile.existsSync()) {
    await cacheFile.copy(newCacheFilePath);
  }

  if (keysFile.existsSync()) {
    await keysFile.copy(newKeysFilePath);
  }

  if (addressListFile.existsSync()) {
    await addressListFile.copy(newAddressListFilePath);
  }
}

Future<void> restoreWalletFiles({
  required String name,
  required WalletType type,
}) async {
  final walletDirPath = await pathForWalletDir(name: name, type: type);
  final cacheFilePath = '$walletDirPath/$name';
  final keysFilePath = '$walletDirPath/$name.keys';
  final addressListFilePath = '$walletDirPath/$name.address.txt';
  final backupCacheFile = File(backupFileName(cacheFilePath));
  final backupKeysFile = File(backupFileName(keysFilePath));
  final backupAddressListFile = File(backupFileName(addressListFilePath));

  if (backupCacheFile.existsSync()) {
    await backupCacheFile.copy(cacheFilePath);
  }

  if (backupKeysFile.existsSync()) {
    await backupKeysFile.copy(keysFilePath);
  }

  if (backupAddressListFile.existsSync()) {
    await backupAddressListFile.copy(addressListFilePath);
  }
}

Future<bool> backupWalletFilesExists({
  required String name,
  required WalletType type,
}) async {
  final walletDirPath = await pathForWalletDir(name: name, type: type);
  final cacheFilePath = '$walletDirPath/$name';
  final keysFilePath = '$walletDirPath/$name.keys';
  final addressListFilePath = '$walletDirPath/$name.address.txt';
  final backupCacheFile = File(backupFileName(cacheFilePath));
  final backupKeysFile = File(backupFileName(keysFilePath));
  final backupAddressListFile = File(backupFileName(addressListFilePath));

  return backupCacheFile.existsSync() &&
      backupKeysFile.existsSync() &&
      backupAddressListFile.existsSync();
}

Future<void> removeCache({
  required String name,
  required WalletType type,
}) async {
  final path = await pathForWallet(name: name, type: type);
  final cacheFile = File(path);

  if (cacheFile.existsSync()) {
    cacheFile.deleteSync();
  }
}

Future<void> restoreOrResetWalletFiles({
  required String name,
  required WalletType type,
}) async {
  final backupsExists = await backupWalletFilesExists(name: name, type: type);

  if (backupsExists) {
    await restoreWalletFiles(name: name, type: type);
  }

  await removeCache(name: name, type: type);
}
