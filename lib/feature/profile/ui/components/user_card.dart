import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/common/components/cached_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UserCard extends ConsumerWidget {
  const UserCard({super.key, this.onLogoutPressed});

  final VoidCallback? onLogoutPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final BiliSession? session = ref.watch(biliSessionControllerProvider);
    final bool isLoggedIn = session?.isLoggedIn ?? false;
    final ColorScheme colorScheme = theme.colorScheme;
    final Color themeColor = colorScheme.primary;
    final String? face = session?.face;
    final String? uname = session?.uname;
    final int? mid = session?.mid;
    final String title = isLoggedIn
        ? (uname?.isNotEmpty == true ? uname! : '已登录 B 站账号')
        : '点击登录';
    final String subtitle = isLoggedIn ? 'mid: ${mid ?? '-'}' : '扫码同步 B 站账号信息';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isLoggedIn ? null : () => context.push('/auth'),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CommonCachedAvatar(
                imageUrl: isLoggedIn ? face : null,
                radius: 24,
                backgroundColor: const Color(0xFFF2F6FA),
                fallbackIcon: Icons.person,
                iconColor: themeColor,
                iconSize: 24,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              if (isLoggedIn)
                TextButton(
                  onPressed: onLogoutPressed,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(36, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: themeColor,
                  ),
                )
              else
                Icon(Icons.chevron_right_rounded, color: themeColor),
            ],
          ),
        ),
      ),
    );
  }
}
