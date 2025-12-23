# Changelog

All notable changes to this project will be documented in this file.  
This project follows a simple, human-readable changelog format inspired by
[Keep a Changelog](https://keepachangelog.com/) and adheres to semantic versioning.

---

## [1.1.2]

### Changed
- Updated dependency: `jetleaf_build`

---

## [1.1.1]

This release aligns `jetleaf_lang` with the redesigned runtime and declaration model
introduced in `jetleaf_build 1.1.0`.

### Changed
- Updated dependency: `jetleaf_build`.
- Merged `FunctionClass` and `RecordClass` APIs into the unified `Class` API,
  reducing surface area and improving consistency across meta abstractions.

### Added
- Introduced a lightweight garbage collection facility:
  - `GarbageCollector`, accessible via `GC`
  - Manual cleanup support through `GC.cleanup()` and related helpers

### Removed
- `ClassNotFoundException`,
  `System`,
  `SystemDetector`,
  `SystemProperties`,
  `StdExtension`,
  `SystemExtension` and
  `QualifiedName`, which are now provided by `jetleaf_build`.
- Legacy meta abstractions:
  - `ClassLoader`
  - `FunctionClass`
  - `RecordClass`

### Notes
- This release continues the transition toward a single, unified meta model for
  all Dart language constructs.
- Consumers using removed APIs should migrate to the `Class` abstraction and
  rely on `jetleaf_build` for runtime-level exceptions and resolution behavior.

---

## [1.1.0]

### Changed
- Updated dependency: `jetleaf_build`

---

## [1.0.9]

### Added
- New tests for meta APIs:
  - `Class`, `Method`, `Field`, `Constructor`, `Parameter`, `Annotation`, and `ClassType`
- New APIs introduced to improve clarity and correctness when working with Dart language constructs:
  - `MaterializedRuntimeHint` and `MaterializedRuntimeHintDescriptor`  
    _Uses the `Class` API for AOT runtime hints_
  - `RecordClass`  
    _Targets Dart `Record` types and enables supported record-specific behavior_
  - `EnumValue`  
    _Enum-specific abstraction, similar to `Field` but specialized_
  - `TypedefClass`  
    _Provides dedicated handling for Dart typedefs_
  - `FunctionClass`  
    _Designed for parameterized function types used in methods and constructors_
- Source APIs now include:
  - `Author` API, driven by the `Author` annotation, to describe the originator
  - `Version` and `VersionRange` APIs, accessible from `Package` and source APIs

### Changed
- Updated dependency: `jetleaf_build`
- Updated `Class` and meta APIs to align with new build designs

### Removed
- `ExecutableArgument`, as it is now provided by `jetleaf_build`
- `ResolvableType` API, which is now obsolete

### Notes
- Newly introduced APIs are intentionally explicit to help developers clearly understand
  which language construct they are working with and to proceed with appropriate caution.

---

## [1.0.8]

### Added
- `getAsset` method to `StringExtension`

### Changed
- Updated dependency: `jetleaf_build`

---

## [1.0.7]

### Changed
- Updated dependency: `jetleaf_build`

---

## [1.0.6]

### Added
- Executable DSL classes

### Changed
- Updated dependencies

---

## [1.0.5]

### Changed
- Updated dependencies

---

## [1.0.4]

### Changed
- Updated dependencies

---

## [1.0.3]

### Changed
- Updated dependencies

---

## [1.0.2]

### Changed
- Updated dependencies

---

## [1.0.1]

### Changed
- Improved application scanner filtering logic to provide finer-grained package and path
  exclusion rules, reducing false positives during runtime scans.
- Revised and refactored the generic extractor design for more robust type extraction and
  generic parsing, including better handling of nested generics and edge cases.

### Notes
- This is a backward-compatible improvement release that stabilizes scanning and extraction
  behavior for downstream generators.

---

## [1.0.0]

### Added
- Initial release of **jetleaf_lang**

---

## [1.0.0+1]

### Added
- Additional logic for application scanner filtering
- Further revisions to the generic extractor design

### Notes
- This package provides a small, ergonomic lang surface for JetLeaf-powered
  applications. Refer to the project `README.md` and documentation for usage
  examples and advanced configuration.

---

## Links

- Homepage: https://jetleaf.hapnium.com  
- Documentation: https://jetleaf.hapnium.com/docs/lang  
- Repository: https://github.com/jetleaf/jetleaf_lang  
- Issues: https://github.com/jetleaf/jetleaf_lang/issues  

---

**Contributors:** Hapnium & JetLeaf contributors