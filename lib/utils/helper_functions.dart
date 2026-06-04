import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearvendorapp/utils/globals.dart';
import 'package:nearvendorapp/utils/hive/current_user_storage.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/views/screens/onboarding/view/welcome_screen.dart';
import 'package:url_launcher/url_launcher.dart';

void hideKeyBoard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

String shortenAddress(String address) {
  if (address.length <= 10) return address;
  return '${address.substring(0, 5)}...${address.substring(address.length - 5)}';
}

String formatAddressInLines(String address, {int charactersPerLine = 20}) {
  if (address.length <= charactersPerLine) return address;

  final List<String> lines = [];
  for (int i = 0; i < address.length; i += charactersPerLine) {
    final int end = (i + charactersPerLine < address.length)
        ? i + charactersPerLine
        : address.length;
    lines.add(address.substring(i, end));
  }
  return lines.join('\n');
}

Future<void> copyTextToClipboard(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));

  if (context.mounted) {
    AppAlerts.showSuccess(context, 'Copied to clipboard');
  }
}

bool isValidAddress(String address) {
  if (address.startsWith('0x') && address.length == 42) {
    return RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(address);
  }
  if (address.length >= 32 && address.length <= 44) {
    return RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$').hasMatch(address);
  }

  return false;
}

Future<bool> isInternetAvailable() async {
  try {
    final result = await InternetAddress.lookup('www.google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    debugPrint('"Check Your Internet Connection"');
    return false;
  }
}

String showAmountWithCurrency(double amount) {
  if (amount % 1 == 0) {
    return "\$ ${amount.toInt()}";
  }

  if (amount >= 1) {
    return "\$ ${amount.toStringAsFixed(2)}";
  }

  String full = amount.toStringAsFixed(20);

  full = full.replaceFirst(RegExp(r'0+$'), '');
  full = full.replaceFirst(RegExp(r'\.$'), '');

  final match = RegExp(r'^(0\.0*)(\d{1,2})').firstMatch(full);
  if (match != null) {
    return "\$ ${match.group(1)! + match.group(2)!}";
  }

  return "\$ $full";
}

String trimTrailingZeros(String input) {
  var s = input;
  if (!s.contains('.')) return s;
  s = s.replaceFirst(RegExp(r'0+$'), '');
  s = s.replaceFirst(RegExp(r'\.$'), '');
  return s;
}

/// Hash a password using SHA-256
String hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString(); // hex string
}

/// Compare a raw password with a stored hash
bool verifyPassword(String enteredPassword, String storedHash) {
  final enteredHash = hashPassword(enteredPassword);
  return enteredHash == storedHash;
}

Future<void> logoutUser() async {
  await CurrentUserStorage.clearUserData();
  final context = navigatorKey.currentContext;
  if (context != null && context.mounted) {
    AppNavigator.pushAndRemoveUntil(context, const WelcomeScreen());
  }
}

String shortAddress(String address) =>
    '${address.substring(0, 6)}...${address.substring(address.length - 4)}';

/// Normalises a phone number for use inside a `tel:` or WhatsApp URL.
///
/// Numbers in the wild often contain spaces, dashes, parentheses or
/// unicode separators (e.g. `+92 300 1234567`, `(0300) 123-4567`).
/// Embedding those raw characters into a URI makes `url_launcher`
/// silently fail on some Android devices because the resulting
/// `tel:` / `https://wa.me/` intent is malformed and `canLaunchUrl`
/// returns `false` even when the dialer / WhatsApp is installed.
String _sanitizePhoneNumber(String phone) {
  if (phone.isEmpty) return phone;
  final hasPlus = phone.trim().startsWith('+');
  final digitsOnly = phone.replaceAll(RegExp('[^0-9]'), '');
  return hasPlus ? '+$digitsOnly' : digitsOnly;
}

/// Opens the platform dialer with the supplied phone number.
///
/// We deliberately attempt to launch the URI directly (and catch any
/// `PlatformException`) instead of relying on `canLaunchUrl` first.
/// On Android 11+ `canLaunchUrl` returns `false` for `tel:` and for
/// `https://wa.me/` unless the host app has the matching `<queries>`
/// entries declared in `AndroidManifest.xml`, even when the dialer /
/// WhatsApp is installed and able to handle the intent. Trying the
/// launch first and falling back on the exception gives correct
/// behaviour across all devices.
Future<void> launchCaller(String phone, BuildContext context) async {
  final sanitized = _sanitizePhoneNumber(phone);
  if (sanitized.isEmpty) {
    AppAlerts.showError(
      context,
      'Phone number is not available for this vendor.',
    );
    return;
  }
  final Uri url = Uri(scheme: 'tel', path: sanitized);
  try {
    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!launched && !context.mounted) return;
    if (!launched) {
      AppAlerts.showError(context, 'No phone app is available to place a call.');
    }
  } on PlatformException catch (e) {
    debugPrint('launchCaller PlatformException: $e');
    if (!context.mounted) return;
    AppAlerts.showError(context, 'Unable to open the dialer on this device.');
  } catch (e) {
    debugPrint('launchCaller error: $e');
    if (!context.mounted) return;
    AppAlerts.showError(context, 'Unable to open the dialer on this device.');
  }
}

Future<void> launchWhatsApp(String phone, BuildContext context) async {
  final sanitized = _sanitizePhoneNumber(phone);
  if (sanitized.isEmpty) {
    AppAlerts.showError(
      context,
      'WhatsApp number is not available for this vendor.',
    );
    return;
  }
  // wa.me / api.whatsapp.com URLs expect the number with no `+` prefix.
  final digitsOnly = sanitized.startsWith('+')
      ? sanitized.substring(1)
      : sanitized;

  final candidates = <Uri>[
    Uri.parse('https://api.whatsapp.com/send?phone=$digitsOnly'),
    Uri.parse('https://wa.me/$digitsOnly'),
    Uri.parse('whatsapp://send?phone=$digitsOnly'),
  ];

  for (final url in candidates) {
    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return;
    } on PlatformException catch (e) {
      debugPrint('launchWhatsApp PlatformException for $url: $e');
    } catch (e) {
      debugPrint('launchWhatsApp error for $url: $e');
    }
  }

  if (!context.mounted) return;
  AppAlerts.showError(
    context,
    'WhatsApp is not installed on this device. Please install it or contact the vendor by phone.',
  );
}

Future<void> launchMap(
  double lat,
  double lon,
  String title,
  BuildContext context,
) async {
  final encodedTitle = Uri.encodeComponent(title);
  final geoUrl = Uri.parse('geo:$lat,$lon?q=$lat,$lon($encodedTitle)');
  final navUrl = Uri.parse('google.navigation:q=$lat,$lon');
  final fallbackUrl = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
  );

  for (final url in [geoUrl, navUrl, fallbackUrl]) {
    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return;
    } on PlatformException catch (e) {
      debugPrint('launchMap PlatformException for $url: $e');
    } catch (e) {
      debugPrint('launchMap error for $url: $e');
    }
  }

  if (!context.mounted) return;
  AppAlerts.showError(context, 'No map application is available on this device.');
}
