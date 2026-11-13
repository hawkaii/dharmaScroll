import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

/// Shares plain text from a reply. Tests swap [send].
abstract final class EkantShare {
  static Future<void> Function(String text) send = _system;

  static Future<void> _system(String text) async {
    try {
      await SharePlus.instance.share(ShareParams(text: text));
    } catch (e) {
      debugPrint('EkantShare: $e');
    }
  }
}
