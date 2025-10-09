// ---------------------------------------------------------------------------
// 🍃 JetLeaf Framework - https://jetleaf.hapnium.com
//
// Copyright © 2025 Hapnium & JetLeaf Contributors. All rights reserved.
//
// This source file is part of the JetLeaf Framework and is protected
// under copyright law. You may not copy, modify, or distribute this file
// except in compliance with the JetLeaf license.
//
// For licensing terms, see the LICENSE file in the root of this project.
// ---------------------------------------------------------------------------
// 
// 🔧 Powered by Hapnium — the Dart backend engine 🍃

/// {@template constant}
/// Constant class containing predefined constants used across the application.
/// 
/// This class provides a centralized location for defining constants that are
/// used throughout the application. It includes:
/// - Default profile
/// - 
/// 
/// {@endtemplate}
class Constant {
  /// {@macro constant}
  Constant._();

  /// {@macro constant}
  /// Default profile
  /// 
  /// This is the default profile used by Jet applications
  static const String DEFAULT_PROFILE = 'jetleaf';

  /// {@macro constant}
  /// 
  /// The name of the default constructor value
  static const String DEFAULT_CONSTRUCTOR = "default";

  /// {@template html_constant_favicon}
  /// A base64-encoded [SVG] favicon string that renders an emoji icon directly in HTML.
  ///
  /// This is especially useful for lightweight server-rendered apps or development environments
  /// where no external favicon file is hosted.
  ///
  /// The icon defaults to the leaf emoji 🍃, but you can replace `${ICON}` with any valid character or emoji.
  ///
  /// Example:
  /// ```dart
  /// final faviconMarkup = HtmlConstant.FAVICON.replaceAll('${HtmlConstant.ICON}', '🔥');
  /// ```
  ///
  /// The `viewBox` ensures proper scaling, and the `font-size` controls how large the emoji renders.
  /// {@endtemplate}
  static const String FAVICON = "data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>$ICON</text></svg>";

  /// {@template html_constant_icon}
  /// The default icon used in [FAVICON] — a leaf emoji 🍃.
  ///
  /// You can override this to inject other emojis or characters into the SVG-based favicon.
  ///
  /// Example:
  /// ```dart
  /// const customIcon = HtmlConstant.FAVICON.replaceAll('${HtmlConstant.ICON}', '💡');
  /// ```
  /// {@endtemplate}
  static const String ICON = "🍃";

  /// {@template html_constant_default_html_pages_directory_path}
  /// The default directory path for HTML pages.
  ///
  /// This is the default directory path for HTML pages.
  /// {@endtemplate}
  static const String DEFAULT_HTML_PAGES_DIRECTORY_PATH = "lib/src/components/http/pages";

  /// {@template html_constant_home_page}
  /// The default home page for JetLeaf applications.
  ///
  /// This is the default home page for JetLeaf applications.
  /// {@endtemplate}
  static const String HOME_PAGE = "/jetleaf";

  /// Path to the JetLeaf asset directory inside `lib/`.
  ///
  /// This is where static or generated assets are located during development.
  static const String PACKAGE_ASSET_DIR = 'assets';

  /// Default directory where compiled or temporary files are placed.
  static const String BUILD_TARGET_DIR_NAME = 'target';

  /// Default file path used for bootstrapping the application.
  ///
  /// JetLeaf may generate or expect a `bootstrap.dart` file here to run the app.
  static const String BOOTSTRAP_TARGET_FILE_NAME = 'target/bootstrap.dart';

  /// Default location of the compiled kernel `.dill` file for launching the app.
  static const String BUILD_TARGET_FILE_NAME = 'build/main.dill';

  /// Name of the generated resources directory (non-package-specific).
  static const String GENERATED_RESOURCES_DIR_NAME = 'generated_resources';

  /// Name of the default resources directory (non-package-specific).
  static const String RESOURCES_DIR_NAME = 'resources';

  /// Name of the generated runtime context file.
  static const String GENERATED_RUNTIME_CONTEXT_FILE_NAME = 'generated_runtime_context.dart';

