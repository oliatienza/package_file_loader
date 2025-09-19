import 'package:json_annotation/json_annotation.dart';
part 'package_config.g.dart';

@JsonSerializable()
class PackageConfig {
  const PackageConfig({
    required this.configVersion,
    required this.packages,
    required this.generated,
    required this.generator,
    required this.generatorVersion,
  });

  final int? configVersion;
  final List<Package> packages;
  final DateTime? generated;
  final String? generator;
  final String? generatorVersion;

  factory PackageConfig.fromJson(Map<String, dynamic> json) => _$PackageConfigFromJson(json);
  Map<String, dynamic> toJson() => _$PackageConfigToJson(this);
}

@JsonSerializable()
class Package {
  const Package({
    required this.name,
    required this.rootUri,
    required this.packageUri,
    required this.languageVersion,
  });

  final String name;
  final String rootUri;
  final String packageUri;
  final String languageVersion;

  factory Package.fromJson(Map<String, dynamic> json) => _$PackageFromJson(json);
  Map<String, dynamic> toJson() => _$PackageToJson(this);
}
