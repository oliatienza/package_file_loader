// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageConfig _$PackageConfigFromJson(Map<String, dynamic> json) =>
    PackageConfig(
      configVersion: (json['configVersion'] as num).toInt(),
      packages: (json['packages'] as List<dynamic>)
          .map((e) => Package.fromJson(e as Map<String, dynamic>))
          .toList(),
      generated: json['generated'] == null
          ? null
          : DateTime.parse(json['generated'] as String),
      generator: json['generator'] as String,
      generatorVersion: json['generatorVersion'] as String,
    );

Map<String, dynamic> _$PackageConfigToJson(PackageConfig instance) =>
    <String, dynamic>{
      'configVersion': instance.configVersion,
      'packages': instance.packages,
      'generated': instance.generated?.toIso8601String(),
      'generator': instance.generator,
      'generatorVersion': instance.generatorVersion,
    };

Package _$PackageFromJson(Map<String, dynamic> json) => Package(
      name: json['name'] as String,
      rootUri: json['rootUri'] as String,
      packageUri: json['packageUri'] as String,
      languageVersion: json['languageVersion'] as String,
    );

Map<String, dynamic> _$PackageToJson(Package instance) => <String, dynamic>{
      'name': instance.name,
      'rootUri': instance.rootUri,
      'packageUri': instance.packageUri,
      'languageVersion': instance.languageVersion,
    };
