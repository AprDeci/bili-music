import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UserCard extends ConsumerWidget {
  const UserCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BiliSession? session = ref.watch(biliSessionControllerProvider);
    final bool isLoggedIn = session?.isLoggedIn ?? false;
    final Color themeColor = Theme.of(context).colorScheme.primary;
    final String? face = session?.face;
    final String? uname = session?.uname;
    final int? mid = session?.mid;
    final ImageProvider<Object>? avatarImage =
        isLoggedIn && face != null && face.isNotEmpty
        ? NetworkImage(face)
        : null;
    final String title = isLoggedIn
        ? (uname?.isNotEmpty == true ? uname! : '已登录 B 站账号')
        : '点击登录';
    final String subtitle = isLoggedIn
        ? 'mid: ${mid ?? '-'}'
        : '扫码同步 B 站账号信息';

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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFF2F6FA),
                backgroundImage: avatarImage,
                child: avatarImage == null
                    ? Icon(Icons.person, size: 24, color: themeColor)
                    : null,
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),

              if (!isLoggedIn)
                Icon(Icons.chevron_right_rounded, color: themeColor),
            ],
          ),
        ),
      ),
    );
  }
}
