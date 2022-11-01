import 'dart:io';

/// packages:test/load_this_file.dart
Future<File> loadPackageFile(String path) async {
  final packageRegex = RegExp(r'^package:(\w+)\/(.*)');
  final match = packageRegex.firstMatch(path);
  if (match == null) {
    throw Error();
  }
  final packageName = match.group(1);
  final filePath = match.group(2);

  final p = '$packageName:';
  final file = File('${Directory.current.path}/.packages');
  final lines = await file.readAsLines();
  final line = lines.firstWhere((e) => e.startsWith(p));
  final packagePath = line.replaceFirst(p, '').replaceFirst('file://', '');

  return File.fromUri(Uri(scheme: 'file', path: '$packagePath$filePath'));
}
