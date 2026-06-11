import 'package:bilimusic/common/components/user_avatar.dart';
import 'package:bilimusic/common/util/format_util.dart';
import 'package:bilimusic/feature/up/domain/up_profile.dart';
import 'package:flutter/material.dart';

class UpProfileHeader extends StatelessWidget {
  const UpProfileHeader({super.key, required this.profile, this.error});

  final UpProfile? profile;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final UpProfile? value = profile;

    if (value == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Row(
          children: <Widget>[
            const CircleAvatar(radius: 34, child: Icon(Icons.person_rounded)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                error ?? 'UP信息加载中',
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: <Widget>[
          UserAvatar(
            avatarUrl: value.avatarUrl,
            radius: 36,
            tipSize: 16,
            officialType: value.officialType,
            useCache: true,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  value.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${formatCompactCount(value.followerCount)} 粉丝',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
