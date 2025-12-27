import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearvendorapp/utils/app_alerts.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/globals.dart';
import 'package:nearvendorapp/views/screens/onboarding/views/welcome_screen.dart';

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
    AppAlerts.showSuccessSnackBar(context, 'Copied to clipboard');
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

void logoutUser() {
  final context = navigatorKey.currentContext;
  if (context?.mounted ?? false) {
    AppNavigator.pushAndRemoveUntil(context!, const WelcomeScreen());
  }
}

String shortAddress(String address) =>
    '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
