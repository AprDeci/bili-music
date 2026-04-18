import 'package:bilimusic/common/util/color_util.dart';
import 'package:bilimusic/common/util/format_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/cache/cache_util.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CacheSettingsPage extends StatefulWidget {
  const CacheSettingsPage({super.key});

  @override
  State<CacheSettingsPage> createState() => _CacheSettingsPageState();
}

class _CacheSettingsPageState extends State<CacheSettingsPage>
    with SingleTickerProviderStateMixin {
  int _imageCacheBytes = 0;
  int _audioCacheBytes = 0;
  bool _imageSelected = true;
  bool _audioSelected = true;
  bool _isLoading = true;
  bool _isClearing = false;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _loadCacheSizes();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _totalCacheBytes => _imageCacheBytes + _audioCacheBytes;

  int get _selectedCacheBytes {
    int total = 0;
    if (_imageSelected) {
      total += _imageCacheBytes;
    }
    if (_audioSelected) {
      total += _audioCacheBytes;
    }
    return total;
  }

  bool get _hasSelectedCache => _selectedCacheBytes > 0;

  Future<void> _loadCacheSizes() async {
    final List<int> sizes = await Future.wait<int>(<Future<int>>[
      CacheUtil.getImageCacheSizeBytes(),
      CacheUtil.getAudioCacheSizeBytes(),
    ]);

    if (!mounted) {
      return;
    }

    setState(() {
      _imageCacheBytes = sizes[0];
      _audioCacheBytes = sizes[1];
      _isLoading = false;
    });
  }

  Future<void> _toggleAndClearSelected() async {
    if (!_hasSelectedCache || _isClearing) {
      return;
    }

    final bool shouldClear =
        await _showClearCacheDialog(
          context,
          cacheSizeLabel: formatBytes(_selectedCacheBytes),
        ) ??
        false;
    if (!shouldClear) {
      return;
    }

    setState(() {
      _isClearing = true;
    });

    try {
      final List<Future<void>> tasks = <Future<void>>[];
      if (_imageSelected) {
        tasks.add(CacheUtil.clearImageCache());
      }
      if (_audioSelected) {
        tasks.add(CacheUtil.clearAudioCache());
      }

      await Future.wait<void>(tasks);
      await _loadCacheSizes();

      if (mounted && _totalCacheBytes <= 0) {
        _controller.forward(from: 0.0);
      }

      if (!mounted) {
        return;
      }

      ToastUtil.show('所选缓存已清理');
    } finally {
      if (mounted) {
        setState(() {
          _isClearing = false;
        });
      }
    }
  }

  void _toggleImageSelected() {
    setState(() {
      _imageSelected = !_imageSelected;
    });
  }

  void _toggleAudioSelected() {
    setState(() {
      _audioSelected = !_audioSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('缓存设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.2,
            child: _totalCacheBytes > 0
                ? PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: [
                        PieChartSectionData(
                          title: _imageCacheBytes > 0
                              ? '图片 ${(_imageCacheBytes / _totalCacheBytes * 100).toStringAsFixed(0)}%'
                              : null,
                          value: _imageSelected
                              ? (_imageCacheBytes / _totalCacheBytes * 100)
                                    .toDouble()
                              : 0,
                          titleStyle: TextStyle(color: Colors.white),
                          color: ColorUtil.getAnalogous(
                            theme.colorScheme.primary,
                          )[4],
                          radius: 45,
                        ),
                        PieChartSectionData(
                          title: _audioCacheBytes > 0
                              ? '音频 ${(_audioCacheBytes / _totalCacheBytes * 100).toStringAsFixed(0)}%'
                              : null,
                          value: _audioSelected
                              ? (_audioCacheBytes / _totalCacheBytes * 100)
                                    .toDouble()
                              : 0,
                          color: ColorUtil.getShade(
                            theme.colorScheme.primary,
                            400,
                          ),
                          titleStyle: TextStyle(color: Colors.white),
                          radius: 45,
                        ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: -60,
                        child: Lottie.asset(
                          'assets/lottie/Done.json',
                          width: 360,
                          height: 240,
                          fit: BoxFit.fitWidth,
                          controller: _controller,
                          repeat: false,
                          onLoaded: (composition) {
                            _controller
                              ..duration = composition.duration
                              ..forward(); // 加载完立即播放一次
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 24,
                        child: Text(
                          '缓存已清理',
                          style: TextStyle(
                            color:
                                theme.textTheme.bodyMedium?.color ??
                                Colors.grey,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          Container(
            margin: EdgeInsets.zero,
            child: Column(
              children: <Widget>[
                _CacheCategoryTile(
                  icon: Icons.image_outlined,
                  title: '图片',
                  valueLabel: formatBytes(_imageCacheBytes),
                  selected: _imageSelected,
                  enabled: !_isLoading && !_isClearing,
                  onTap: _toggleImageSelected,
                ),
                const Divider(height: 1),
                _CacheCategoryTile(
                  icon: Icons.audiotrack_outlined,
                  title: '音频',
                  valueLabel: formatBytes(_audioCacheBytes),
                  selected: _audioSelected,
                  enabled: !_isLoading && !_isClearing,
                  onTap: _toggleAudioSelected,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _hasSelectedCache && !_isLoading && !_isClearing
                ? _toggleAndClearSelected
                : null,
            child: _isClearing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('清空所选缓存 ${formatBytes(_selectedCacheBytes)}'),
          ),
          if (kDebugMode)
            Column(
              children: [
                Row(
                  children: [
                    // Play backward
                    IconButton(
                      icon: const Icon(Icons.arrow_left),
                      onPressed: () {
                        _controller.reverse();
                      },
                    ),
                    // Pause
                    IconButton(
                      icon: const Icon(Icons.pause),
                      onPressed: () {
                        _controller.stop();
                      },
                    ),
                    // Play forward
                    IconButton(
                      icon: const Icon(Icons.arrow_right),
                      onPressed: () {
                        _controller.forward();
                      },
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CacheCategoryTile extends StatelessWidget {
  const _CacheCategoryTile({
    required this.icon,
    required this.title,
    required this.valueLabel,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String valueLabel;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      enabled: enabled,
      leading: Icon(icon),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(valueLabel, style: theme.textTheme.bodyMedium),
          const SizedBox(width: 12),
          Checkbox(value: selected, onChanged: enabled ? (_) => onTap() : null),
        ],
      ),
      onTap: enabled ? onTap : null,
    );
  }
}

Future<bool?> _showClearCacheDialog(
  BuildContext context, {
  required String cacheSizeLabel,
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('确认清空所选缓存吗？'),
        content: Text('将清理 $cacheSizeLabel 的图片与音频缓存，后续使用时会重新下载。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      );
    },
  );
}
