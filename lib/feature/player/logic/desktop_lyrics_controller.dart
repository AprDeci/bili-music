import 'dart:async';

import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/utils/player_display_metadata.dart';
import 'package:desktop_lyrics/desktop_lyrics.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'desktop_lyrics_controller.g.dart';

@Riverpod(keepAlive: true)
class DesktopLyricsController extends _$DesktopLyricsController {
  DesktopLyrics? _lyrics;
  Future<void> _syncQueue = Future<void>.value();
  bool _pluginEnabled = false;
  String? _renderedStableId;
  String? _renderedLine;
  double? _renderedProgress;

  @override
  bool build() {
    final bool enabled = ref
        .read(appSettingsStoreProvider)
        .readBool(HiveKeys.desktopLyricsEnabled, defaultValue: false);
    if (!PlatformUtil.isWindows) {
      return enabled;
    }

    _lyrics = DesktopLyrics();
    ref.listen<PlayerState>(
      playerControllerProvider,
      (_, _) => _scheduleSync(),
      fireImmediately: true,
    );
    ref.listen<MetadataState>(
      metadataControllerProvider,
      (_, _) => _scheduleSync(),
      fireImmediately: true,
    );
    return enabled;
  }

  Future<void> setEnabled(bool value) async {
    state = value;
    await ref
        .read(appSettingsStoreProvider)
        .writeBool(HiveKeys.desktopLyricsEnabled, value);
    _scheduleSync();
  }

  Future<void> toggle() => setEnabled(!state);

  void _scheduleSync() {
    if (!PlatformUtil.isWindows) {
      return;
    }
    _syncQueue = _syncQueue.then((_) => _sync());
  }

  Future<void> _sync() async {
    final DesktopLyrics? lyrics = _lyrics;
    if (lyrics == null) {
      return;
    }
    if (!state) {
      await _clearAndDisable(lyrics);
      return;
    }

    final PlayerState playerState = ref.read(playerControllerProvider);
    final MetadataState metadataState = ref.read(metadataControllerProvider);
    final String? stableId = playerState.currentItem?.stableId;
    if (_renderedStableId != null && _renderedStableId != stableId) {
      await _clearAndDisable(lyrics);
    }
    final String? rawLyrics = metadataState.stableId == stableId
        ? resolveDisplayLyrics(metadataState.metadata)
        : null;
    final DesktopLyricFrame? frame = resolveDesktopLyricFrame(
      rawLyrics,
      position: playerState.position,
      offsetMs: resolveDisplayLyricOffsetMs(metadataState.metadata),
    );
    if (frame == null) {
      await _clearAndDisable(lyrics);
      return;
    }

    await _setPluginEnabled(lyrics, true);
    if (_renderedLine == frame.line && _renderedProgress == frame.progress) {
      return;
    }
    await lyrics.render(
      DesktopLyricsFrame.line(
        currentLine: frame.line,
        lineProgress: frame.progress,
      ),
    );
    _renderedLine = frame.line;
    _renderedProgress = frame.progress;
    _renderedStableId = stableId;
  }

  Future<void> _clearAndDisable(DesktopLyrics lyrics) async {
    if (_pluginEnabled && _renderedLine != '') {
      await lyrics.render(const DesktopLyricsFrame.line(currentLine: ''));
      _renderedLine = '';
      _renderedProgress = 1;
    }
    _renderedStableId = null;
    await _setPluginEnabled(lyrics, false);
  }

  Future<void> _setPluginEnabled(DesktopLyrics lyrics, bool enabled) async {
    if (_pluginEnabled == enabled) {
      return;
    }
    await lyrics.apply(
      lyrics.state.copyWith(
        interaction: lyrics.state.interaction.copyWith(enabled: enabled),
        background: lyrics.state.background.copyWith(
          opacity: 0.3,
          backgroundColor: Colors.black,
        ),
        text: lyrics.state.text.copyWith(
          fontSize: 24,
          textColor: Colors.blue[400],
        ),
        gradient: lyrics.state.gradient.copyWith(textGradientEnabled: false),
      ),
    );
    _pluginEnabled = enabled;
  }
}

class DesktopLyricFrame {
  const DesktopLyricFrame({required this.line, required this.progress});

  final String line;
  final double progress;
}

class _DesktopLyricLine {
  const _DesktopLyricLine({
    required this.startMs,
    required this.durationMs,
    required this.text,
  });

  final int startMs;
  final int? durationMs;
  final String text;
}

DesktopLyricFrame? resolveDesktopLyricFrame(
  String? rawLyrics, {
  required Duration position,
  required int offsetMs,
}) {
  final _ParsedDesktopLyrics parsedLyrics = _parseDesktopLyrics(rawLyrics);
  final List<_DesktopLyricLine> lines = parsedLyrics.lines;
  if (lines.isEmpty) {
    return null;
  }
  final int positionMs =
      position.inMilliseconds + offsetMs - parsedLyrics.offsetMs;
  _DesktopLyricLine? current;
  _DesktopLyricLine? next;
  _DesktopLyricLine? previousNonEmpty;
  for (final _DesktopLyricLine line in lines) {
    if (line.startMs > positionMs) {
      next = line;
      break;
    }
    current = line;
    if (line.text.isNotEmpty) {
      previousNonEmpty = line;
    }
  }
  if (current == null) {
    return null;
  }
  if (current.text.isEmpty) {
    final _DesktopLyricLine? line = previousNonEmpty;
    return line == null
        ? null
        : DesktopLyricFrame(line: line.text, progress: 1);
  }
  final int durationMs =
      current.durationMs ??
      ((next?.startMs ?? current.startMs) - current.startMs);
  final double progress = durationMs <= 0
      ? 1
      : ((positionMs - current.startMs) / durationMs).clamp(0, 1).toDouble();
  return DesktopLyricFrame(line: current.text, progress: progress);
}

