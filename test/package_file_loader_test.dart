import 'package:build/build.dart';
import 'package:package_file_loader/package_file_loader.dart';
import 'package:test/test.dart';

void main() {
  group('Load package exports', () {
    test('Should be able to load test.dart from package test', () async {
      final testFile = await loadPackageFile('package:test/test.dart');
      expect(testFile.existsSync(), equals(true));
    });
  });

  group('Extract package from absolute paths obtained from .package or .package_config.json', () {
    test("Should extract 'recase' & 'meta' from pub dependency", () async {
      final recase =
          "file:///Users/oliatienza/Development/flutter/.pub-cache/hosted/pub.dartlang.org/recase-4.0.0";
      final meta =
          "file:///Users/oliatienza/Development/flutter/.pub-cache/hosted/pub.dartlang.org/meta-1.7.0";

      expect(packageFromAbsolutePath(recase), equals('recase'));
      expect(packageFromAbsolutePath(meta), equals('meta'));
    });

    test("Should extract 'package_file_loader' & 'schema' from pub dependency", () async {
      final pfl =
          "file:///Users/oliatienza/Development/flutter/.pub-cache/git/package_file_loader-03bac97afb13e82b2f6d72256969a71e47f7cb30/";
      final schema =
          "file:///Users/oliatienza/Development/flutter/.pub-cache/git/schema-123lkfasdlkj2asd2klqwdal230asdlkj2e/";

      expect(packageFromAbsolutePath(pfl), equals('package_file_loader'));
      expect(packageFromAbsolutePath(schema), equals('schema'));
    });

    test("Should throw an exception if the format provided is invalid", () async {
      final invalid = "../../this/should/not/work";

      expect(() => packageFromAbsolutePath(invalid), throwsA(isA<PackageNotFoundException>()));
    });
  });

  group('Should convert absolute imports to package imports', () {
    test("Should extract 'recase' from pub dependency", () async {
      final bs =
          "file:///Users/oliatienza/Development/flutter/.pub-cache/hosted/pub.dartlang.org/boolean_selector-2.1.1/boolean_selector.dart";

      expect(await packageImportFromAbsolutePath(bs),
          equals('package:boolean_selector/boolean_selector.dart'));
    });
  });
}
