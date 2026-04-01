# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A Dart utility package for loading files from Dart/Flutter package dependencies at runtime using `package:` URIs. It reads `.dart_tool/package_config.json` to resolve package paths.

## Commands

```bash
# Get dependencies
dart pub get

# Run tests
dart test

# Run a single test
dart test test/package_file_loader_test.dart

# Regenerate json_serializable code
dart run build_runner build

# Analyze
dart analyze
```

## Architecture

The package has two layers:

1. **PackageConfig model** (`lib/src/package_config/package_config.dart`) — JSON-serializable model for `.dart_tool/package_config.json`. Uses `json_serializable` for codegen (`.g.dart` file). After modifying the model, regenerate with `build_runner`.

2. **Core API** (`lib/src/package_file_loader_base.dart`) — Public functions that resolve `package:` URIs to `File` objects by parsing the package config:
   - `loadPackageFile` / `loadPackageFileSync` — returns a `File` from a package URI
   - `loadPackageFileAsAsset` / `loadPackageFileAsAssetSync` — returns a `LoadedFileAsset` (wraps `AssetId` from `package:build`)
   - `packageFromAbsolutePath` — extracts package name from an absolute pub-cache path
   - `packageImportFromAbsolutePath` — converts absolute path back to a `package:` import

Everything is exported via the barrel file `lib/package_file_loader.dart`.
