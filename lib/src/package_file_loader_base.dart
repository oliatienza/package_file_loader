import 'dart:convert';
import 'dart:io';

import 'package:build/build.dart';

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

  final packagesIndex = _loadPackagesIndex();
  final p = '$packageName:';
  final lines = await packagesIndex.readAsLines();
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

Future<PackageConfig> _loadPackageConfig() async {
  final file = _loadPackageConfigFile();
  return PackageConfig.fromJson(jsonDecode(await file.readAsString()));
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
