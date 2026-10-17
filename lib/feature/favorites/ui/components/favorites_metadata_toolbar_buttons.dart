import 'dart:async';

import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_view_mode_logic.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_backfill_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_backfill_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

const String _metadataScanTag = 'favorites_metadata_scan';
const double _scanPopupWidth = 268;
const double _scanArrowWidth = 16;
const double _scanArrowHeight = 8;

class MetadataViewModeButton extends StatelessWidget {
  const MetadataViewModeButton({
    super.key,
    required this.viewMode,
    required this.onPressed,
  });

  final FavoriteListViewMode viewMode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bool isMetadata = viewMode == FavoriteListViewMode.metadata;
    return Tooltip(
      message: isMetadata ? '切换到视频视图' : '切换到元信息视图',
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        icon: Icon(isMetadata ? Icons.music_note_rounded : Icons.album_rounded),
      ),
    );
  }
}

class MetadataBackfillButton extends ConsumerWidget {
  const MetadataBackfillButton({super.key, required this.entries});

  final List<FavoriteEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MetadataBackfillState state = ref.watch(
      metadataBackfillControllerProvider,
    );

    return Builder(
      builder: (BuildContext buttonContext) {
        if (state.isRunning) {
          return Tooltip(
            message: '点击停止补齐',
            child: SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                onPressed: () => _cancel(ref),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                icon: const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          );
        }
        return Tooltip(
          message: '补齐/检测元数据',
          child: IconButton(
            onPressed: () => _start(buttonContext, ref),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            icon: const Icon(Icons.auto_fix_high_rounded),
          ),
        );
      },
    );
  }

  void _cancel(WidgetRef ref) {
    ref.read(metadataBackfillControllerProvider.notifier).cancel();
    unawaited(SmartDialog.dismiss<void>(tag: _metadataScanTag));
  }

  void _start(BuildContext buttonContext, WidgetRef ref) {
    final MetadataBackfillController controller = ref.read(
      metadataBackfillControllerProvider.notifier,
    );
    unawaited(
      controller.backfillMissing(
        entries.map((FavoriteEntry entry) => entry.toPlayableItem()),
      ),
    );
    if (buttonContext.mounted) {
      _showScanPopup(buttonContext, entries.length);
    }
  }

  void _showScanPopup(BuildContext targetContext, int foundCount) {
    unawaited(SmartDialog.dismiss<void>(tag: _metadataScanTag));
    unawaited(
      SmartDialog.showAttach<void>(
        tag: _metadataScanTag,
        targetContext: targetContext,
        maskColor: Colors.transparent,
        alignment: Alignment.bottomCenter,
        animationType: SmartAnimationType.scale,
        keepSingle: true,
        clickMaskDismiss: true,
        scalePointBuilder: (Size selfSize) {
          return Offset(selfSize.width / 2, 0);
        },
        adjustBuilder: (AttachParam attachParam) {
          return AttachAdjustParam(
            builder: (_) => Padding(
              padding: const EdgeInsets.only(top: 2),
              child: MetadataScanPopup(
                foundCount: foundCount,
                arrowCenterX: _arrowCenterX(attachParam),
              ),
            ),
          );
        },
        builder: (_) => MetadataScanPopup(foundCount: foundCount),
      ),
    );
  }

  // 用目标按钮与弹窗的全局坐标算出箭头中心，使箭头正好对准按钮中心。
  double _arrowCenterX(AttachParam param) {
    final double popupWidth = param.selfSize.width;
    if (popupWidth <= 0) {
      return _scanPopupWidth / 2;
    }
    final double targetCenterX =
        param.targetOffset.dx + param.targetSize.width / 2;
    final double localX = targetCenterX - param.selfOffset.dx;
    final double minX = _scanArrowWidth / 2;
    final double maxX = popupWidth - _scanArrowWidth / 2;
    return localX.clamp(minX, maxX);
  }
}

class MetadataScanPopup extends ConsumerWidget {
  const MetadataScanPopup({
    super.key,
    required this.foundCount,
    this.arrowCenterX,
  });

  final int foundCount;
  final double? arrowCenterX;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MetadataBackfillState state = ref.watch(
      metadataBackfillControllerProvider,
    );

    final int pending = (state.total - state.processed).clamp(0, state.total);
    final String title = state.isRunning ? '正在扫描' : '扫描完成';

    return _ArrowBubble(
      color: colorScheme.primary,
      arrowCenterX: arrowCenterX ?? _scanPopupWidth / 2,
      child: SizedBox(
        width: _scanPopupWidth,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 8, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => unawaited(
                      SmartDialog.dismiss<void>(tag: _metadataScanTag),
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints.tightFor(
                      width: 28,
                      height: 28,
                    ),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.onPrimary,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '已找到 $foundCount，待更新 $pending，已更新 ${state.matched}',
                style: TextStyle(
                  color: colorScheme.onPrimary.withValues(alpha: 0.92),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 带朝上小箭头的气泡，箭头中心由调用方按目标按钮算出。
class _ArrowBubble extends StatelessWidget {
  const _ArrowBubble({
    required this.color,
    required this.arrowCenterX,
    required this.child,
  });

  static const double _radius = 12;

  final Color color;
  final double arrowCenterX;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topLeft,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: _scanArrowHeight),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(_radius),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.24),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        ),
        Positioned(
          top: 0,
          left: (arrowCenterX - _scanArrowWidth / 2).clamp(
            0.0,
            double.infinity,
          ),
          child: CustomPaint(
            size: const Size(_scanArrowWidth, _scanArrowHeight),
            painter: _ArrowUpPainter(color: color),
          ),
        ),
      ],
    );
  }
}

class _ArrowUpPainter extends CustomPainter {
  const _ArrowUpPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final Path path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArrowUpPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
