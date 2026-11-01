import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class CollectionKindIcon extends StatelessWidget {
  const CollectionKindIcon({
    super.key,
    required this.kind,
    this.size = 20,
    this.color,
  });

  final CollectionKind kind;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: HugeIcon(
        icon: switch (kind) {
          CollectionKind.music => HugeIcons.strokeRoundedMusicNote02,
          CollectionKind.spoken => HugeIcons.strokeRoundedHeadphones,
        },
        size: size,
        color: color,
        strokeWidth: 1.8,
      ),
    );
  }
}

class CollectionKindTag extends StatelessWidget {
  const CollectionKindTag({super.key, required this.kind});

  final CollectionKind kind;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Semantics(
      label: '歌单类型：${kind.label}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CollectionKindIcon(
              kind: kind,
              size: 14,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              kind.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
