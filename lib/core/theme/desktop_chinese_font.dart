import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

final class DesktopChineseFont {
  const DesktopChineseFont._();

  static const String fontFamily = 'BilimusicDesktopChinese';

  static Future<void> load() async {
    if (!Platform.isLinux && !Platform.isWindows) {
      return;
    }

    final File fontFile = File(_bundleFontPath());
    if (!await fontFile.exists()) {
      return;
    }

    final Uint8List bytes = await fontFile.readAsBytes();
    await ui.loadFontFromList(bytes, fontFamily: fontFamily);
  }

  static String _bundleFontPath() {
    final File executable = File(Platform.resolvedExecutable);
    return '${executable.parent.path}/data/fonts/MiSans-Regular.ttf';
  }
}