class _ParsedDesktopLyrics {
  const _ParsedDesktopLyrics({required this.lines, required this.offsetMs});

  final List<_DesktopLyricLine> lines;
  final int offsetMs;
}

enum _DesktopLyricsFormat { lrc, krc, qrc, yrc }

final RegExp _lrcTimestamp = RegExp(r'\[(\d{1,3}):(\d{2})(?:[.:](\d{1,3}))?\]');
final RegExp _timedLine = RegExp(r'^\[(\d+),(\d+)(?:,\d+)?\]\s*(.*)$');
final RegExp _timedWord = RegExp(
  r'(?:\(-?\d+,-?\d+(?:,-?\d+)?\)|<-?\d+,-?\d+(?:,-?\d+)?>)',
);
final RegExp _offsetTag = RegExp(
  r'^\[offset[:,](-?\d+)\]$',
  caseSensitive: false,
);

_ParsedDesktopLyrics _parseDesktopLyrics(String? rawLyrics) {
  final String source = rawLyrics?.trim() ?? '';
  if (source.isEmpty) {
    return const _ParsedDesktopLyrics(
      lines: <_DesktopLyricLine>[],
      offsetMs: 0,
    );
  }

  return switch (_detectDesktopLyricsFormat(source)) {
    _DesktopLyricsFormat.lrc => _parseLrcLyrics(source),
    _DesktopLyricsFormat.krc => _parseKrcLyrics(source),
    _DesktopLyricsFormat.qrc => _parseQrcLyrics(source),
    _DesktopLyricsFormat.yrc => _parseYrcLyrics(source),
  };
}

_DesktopLyricsFormat _detectDesktopLyricsFormat(String source) {
  if (RegExp(r'^\[\d+,\d+,\d+\]', multiLine: true).hasMatch(source) ||
      RegExp(
        r'^\[offset,-?\d+\]$',
        multiLine: true,
        caseSensitive: false,
      ).hasMatch(source)) {
    return _DesktopLyricsFormat.krc;
  }
  if (RegExp(
    r'^\[\d+,\d+\]\s*\(-?\d+,-?\d+,-?\d+\)',
    multiLine: true,
  ).hasMatch(source)) {
    return _DesktopLyricsFormat.yrc;
  }
  if (RegExp(r'^\[\d+,\d+\]', multiLine: true).hasMatch(source)) {
    return _DesktopLyricsFormat.qrc;
  }
  return _DesktopLyricsFormat.lrc;
}

_ParsedDesktopLyrics _parseLrcLyrics(String source) {
  final List<_DesktopLyricLine> result = <_DesktopLyricLine>[];
  int lyricsOffsetMs = 0;
  for (final String sourceLine in source.split(RegExp(r'\r?\n'))) {
    final RegExpMatch? offsetMatch = _offsetTag.firstMatch(sourceLine.trim());
    if (offsetMatch != null) {
      lyricsOffsetMs = int.parse(offsetMatch.group(1)!);
      continue;
    }
    final Iterable<RegExpMatch> matches = _lrcTimestamp.allMatches(sourceLine);
    final String text = sourceLine.replaceAll(_lrcTimestamp, '').trim();
    for (final RegExpMatch match in matches) {
      final String fraction = match.group(3) ?? '';
      final int fractionMs = fraction.isEmpty
          ? 0
          : int.parse(fraction.padRight(3, '0').substring(0, 3));
      result.add(
        _DesktopLyricLine(
          startMs:
              int.parse(match.group(1)!) * Duration.millisecondsPerMinute +
              int.parse(match.group(2)!) * Duration.millisecondsPerSecond +
              fractionMs,
          durationMs: null,
          text: text,
        ),
      );
    }
  }
  return _sortedLyrics(result, lyricsOffsetMs);
}

_ParsedDesktopLyrics _parseKrcLyrics(String source) =>
    _parseTimedLyrics(source);

_ParsedDesktopLyrics _parseQrcLyrics(String source) =>
    _parseTimedLyrics(source);

_ParsedDesktopLyrics _parseYrcLyrics(String source) =>
    _parseTimedLyrics(source);

_ParsedDesktopLyrics _parseTimedLyrics(String source) {
  final List<_DesktopLyricLine> result = <_DesktopLyricLine>[];
  int lyricsOffsetMs = 0;
  for (final String sourceLine in source.split(RegExp(r'\r?\n'))) {
    final RegExpMatch? offsetMatch = _offsetTag.firstMatch(sourceLine.trim());
    if (offsetMatch != null) {
      lyricsOffsetMs = int.parse(offsetMatch.group(1)!);
      continue;
    }
    final RegExpMatch? lineMatch = _timedLine.firstMatch(sourceLine);
    if (lineMatch == null) {
      continue;
    }
    result.add(
      _DesktopLyricLine(
        startMs: int.parse(lineMatch.group(1)!),
        durationMs: int.parse(lineMatch.group(2)!),
        text: lineMatch.group(3)!.replaceAll(_timedWord, '').trim(),
      ),
    );
  }
  return _sortedLyrics(result, lyricsOffsetMs);
}

_ParsedDesktopLyrics _sortedLyrics(
  List<_DesktopLyricLine> lines,
  int offsetMs,
) {
  lines.sort(
    (_DesktopLyricLine a, _DesktopLyricLine b) =>
        a.startMs.compareTo(b.startMs),
  );
  return _ParsedDesktopLyrics(lines: lines, offsetMs: offsetMs);
}
