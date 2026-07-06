// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetsAppIconsGen {
  const $AssetsAppIconsGen();

  /// File path: assets/app_icons/nearvendor.png
  AssetGenImage get nearvendor =>
      const AssetGenImage('assets/app_icons/nearvendor.png');

  /// List of all assets
  List<AssetGenImage> get values => [nearvendor];
}

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/poppins.ttf
  String get poppins => 'assets/fonts/poppins.ttf';

  /// List of all assets
  List<String> get values => [poppins];
}

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/camera.svg
  SvgGenImage get camera => const SvgGenImage('assets/icons/camera.svg');

  /// File path: assets/icons/electronics.svg
  SvgGenImage get electronics =>
      const SvgGenImage('assets/icons/electronics.svg');

  /// File path: assets/icons/explore.svg
  SvgGenImage get explore => const SvgGenImage('assets/icons/explore.svg');

  /// File path: assets/icons/fashion_icon.svg
  SvgGenImage get fashionIcon =>
      const SvgGenImage('assets/icons/fashion_icon.svg');

  /// File path: assets/icons/furniture.svg
  SvgGenImage get furniture => const SvgGenImage('assets/icons/furniture.svg');

  /// File path: assets/icons/grocery.svg
  SvgGenImage get grocery => const SvgGenImage('assets/icons/grocery.svg');

  /// File path: assets/icons/health.svg
  SvgGenImage get health => const SvgGenImage('assets/icons/health.svg');

  /// File path: assets/icons/map.svg
  SvgGenImage get map => const SvgGenImage('assets/icons/map.svg');

  /// File path: assets/icons/near_vendor_Text.svg
  SvgGenImage get nearVendorText =>
      const SvgGenImage('assets/icons/near_vendor_Text.svg');

  /// File path: assets/icons/profile_icon.svg
  SvgGenImage get profileIcon =>
      const SvgGenImage('assets/icons/profile_icon.svg');

  /// File path: assets/icons/search_icon.svg
  SvgGenImage get searchIcon =>
      const SvgGenImage('assets/icons/search_icon.svg');

  /// File path: assets/icons/wishlist.svg
  SvgGenImage get wishlist => const SvgGenImage('assets/icons/wishlist.svg');

  /// File path: assets/icons/wishlist_add.svg
  SvgGenImage get wishlistAdd =>
      const SvgGenImage('assets/icons/wishlist_add.svg');

  /// List of all assets
  List<SvgGenImage> get values => [
    camera,
    electronics,
    explore,
    fashionIcon,
    furniture,
    grocery,
    health,
    map,
    nearVendorText,
    profileIcon,
    searchIcon,
    wishlist,
    wishlistAdd,
  ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/header_img.png
  AssetGenImage get headerImg =>
      const AssetGenImage('assets/images/header_img.png');

  /// File path: assets/images/items_art.png
  AssetGenImage get itemsArt =>
      const AssetGenImage('assets/images/items_art.png');

  /// File path: assets/images/onboarding_0.png
  AssetGenImage get onboarding0 =>
      const AssetGenImage('assets/images/onboarding_0.png');

  /// File path: assets/images/onboarding_1.png
  AssetGenImage get onboarding1 =>
      const AssetGenImage('assets/images/onboarding_1.png');

  /// File path: assets/images/onboarding_2.png
  AssetGenImage get onboarding2 =>
      const AssetGenImage('assets/images/onboarding_2.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    headerImg,
    itemsArt,
    onboarding0,
    onboarding1,
    onboarding2,
  ];
}

class Assets {
  const Assets._();

  static const String aEnv = '.env';
  static const $AssetsAppIconsGen appIcons = $AssetsAppIconsGen();
  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();

  /// List of all assets
  static List<String> get values => [aEnv];
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}

class SvgGenImage {
  const SvgGenImage(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = false;

  const SvgGenImage.vec(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    _svg.ColorMapper? colorMapper,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
        colorMapper: colorMapper,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter:
          colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
