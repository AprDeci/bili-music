import 'package:flutter/material.dart';

class FavoriteSearchEmptyState extends StatelessWidget {
  const FavoriteSearchEmptyState({super.key, required this.onSearchOnline});

  final VoidCallback onSearchOnline;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.search_off_rounded, size: 42, color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            '没有结果？前往在线搜索试试',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          TextButton.icon(onPressed: onSearchOnline, label: const Text('搜索')),
        ],
      ),
    );
  }
}
