import 'dart:convert';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_ce/hive.dart';

const Size defaultDesktopWindowSize = Size(1050, 700);

class DesktopWindowState {
  const DesktopWindowState({
    required this.position,
    required this.size,
    required this.isMaximized,
  });

  final Offset position;
  final Size size;
  final bool isMaximized;

  Map<String, Object> toJson() {
    return <String, Object>{
      'x': position.dx,
      'y': position.dy,
      'width': size.width,
      'height': size.height,
      'isMaximized': isMaximized,
    };
  }

  static DesktopWindowState? fromJson(Map<String, dynamic> json) {
    final double? x = _readDouble(json['x']);
    final double? y = _readDouble(json['y']);
    final double? width = _readDouble(json['width']);
    final double? height = _readDouble(json['height']);
    final Object? isMaximizedValue = json['isMaximized'];

    if (x == null ||
        y == null ||
        width == null ||
        height == null ||
        isMaximizedValue is! bool) {
      return null;
    }

    return DesktopWindowState(
      position: Offset(x, y),
      size: Size(
        width.clamp(defaultDesktopWindowSize.width, double.infinity),
        height.clamp(defaultDesktopWindowSize.height, double.infinity),
      ),
      isMaximized: isMaximizedValue,
    );
  }

  static double? _readDouble(Object? value) {
    final double? parsed = switch (value) {
      num() => value.toDouble(),
      String() => double.tryParse(value),
      _ => null,
    };

    if (parsed == null || parsed.isNaN || parsed.isInfinite) {
      return null;
    }

    return parsed;
  }
}

class DesktopWindowStateStore {
  const DesktopWindowStateStore(this._prefsBox);

  final Box<String> _prefsBox;

  DesktopWindowState? read() {
    final String rawValue =
        _prefsBox.get(HiveKeys.desktopWindowState, defaultValue: '') ?? '';
    if (rawValue.isEmpty) {
      return null;
    }

    try {
      final Object? decoded = jsonDecode(rawValue);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return DesktopWindowState.fromJson(decoded);
    } on FormatException {
      return null;
    }
  }

  Future<void> write(DesktopWindowState state) {
    return _prefsBox.put(HiveKeys.desktopWindowState, jsonEncode(state));
  }
}
