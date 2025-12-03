## [1.0.6]

- Updated dependencies
- Added executable DSL classes

## [1.0.5]

- Updated dependencies

## [1.0.4]

- Updated dependencies

## [1.0.3]

- Updated dependencies

## [1.0.2]

- Updated dependencies

## [1.0.1]

- Improved application scanner filtering logic to provide finer-grained package and path exclusion rules and reduce false positives during runtime scans. This improves scan performance and accuracy when scanning large workspaces or mixed-package repositories.
- Revised and refactored the generic extractor design to make type extraction and generic parsing more robust (better handling of nested generics and edge cases encountered during code generation).

Notes: This is a backwards-compatible improvement release that stabilizes scanning and extraction behavior for downstream generators.

## 1.0.0
- Setting out the first version for jetleaf_lang

## 1.0.0+1
- Added extra new logic for application scanner filtering
- Revised generic extractor design