import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeepLinkService {
  static late AppLinks _appLinks;

  DeepLinkService._();

  static Future<void> initialize() async {
    try {
      _appLinks = AppLinks();

      _appLinks.uriLinkStream.listen((uri) {
        debugPrint('Deep link received: $uri');
        _processDeepLink(uri.toString());
      });

      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('Initial deep link: $initialUri');
        _processDeepLink(initialUri.toString());
      }
    } catch (e) {
      debugPrint('Error initializing deep link service: $e');
    }
  }

  static Future<void> _processDeepLink(String link) async {
    debugPrint('Processing deep link: $link');

    try {
      if (_isWalletConnectUri(link)) {
        await _handleWalletConnectUri(link);
      } else {
        debugPrint('Not a WalletConnect URI: $link');
      }
    } catch (e) {
      debugPrint('Error processing deep link: $e');
    }
  }

  static bool _isWalletConnectUri(String uri) {
    return uri.startsWith('wc:') || uri.contains('bridge=');
  }

  static Future<void> _handleWalletConnectUri(String uri) async {
    debugPrint('Handling WalletConnect URI from deep link: $uri');

    try {
      if (_onWalletConnectDeepLinkReceived != null) {
        await _onWalletConnectDeepLinkReceived!(uri);
      }
    } catch (e) {
      debugPrint('Error handling WalletConnect URI: $e');
    }
  }

  static Future<void> Function(String uri)? _onWalletConnectDeepLinkReceived;

  // ignore: use_setters_to_change_properties
  static void setWalletConnectCallback(
    Future<void> Function(String uri) callback,
  ) {
    _onWalletConnectDeepLinkReceived = callback;
  }
}
