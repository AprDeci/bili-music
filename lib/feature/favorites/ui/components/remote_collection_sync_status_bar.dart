import 'package:flutter/material.dart';

enum RemoteCollectionSyncStatus { syncing, success, failure }

class RemoteCollectionSyncStatusBar extends StatelessWidget {
  const RemoteCollectionSyncStatusBar({super.key, required this.status});

  final RemoteCollectionSyncStatus? status;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool isSyncing = status == RemoteCollectionSyncStatus.syncing;
    final bool isSuccess = status == RemoteCollectionSyncStatus.success;
    final bool isFailure = status == RemoteCollectionSyncStatus.failure;

    return AnimatedSize(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutBack,
        opacity: status == null ? 0 : 1,
        child: status == null
            ? const SizedBox.shrink()
            : Container(
                width: double.infinity,
                color: isSyncing
                    ? colors.surfaceContainerHighest
                    : isSuccess
                    ? colors.secondaryContainer
                    : colors.tertiaryContainer,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  reverseDuration: const Duration(milliseconds: 180),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                        );
                      },
                  child: Row(
                    key: ValueKey<RemoteCollectionSyncStatus>(status!),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (isSyncing)
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.onSurfaceVariant,
                          ),
                        )
                      else
                        Icon(
                          isFailure
                              ? Icons.warning_amber_rounded
                              : Icons.check_rounded,
                          size: 16,
                          color: isFailure
                              ? colors.onTertiaryContainer
                              : colors.onSecondaryContainer,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        isSyncing
                            ? '同步中...'
                            : isFailure
                            ? '同步失败，已使用本地数据'
                            : '同步完成',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isFailure
                              ? colors.onTertiaryContainer
                              : isSyncing
                              ? colors.onSurfaceVariant
                              : colors.onSecondaryContainer,
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
