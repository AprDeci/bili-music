import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/feature/player/domain/player_lyric_settings.dart';
import 'package:bilimusic/feature/player/logic/player_lyric_settings_logic.dart';
import 'package:bilimusic/feature/player/ui/components/player_dynamic_backdrop.dart';
import 'package:bilimusic/feature/player/ui/components/player_lyric_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/flutter_lyric.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showPlayerLyricSettings(
  BuildContext context, {
  Color? activeColor,
}) async {
  final Widget panel = _PlayerLyricSettingsPanel(activeColor: activeColor);
  if (PlatformUtil.isDesktop) {
    await showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(width: 540, height: 760, child: panel),
      ),
    );
  } else {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (BuildContext context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: FractionallySizedBox(heightFactor: 0.9, child: panel),
      ),
    );
  }
}

class _PlayerLyricSettingsPanel extends ConsumerStatefulWidget {
  const _PlayerLyricSettingsPanel({this.activeColor});
  final Color? activeColor;
  @override
  ConsumerState<_PlayerLyricSettingsPanel> createState() =>
      _PlayerLyricSettingsPanelState();
}

class _PlayerLyricSettingsPanelState
    extends ConsumerState<_PlayerLyricSettingsPanel> {
  late PlayerLyricSettings _draft;
  late final LyricController _previewController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _draft = ref.read(playerLyricSettingsLogicProvider);
    _previewController = LyricController()
      ..load(
        '[00:00.000]听见音乐的颜色\n'
        '[00:04.000]让每一句歌词都在此刻的旋律里刚刚好\n'
        '[00:08.000]跟随此刻的旋律',
        translation:
            '[00:00.000]Hear the colors of music\n'
            '[00:04.000]Every line finds its place in the melody\n'
            '[00:08.000]Follow the melody',
      )
      ..setPosition(const Duration(seconds: 6));
  }

  @override
  void dispose() {
    _previewController.dispose();
    super.dispose();
  }

  Future<void> _apply(PlayerLyricSettings value) async {
    if (_saving) return;
    setState(() {
      _draft = value;
      _saving = true;
    });
    try {
      await ref.read(playerLyricSettingsLogicProvider.notifier).update(value);
    } on Object {
      if (!mounted) return;
      setState(() => _draft = ref.read(playerLyricSettingsLogicProvider));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('歌词外观保存失败，请重试')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DefaultTabController(
      length: 3,
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) => Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text('歌词外观', style: theme.textTheme.titleLarge),
                    ),
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () => _apply(const PlayerLyricSettings()),
                      child: const Text('恢复默认'),
                    ),
                    IconButton(
                      tooltip: '关闭歌词外观',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: (constraints.maxHeight * 0.24).clamp(64, 180),
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        PlayerDynamicBackdrop(baseColor: widget.activeColor),
                        LyricView(
                          controller: _previewController,
                          preset: buildPlayerLyricPreset(
                            theme: theme,
                            settings: _draft,
                            activeColor: widget.activeColor,
                            reduceMotion: MediaQuery.disableAnimationsOf(
                              context,
                            ),
                          ).copyWith(interactive: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const TabBar(
                tabs: <Widget>[
                  Tab(text: '文字'),
                  Tab(text: '布局'),
                  Tab(text: '配色与动效'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: <Widget>[
                    _list('text', _typography()),
                    _list('layout', _layout()),
                    _list('effects', _effects()),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Text(
                  MediaQuery.disableAnimationsOf(context)
                      ? '系统已开启减少动态效果，歌词动效将关闭。'
                      : '修改后自动保存，应用于所有歌曲。',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _list(String key, List<Widget> children) => ListView(
    key: PageStorageKey<String>('lyric-settings-$key'),
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
    children: children,
  );

  List<Widget> _typography() => <Widget>[
    _section('歌词文字', '当前句指正在播放的歌词；未单独调整的字号会沿用正文。'),
    _slider(
      'lyricFontScale',
      '正文大小',
      _draft.fontScale,
      10 / 30,
      1.6,
      (double v) => _draft.copyWith(fontScale: v),
      display: '${(30 * _draft.fontScale).round()} px',
    ),
    _slider(
      'lyricActiveFontSize',
      '当前句大小',
      _draft.activeFontSize ?? 30 * _draft.fontScale,
      10,
      60,
      (double v) => _draft.copyWith(activeFontSize: v),
    ),
    _choice<int>(
      'lyricActiveFontWeight',
      '当前句字重',
      _draft.activeFontWeight,
      const <int, String>{
        400: '常规 400',
        500: '中等 500',
        600: '半粗 600',
        700: '加粗 700',
        800: '特粗 800',
      },
      (int v) => _draft.copyWith(activeFontWeight: v),
    ),
    _slider(
      'lyricTextOpacity',
      '正文透明度',
      _draft.textOpacity,
      0,
      1,
      (double v) => _draft.copyWith(textOpacity: v),
      percent: true,
    ),
    _slider(
      'lyricActiveTextOpacity',
      '当前句文字透明度',
      _draft.activeTextOpacity ?? _draft.textOpacity,
      0,
      1,
      (double v) => _draft.copyWith(activeTextOpacity: v),
      percent: true,
    ),
    _choice<bool>(
      'lyricActiveTextColorMode',
      '当前句文字颜色',
      _draft.activeTextColor != null,
      const <bool, String>{false: '跟随主题', true: '自定义'},
      (bool v) => _draft.copyWith(
        activeTextColor: v
            ? Theme.of(context).colorScheme.onSurface.toARGB32()
            : null,
      ),
    ),
    if (_draft.activeTextColor != null)
      _LyricColorEditor(
        color: _draft.activeTextColor!,
        enabled: !_saving,
        label: '当前句颜色值',
        applyTooltip: '应用当前句颜色',
        onChanged: (int v) => _apply(_draft.copyWith(activeTextColor: v)),
      ),
    _section('歌词译文', '分别调整普通句和当前句的译文大小。'),
    _slider(
      'lyricTranslationFontSize',
      '译文大小',
      _draft.translationFontSize ?? 16 * _draft.fontScale,
      8,
      32,
      (double v) => _draft.copyWith(translationFontSize: v),
    ),
    _slider(
      'lyricActiveTranslationFontSize',
      '当前译文大小',
      _draft.activeTranslationFontSize ??
          _draft.translationFontSize ??
          16 * _draft.fontScale,
      8,
      36,
      (double v) => _draft.copyWith(activeTranslationFontSize: v),
    ),
    _slider(
      'lyricTranslationSpacing',
      '译文间距',
      _draft.translationSpacing,
      0,
      32,
      (double v) => _draft.copyWith(translationSpacing: v),
    ),
  ];

  List<Widget> _layout() => <Widget>[
    _section('显示与换行'),
    _choice<PlayerLyricDisplayMode>(
      'lyricDisplayMode',
      '显示方式',
      _draft.displayMode,
      const <PlayerLyricDisplayMode, String>{
        PlayerLyricDisplayMode.scrollable: '多行列表',
        PlayerLyricDisplayMode.activeLine: '仅当前句',
      },
      (PlayerLyricDisplayMode v) => _draft.copyWith(displayMode: v),
    ),
    _choice<PlayerLyricLayoutMode>(
      'lyricLayoutMode',
      '长句换行方式',
      _draft.layoutMode,
      const <PlayerLyricLayoutMode, String>{
        PlayerLyricLayoutMode.fixed: '保持换行位置',
        PlayerLyricLayoutMode.dualStyle: '随字号重新换行',
      },
      (PlayerLyricLayoutMode v) => _draft.copyWith(layoutMode: v),
    ),
    _note(
      _draft.layoutMode == PlayerLyricLayoutMode.fixed
          ? '按当前句样式统一计算换行，切句时保持断行位置。'
          : '普通句与当前句分别排版，字号变化时可能重新换行。',
    ),
    _section('对齐与间距', '文字对齐影响长句换行后的每一行；内容对齐影响整块歌词的位置。'),
    _choice<PlayerLyricAlignment>(
      'lyricAlignment',
      '文字对齐',
      _draft.alignment,
      _alignmentLabels,
      (PlayerLyricAlignment v) => _draft.copyWith(
        alignment: v,
        contentAlignment: _draft.contentAlignment ?? _draft.alignment,
      ),
    ),
    _choice<PlayerLyricAlignment>(
      'lyricContentAlignment',
      '内容对齐',
      _draft.contentAlignment ?? _draft.alignment,
      _alignmentLabels,
      (PlayerLyricAlignment v) => _draft.copyWith(contentAlignment: v),
    ),
    _slider(
      'lyricLineSpacing',
      '行间留白',
      _draft.lineSpacing,
      0,
      80,
      (double v) => _draft.copyWith(lineSpacing: v),
    ),
    _slider(
      'lyricHorizontalPadding',
      '水平边距',
      _draft.horizontalPadding,
      0,
      80,
      (double v) => _draft.copyWith(horizontalPadding: v),
    ),
    _section('歌词停留位置', '设置自动跟随播放和手动浏览选句时的垂直停留位置。'),
    ..._anchor(selection: false),
    ..._anchor(selection: true),
  ];

  static const Map<PlayerLyricAlignment, String> _alignmentLabels =
      <PlayerLyricAlignment, String>{
        PlayerLyricAlignment.start: '左对齐',
        PlayerLyricAlignment.center: '居中',
        PlayerLyricAlignment.end: '右对齐',
      };

  List<Widget> _anchor({required bool selection}) {
    final String label = selection ? '选择句' : '当前句';
    final String key = selection ? 'lyricSelectionAnchor' : 'lyricActiveAnchor';
    final PlayerLyricAnchorUnit unit = selection
        ? _draft.selectionAnchorUnit
        : _draft.activeAnchorUnit;
    final double position = selection
        ? _draft.selectionAnchorPosition
        : _draft.activeAnchorPosition;
    final PlayerLyricAnchorTarget target = selection
        ? _draft.selectionAnchorTarget
        : _draft.activeAnchorTarget;
    return <Widget>[
      _choice<PlayerLyricAnchorUnit>(
        '${key}Unit',
        '$label定位方式',
        unit,
        const <PlayerLyricAnchorUnit, String>{
          PlayerLyricAnchorUnit.fraction: '按区域高度',
          PlayerLyricAnchorUnit.pixels: '距顶部像素',
        },
        (PlayerLyricAnchorUnit v) {
          final double resetPosition = v == PlayerLyricAnchorUnit.fraction
              ? 0.5
              : 160;
          return selection
              ? _draft.copyWith(
                  selectionAnchorUnit: v,
                  selectionAnchorPosition: resetPosition,
                )
              : _draft.copyWith(
                  activeAnchorUnit: v,
                  activeAnchorPosition: resetPosition,
                );
        },
      ),
      _slider(
        '${key}Position',
        '$label位置',
        position,
        0,
        unit == PlayerLyricAnchorUnit.fraction ? 1 : 600,
        (double v) => selection
            ? _draft.copyWith(selectionAnchorPosition: v)
            : _draft.copyWith(activeAnchorPosition: v),
        percent: unit == PlayerLyricAnchorUnit.fraction,
      ),
      _choice<PlayerLyricAnchorTarget>(
        '${key}Target',
        '$label对齐基准',
        target,
        const <PlayerLyricAnchorTarget, String>{
          PlayerLyricAnchorTarget.mainText: '正文中心',
          PlayerLyricAnchorTarget.translationText: '译文中心',
          PlayerLyricAnchorTarget.lineCenter: '含译文的整体中心',
        },
        (PlayerLyricAnchorTarget v) => selection
            ? _draft.copyWith(selectionAnchorTarget: v)
            : _draft.copyWith(activeAnchorTarget: v),
      ),
    ];
  }

  List<Widget> _effects() => <Widget>[
    _choice<PlayerLyricColorMode>(
      'lyricColorMode',
      '高亮配色',
      _draft.colorMode,
      const <PlayerLyricColorMode, String>{
        PlayerLyricColorMode.cover: '跟随封面',
        PlayerLyricColorMode.theme: '跟随主题',
        PlayerLyricColorMode.custom: '自定义颜色',
      },
      (PlayerLyricColorMode v) => _draft.copyWith(colorMode: v),
    ),
    if (_draft.colorMode == PlayerLyricColorMode.custom)
      _LyricColorEditor(
        color: _draft.customColor,
        enabled: !_saving,
        label: '颜色值',
        applyTooltip: '应用颜色',
        onChanged: (int v) => _apply(_draft.copyWith(customColor: v)),
      ),
    _choice<PlayerLyricMotion>(
      'lyricMotion',
      '歌词动效',
      _draft.motion,
      const <PlayerLyricMotion, String>{
        PlayerLyricMotion.full: '完整（当前效果）',
        PlayerLyricMotion.reduced: '减弱（仅平滑滚动）',
        PlayerLyricMotion.off: '关闭',
      },
      (PlayerLyricMotion v) => _draft.copyWith(motion: v),
    ),
  ];

  Widget _section(String title, [String? description]) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        if (description != null) ...<Widget>[
          const SizedBox(height: 4),
          _note(description),
        ],
      ],
    ),
  );

  Widget _note(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text, style: Theme.of(context).textTheme.bodySmall),
  );

  Widget _slider(
    String key,
    String label,
    double value,
    double min,
    double max,
    PlayerLyricSettings Function(double) change, {
    bool percent = false,
    String? display,
  }) {
    String format(double v) =>
        percent ? '${(v * 100).round()}%' : '${v.round()} px';
    final String formatted = display ?? format(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('$label · $formatted'),
        Semantics(
          label: label,
          child: Slider(
            key: Key(key),
            value: value.clamp(min, max),
            min: min,
            max: max,
            label: formatted,
            semanticFormatterCallback: key == 'lyricFontScale'
                ? (double v) => '${(v * 30).round()} px'
                : format,
            onChanged: _saving
                ? null
                : (double v) => setState(() => _draft = change(v)),
            onChangeEnd: _saving ? null : (_) => _apply(_draft),
          ),
        ),
      ],
    );
  }

  Widget _choice<T>(
    String key,
    String label,
    T value,
    Map<T, String> choices,
    PlayerLyricSettings Function(T) change,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: InputDecorator(
      decoration: InputDecoration(labelText: label, enabled: !_saving),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          key: Key(key),
          value: value,
          isExpanded: true,
          isDense: true,
          items: <DropdownMenuItem<T>>[
            for (final MapEntry<T, String> entry in choices.entries)
              DropdownMenuItem<T>(value: entry.key, child: Text(entry.value)),
          ],
          onChanged: _saving
              ? null
              : (T? v) {
                  if (v != null) _apply(change(v));
                },
        ),
      ),
    ),
  );
}

