import 'package:bilimusic/feature/player/domain/playback_chapter.dart';
import 'package:bilimusic/feature/player/logic/chapters/playback_chapter_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses mm:ss lines in order', () {
    final List<PlaybackChapter> chapters = PlaybackChapterParser.parse(
      '00:00 夜曲\n03:45 晴天\n07:30 稻香',
    );

    expect(chapters.length, 3);
    expect(chapters[0].start, Duration.zero);
    expect(chapters[0].title, '夜曲');
    expect(chapters[1].start, const Duration(minutes: 3, seconds: 45));
    expect(chapters[1].title, '晴天');
    expect(chapters[2].start, const Duration(minutes: 7, seconds: 30));
  });

  test('parses hh:mm:ss, brackets and list prefixes', () {
    final List<PlaybackChapter> chapters = PlaybackChapterParser.parse(
      '1. 【01:02:03】第一首\n'
      '2、[00:00:10] 第二首',
    );

    expect(chapters.length, 2);
    expect(chapters[0].start, const Duration(seconds: 10));
    expect(chapters[0].title, '第二首');
    expect(chapters[1].start, const Duration(hours: 1, minutes: 2, seconds: 3));
    expect(chapters[1].title, '第一首');
  });

  test('splits inline segments and trims trailing range timestamps', () {
    final List<PlaybackChapter> chapters = PlaybackChapterParser.parse(
      '00:00 歌A | 03:45 歌B (07:30)',
    );

    expect(chapters.length, 2);
    expect(chapters[0].title, '歌A');
    expect(chapters[1].title, '歌B');
  });

  test('ignores noise lines and requires at least two chapters', () {
    expect(PlaybackChapterParser.parse('只有一首 00:00 歌'), isEmpty);
    expect(PlaybackChapterParser.parse(''), isEmpty);
    expect(PlaybackChapterParser.parse(null), isEmpty);
    expect(
      PlaybackChapterParser.parse('00:00 歌A\n没有时间戳的说明\n03:45 歌B').length,
      2,
    );
  });

  test('drops chapters beyond the media duration', () {
    final List<PlaybackChapter> chapters = PlaybackChapterParser.parse(
      '00:00 歌A\n03:00 歌B\n10:00 歌C',
      duration: const Duration(minutes: 5),
    );

    expect(chapters.length, 2);
    expect(chapters.last.title, '歌B');
    expect(chapters.last.end, isNull);
  });

  test('merges duplicate starts and keeps the first title', () {
    final List<PlaybackChapter> chapters = PlaybackChapterParser.parse(
      '00:00 歌A\n00:00 歌B\n03:00 歌C',
    );

    expect(chapters.length, 2);
    expect(chapters.first.title, '歌A');
  });

  test('fills end offsets from the next chapter', () {
    final List<PlaybackChapter> chapters = PlaybackChapterParser.parse(
      '00:00 歌A\n03:00 歌B',
    );

    expect(chapters.first.end, const Duration(minutes: 3));
    expect(chapters.last.end, isNull);
  });

  test('supports full-width and dash separators', () {
    final List<PlaybackChapter> chapters = PlaybackChapterParser.parse(
      '00:00 —— 开场\n'
      '02:00 – 中段\n'
      '04:00 尾声',
    );

    expect(chapters.length, 3);
    expect(chapters[0].title, '开场');
    expect(chapters[1].title, '中段');
    expect(chapters[2].title, '尾声');
  });
}
