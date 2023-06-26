import 'dart:convert';
import 'dart:io';

import 'package:build/build.dart';
import 'package:path/path.dart' as path;

import 'package_config/package_config.dart';

final packageRegex = RegExp(r'^package:(\w+)\/(.*)$');
final pubDependencyAbsolutePathRegex =
    RegExp(r'^\S*pub-cache\/hosted\/pub.dartlang.org\/(\w+)\S*$');
final gitDependencyAbsolutePathRegex = RegExp(r'^\S*pub-cache\/git\/(\w+)\S*$');

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

Future<File> loadPackageFile(String path) async =>
    (_loadPackageFile(path, await _loadPackageConfig())).file;
File loadPackageFileSync(String path) => (_loadPackageFile(path, _loadPackageConfigSync())).file;

Future<LoadedFileAsset> loadPackageFileAsAsset(String path) async {
  final info = _loadPackageFile(path, await _loadPackageConfig());
  return LoadedFileAsset(assetId: AssetId(info.packageName, info.path), file: info.file);
}

Future<LoadedFileAsset> loadPackageFileAsAssetSync(String path) async {
  final info = _loadPackageFile(path, _loadPackageConfigSync());
  return LoadedFileAsset(assetId: AssetId(info.packageName, info.path), file: info.file);
}

_LoadedFile _loadPackageFile(String path, PackageConfig packageConfig) {
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
  final package = packageConfig.packages.firstWhere((e) => e.name == packageName,
      orElse: () => throw PackageNotFoundException(
          '$packageName, make sure that the dependency is added to pubspec and run flutter pub get'));

  final packagePath = _getPackagePath(p, package);

  return _LoadedFile(
    packageName: packageName,
    path: filePath,
    file: File.fromUri(
      Uri(scheme: 'file', path: '$packagePath$filePath'),
    ),
  );
}

Future<String> packageImportFromAbsolutePath(String absolutePath) async {
  final packageName = packageFromAbsolutePath(absolutePath);

  final packages = (await _loadPackageConfig()).packages;
  final p = packages.firstWhere((element) => element.name == packageName);

  return absolutePath.replaceFirst(p.rootUri, 'package:$packageName');
}

String packageFromAbsolutePath(String absolutePath) {
  final regex = [pubDependencyAbsolutePathRegex, gitDependencyAbsolutePathRegex];
  for (final r in regex) {
    var match = r.firstMatch(absolutePath);
    var group = match?.group(1);
    if (group != null) {
      return group;
    }
  }

  throw PackageNotFoundException('Could not extract package from input path');
}

String _getPackagePath(String p, Package package) {
  String rootUri = package.rootUri.replaceFirst(p, '');

  if (package.rootUri.contains('file://')) {
    rootUri = package.rootUri.replaceFirst('file://', '');
  } else {
    // The config file always prepend `../` to the root uri
    final relative = package.rootUri.replaceFirst('../', '');
    rootUri = path.normalize(path.absolute(relative));
  }

  return '$rootUri/${package.packageUri}';
}

Future<PackageConfig> _loadPackageConfig() async {
  final file = _loadPackageConfigFile();
  return PackageConfig.fromJson(jsonDecode(await file.readAsString()));
}

PackageConfig _loadPackageConfigSync() {
  final file = _loadPackageConfigFile();
  return PackageConfig.fromJson(jsonDecode(file.readAsStringSync()));
}

File _loadPackageConfigFile() {
  final file = File('${Directory.current.path}/.dart_tool/package_config.json');
  if (!file.existsSync()) {
    throw FileSystemException('package_config.json not found. Run flutter pub get first');
  }

  return file;
}

File _loadPackagesIndex() {
  final file = File('${Directory.current.path}/.packages');
  if (!file.existsSync()) {
    throw FileSystemException('.packages index not found. Run flutter pub get first');
  }

  return file;
}
