import 'package:package_file_loader/package_file_loader.dart';
import 'package:test/test.dart';

void main() {
  group('Load package exports', () {
    test('Should be able to load test.dart from package test', () async {
      final testFile = await loadPackageFile('package:test/test.dart');
      expect(testFile.existsSync(), true);
    });
  });
}
