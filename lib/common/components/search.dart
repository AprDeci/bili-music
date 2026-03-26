import 'package:flutter/material.dart';

class CommonSearchBar extends StatelessWidget {
  const CommonSearchBar({
    super.key,
    this.onTap,
    this.hintText = '',
    this.margin,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  });

  final VoidCallback? onTap;
  final String hintText;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFD8E2EC)),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.search_rounded,
                  size: 16,
                  color: Color(0xFF5B6F82),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hintText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF7D8C9B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
