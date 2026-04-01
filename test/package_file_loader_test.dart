import 'package:build/build.dart';
import 'package:package_file_loader/package_file_loader.dart';
import 'package:test/test.dart';

void main() {
  group('loadPackageFile', () {
    test('loads an existing package file asynchronously', () async {
      final file = await loadPackageFile('package:test/test.dart');
      expect(file.existsSync(), isTrue);
    });

    test('loads an existing package file synchronously', () {
      final file = loadPackageFileSync('package:test/test.dart');
      expect(file.existsSync(), isTrue);
    });

    test('resolves a nested file path within a package', () async {
      final file = await loadPackageFile('package:test/src/runner/executable_settings.dart');
      // Verify it resolves to a path under the package's lib/ directory
      expect(file.path, contains('test-'));
      expect(file.path, contains('lib/src/runner/executable_settings.dart'));
    });

    test('throws FormatException for invalid package URI format', () async {
      expect(
        () => loadPackageFileSync('not_a_package_uri'),
        throwsFormatException,
      );
    });

    test('throws FormatException for missing package prefix', () async {
      expect(
        () => loadPackageFileSync('test/test.dart'),
        throwsFormatException,
      );
    });

    test('throws PackageNotFoundException for unknown package', () async {
      expect(
        () => loadPackageFileSync('package:nonexistent_pkg_xyz/foo.dart'),
        throwsA(isA<PackageNotFoundException>()),
      );
    });
  });

  group('loadPackageFileAsAsset', () {
    test('returns a LoadedFileAsset with correct AssetId', () async {
      final asset = await loadPackageFileAsAsset('package:test/test.dart');
      expect(asset.assetId, equals(AssetId('test', 'test.dart')));
      expect(asset.file.existsSync(), isTrue);
    });

    test('returns correct AssetId for nested paths', () async {
      final asset = await loadPackageFileAsAsset('package:test/src/runner/executable_settings.dart');
      expect(asset.assetId, equals(AssetId('test', 'src/runner/executable_settings.dart')));
      expect(asset.file.path, contains('lib/src/runner/executable_settings.dart'));
    });
  });

  group('packageFromAbsolutePath', () {
    test('extracts package name from pub.dev hosted dependency', () {
      final paths = [
        'file:///Users/user/.pub-cache/hosted/pub.dev/meta-1.18.2',
        'file:///Users/user/.pub-cache/hosted/pub.dev/async-2.13.1',
        'file:///Users/user/.pub-cache/hosted/pub.dev/boolean_selector-2.1.2',
      ];

      expect(packageFromAbsolutePath(paths[0]), equals('meta'));
      expect(packageFromAbsolutePath(paths[1]), equals('async'));
      expect(packageFromAbsolutePath(paths[2]), equals('boolean_selector'));
    });

    test('extracts package name from legacy pub.dartlang.org hosted dependency', () {
      final recase =
          'file:///Users/user/.pub-cache/hosted/pub.dartlang.org/recase-4.0.0';
      final meta =
          'file:///Users/user/.pub-cache/hosted/pub.dartlang.org/meta-1.7.0';

      expect(packageFromAbsolutePath(recase), equals('recase'));
      expect(packageFromAbsolutePath(meta), equals('meta'));
    });

    test('extracts package name from git dependency', () {
      final pfl =
          'file:///Users/user/.pub-cache/git/package_file_loader-03bac97afb13e82b2f6d72256969a71e47f7cb30/';
      final schema =
          'file:///Users/user/.pub-cache/git/schema-123lkfasdlkj2asd2klqwdal230asdlkj2e/';

      expect(packageFromAbsolutePath(pfl), equals('package_file_loader'));
      expect(packageFromAbsolutePath(schema), equals('schema'));
    });

    test('throws PackageNotFoundException for invalid paths', () {
      expect(
        () => packageFromAbsolutePath('../../this/should/not/work'),
        throwsA(isA<PackageNotFoundException>()),
      );
    });

    test('throws PackageNotFoundException for empty string', () {
      expect(
        () => packageFromAbsolutePath(''),
        throwsA(isA<PackageNotFoundException>()),
      );
    });
  });

  group('packageImportFromAbsolutePath', () {
    test('converts pub.dev absolute path to package import', () async {
      // Load a real file to get its actual absolute path, then convert back
      final testFile = await loadPackageFile('package:test/test.dart');
      final absolutePath = 'file://${testFile.path}';

      final result = await packageImportFromAbsolutePath(absolutePath);
      expect(result, equals('package:test/test.dart'));
    });
  });
}
