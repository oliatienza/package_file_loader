import 'package:package_file_loader/package_file_loader.dart';

Future<void> main() async {
  final file = await loadPackageFile('package:package_file_loader/package_file_loader');
  print(file.existsSync());
}
