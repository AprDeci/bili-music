import 'dart:io';

import 'package:image/image.dart' as img;

const int _canvas = 1024;
const int _macosContent = 824; // 824 / 1024 是 Apple 的 macOS 图标内容比例
const String _source = 'assets/icons/icon3.png';
const String _macosSource = 'assets/icons/icon3_macos.png';

void main() {
  final design = img.decodeImage(File(_source).readAsBytesSync());
  if (design == null) {
    stderr.writeln('$_source 不是可解码的图片');
    exit(1);
  }
  if (design.width != _canvas || design.height != _canvas) {
    stderr.writeln('设计稿必须是 ${_canvas}x$_canvas，当前 ${design.width}x${design.height}');
    exit(1);
  }

  // 源图四边中点必须是不透明的，否则说明它已经带过边距，再补一次会缩更小。
  for (final (int x, int y) in [
    (0, _canvas ~/ 2),
    (_canvas ~/ 2, 0),
    (_canvas - 1, _canvas ~/ 2),
    (_canvas ~/ 2, _canvas - 1),
  ]) {
    if (design.getPixel(x, y).a < 255) {
      stderr.writeln('$_source 边缘是透明的，可能已经带边距；请用满画布设计稿');
      exit(1);
    }
  }

  final content = img.copyResize(
    design,
    width: _macosContent,
    height: _macosContent,
    interpolation: img.Interpolation.cubic,
  );
  final padded = img.Image(width: _canvas, height: _canvas, numChannels: 4);
  final int offset = (_canvas - _macosContent) ~/ 2;
  img.compositeImage(padded, content, dstX: offset, dstY: offset);
  File(_macosSource).writeAsBytesSync(img.encodePng(padded));
  stdout.writeln('已更新 $_macosSource（内容 ${_macosContent}px，边距 ${offset}px）');

  final result = Process.runSync(
    Platform.resolvedExecutable,
    ['run', 'flutter_launcher_icons'],
    runInShell: true,
  );
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  exit(result.exitCode);
}