class _LyricColorEditor extends StatefulWidget {
  const _LyricColorEditor({
    required this.color,
    required this.enabled,
    required this.label,
    required this.applyTooltip,
    required this.onChanged,
  });
  final int color;
  final bool enabled;
  final String label;
  final String applyTooltip;
  final ValueChanged<int> onChanged;
  @override
  State<_LyricColorEditor> createState() => _LyricColorEditorState();
}

class _LyricColorEditorState extends State<_LyricColorEditor> {
  late final TextEditingController _controller;
  final GlobalKey<FormFieldState<String>> _field =
      GlobalKey<FormFieldState<String>>();
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _hexColor(widget.color));
  }

  @override
  void didUpdateWidget(covariant _LyricColorEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color ||
        oldWidget.enabled != widget.enabled) {
      _controller.text = _hexColor(widget.color);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply() {
    if (_field.currentState?.validate() != true) return;
    final String hex = _controller.text.trim().replaceFirst('#', '');
    widget.onChanged(0xff000000 | int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final (String label, int color) in const <(String, int)>[
              ('玫红', 0xffe91e63),
              ('橙色', 0xffff9800),
              ('绿色', 0xff4caf50),
              ('蓝色', 0xff2196f3),
              ('紫色', 0xff9c27b0),
              ('白色', 0xffffffff),
              ('黑色', 0xff000000),
            ])
              Semantics(
                selected: widget.color == color,
                child: IconButton.outlined(
                  tooltip: label,
                  onPressed: widget.enabled
                      ? () => widget.onChanged(color)
                      : null,
                  style: IconButton.styleFrom(backgroundColor: Color(color)),
                  icon: Icon(
                    widget.color == color ? Icons.check_rounded : Icons.circle,
                    color: widget.color == color
                        ? (Color(color).computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white)
                        : Colors.transparent,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: _field,
          controller: _controller,
          enabled: widget.enabled,
          maxLength: 7,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: '#RRGGBB',
            counterText: '',
            suffixIcon: IconButton(
              tooltip: widget.applyTooltip,
              onPressed: widget.enabled ? _apply : null,
              icon: const Icon(Icons.check_rounded),
            ),
          ),
          validator: (String? value) =>
              RegExp(r'^#?[0-9a-fA-F]{6}$').hasMatch(value?.trim() ?? '')
              ? null
              : '请输入六位十六进制颜色，如 #E91E63',
          onFieldSubmitted: (_) => _apply(),
        ),
      ],
    ),
  );
  static String _hexColor(int color) =>
      '#${(color & 0x00ffffff).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
