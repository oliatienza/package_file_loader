import 'dart:io';

import 'package:build/build.dart';
import 'package:collection/collection.dart';

final packageRegex = RegExp(r'^package:(\w+)\/(.*)$');

class _LoadedFile {
  _LoadedFile({
    required this.file,
    required this.packageName,
    required this.path,
  });

  final File file;
  final String packageName;
  final String path;
}

class LoadedFileAsset {
  LoadedFileAsset({
    required this.assetId,
    required this.file,
  });

  final AssetId assetId;
  final File file;
}

Future<File> loadPackageFile(String path) async => (await _loadPackageFile(path)).file;

Future<LoadedFileAsset> loadPackageFileAsAsset(String path) async {
  final info = await _loadPackageFile(path);
  return LoadedFileAsset(assetId: AssetId(info.packageName, info.path), file: info.file);
}

Future<_LoadedFile> _loadPackageFile(String path) async {
  final match = packageRegex.firstMatch(path);
  if (match == null) {
    throw FormatException(
        "Invalid format for package reference. Expected format r'^package:(\\w+)/(.*)\$'");
  }

  final packageName = match.group(1);
  if (packageName == null) {
    throw FormatException('Could not extract package name from path');
  }
  final filePath = match.group(2);
  if (filePath == null) {
    throw FormatException('Could not extract file location from path');
  }

  final p = '$packageName:';
  final file = File('${Directory.current.path}/.packages');
  if (!file.existsSync()) {
    throw FileSystemException('Packages index not found. Run flutter pub get first');
  }
  final lines = await file.readAsLines();
  final line = lines.firstWhere((e) => e.startsWith(p),
      orElse: () => throw PackageNotFoundException(
          '$packageName, make sure that the dependency is added to pubspec and run flutter pub get'));
  final packagePath = line.replaceFirst(p, '').replaceFirst('file://', '');

  return _LoadedFile(
    packageName: packageName,
    path: filePath,
    file: File.fromUri(
      Uri(scheme: 'file', path: '$packagePath$filePath'),
    ),
  );
}
