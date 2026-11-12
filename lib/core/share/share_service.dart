import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

/// Hands a PNG to the system share sheet. Tests swap [instance] for a fake.
class ShareService {
  static ShareService instance = ShareService();

  /// Returns true when the person shared (or the platform cannot tell).
  Future<bool> sharePng(Uint8List png, String name, String text) async {
    try {
      final ShareResult r = await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[
            XFile.fromData(png, mimeType: 'image/png', name: '$name.png'),
          ],
          fileNameOverrides: <String>['$name.png'],
          text: text,
        ),
      );
      return r.status != ShareResultStatus.dismissed;
    } catch (e) {
      debugPrint('ShareService.sharePng failed: $e');
      return false;
    }
  }
}
