import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  const UserCard({super.key, this.name = '用户名', this.avatarImage});

  final String name;
  final ImageProvider<Object>? avatarImage;

  @override
  Widget build(BuildContext context) {
    final Color themeColor = Theme.of(context).colorScheme.primary;
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            backgroundImage: avatarImage,
            child: avatarImage == null
                ? Icon(Icons.person, size: 24, color: themeColor)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