  /// Name of the development flag.
  static const String DEV_FLAG = "--jetleaf-dev";

  /// Name of the development hot reload flag.
  static const String DEV_HOT_RELOAD_FLAG = "--watch";

  /// Name of the development hot reload flag negation.
  static const String DEV_HOT_RELOAD_FLAG_NEGATION = "--no-watch";

  /// Name of the Dart SDK package.
  static const String DART_PACKAGE_NAME = "dart-sdk";
}

/// {@template package_names}
/// A central collection of constant package name identifiers used
/// throughout the **Jetleaf framework**.
///
/// These names are used for namespacing, module organization,
/// and avoiding hard-coded strings in the codebase. By centralizing
/// them here, it ensures consistency and reduces the likelihood
/// of typos.
///
/// ### Example
/// ```dart
/// void main() {
///   print(PackageNames.MAIN);   // "jetleaf"
///   print(PackageNames.POD);   // "jetleaf_core"
///   print(PackageNames.LANG);   // "jetleaf_lang"
/// }
/// ```
/// {@endtemplate}
class PackageNames {
  /// {@macro package_names}
  ///
  /// The root name of the framework: `"jetleaf"`.
  static const String MAIN = "jetleaf";

  /// The package name for the **core** module.
  ///
  /// Value: `"jetleaf_core"`.
  static const String CORE = "${MAIN}_core";

  /// The package name for the **type conversion** module.
  ///
  /// Value: `"jetleaf_convert"`.
  static const String CONVERT = "${MAIN}_convert";

  /// The package name for the **language support** module.
  ///
  /// Value: `"jetleaf_lang"`.
  static const String LANG = "${MAIN}_lang";

  /// The package name for the **meta-programming** module.
  ///
  /// Value: `"jetleaf_meta"`.
  static const String META = "${MAIN}_meta";

  /// The package name for the **utility** module.
  ///
  /// Value: `"jetleaf_utils"`.
  static const String UTILS = "${MAIN}_utils";

  /// The package name for the **Dart SDK**.
  ///
  /// Value: `"dart_sdk"`.
  static const String DART = "dart_sdk";

  /// The package name for the **logging support** module
  /// 
  /// Value: `"jetleaf_logging"`
  static const String LOGGING = "${MAIN}_logging";

  /// The package name for the **web server** module
  /// 
  /// Value: `"jetleaf_web"`
  static const String WEB = "${MAIN}_web";

  /// The package name for the **pod** module
  /// 
  /// Value: `"jetleaf_pod"`
  static const String POD = "${MAIN}_pod";

  /// The package name for the **scheduler** module
  /// 
  /// Value: `"jetleaf_scheduler"`
  static const String SCHEDULER = "${MAIN}_scheduler";

  /// The package name for the **security** module
  /// 
  /// Value: `"jetleaf_security"`
  static const String SECURITY = "${MAIN}_security";

  /// The package name for the **testing** module
  /// 
  /// Value: `"jetleaf_test"`
  static const String TEST = "${MAIN}_test";

  /// The package name for the **data** module
  /// 
  /// Value: `"jetleaf_data"`
  static const String DATA = "${MAIN}_data";

  /// The package name for the **rate limiter** module
  /// 
  /// Value: `"jetleaf_rate_limiter"`
  static const String RATE_LIMITER = "${MAIN}_rate_limiter";

  /// The package name for the **cache** module
  /// 
  /// Value: `"jetleaf_cache"`
  static const String CACHE = "${MAIN}_cache";

  /// The package name for the **validation** module
  /// 
  /// Value: `"jetleaf_validation"`
  static const String VALIDATION = "${MAIN}_validation";

  /// The package name for the **jetson** module
  /// 
  /// Value: `"jetson"`
  static const String JETSON = "jetson";

  /// The package name for the **environment** module
  /// 
  /// Value: `"jetleaf_env"`
  static const String ENV = "${MAIN}_env";
}