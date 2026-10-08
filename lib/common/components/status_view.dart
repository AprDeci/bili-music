import 'package:flutter/material.dart';

// 全站统一的状态块（空态/错误/未登录）。样式在这里定死，调用点不要再调尺寸、
// 间距、颜色，否则又会长出 20 种不同的空态。
class StatusView extends StatelessWidget {
  const StatusView({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.iconColor,
    this.onRetry,
    this.retryLabel = '重试',
    this.isRetrying = false,
    this.actions = const <Widget>[],
  });

  static const double _iconBoxSize = 72;
  static const double _iconSize = 32;

  final String title;
  final String? description;
  final IconData? icon;

  // 错误态传 colorScheme.error，其余用主题主色
  final Color? iconColor;

  // 最常见的动作，单独留参数省得到处拼按钮
  final VoidCallback? onRetry;
  final String retryLabel;
  final bool isRetrying;

  // 其余按钮：去登录、在线搜索等
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String? description = this.description;
    final Color tint = iconColor ?? colorScheme.primary;
    final bool hasAction = onRetry != null || actions.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Container(
                width: _iconBoxSize,
                height: _iconBoxSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tint.withValues(alpha: 0.12),
                ),
                child: Icon(icon, size: _iconSize, color: tint),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            if (description != null && description.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
            if (hasAction) ...<Widget>[
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  if (onRetry != null)
                    FilledButton.tonal(
                      onPressed: isRetrying ? null : onRetry,
                      child: Text(isRetrying ? '重试中' : retryLabel),
                    ),
                  ...actions,
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 滚动列表里用：撑满剩余空间，保证空态和整页空态一样居中
class SliverStatusView extends StatelessWidget {
  const SliverStatusView({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(hasScrollBody: false, child: child);
  }
}
