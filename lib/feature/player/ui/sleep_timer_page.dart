import 'dart:async';

import 'package:bilimusic/feature/player/logic/sleep_timer_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const List<_FixedSleepOption> _fixedSleepOptions = <_FixedSleepOption>[
  _FixedSleepOption(
    label: '不开启',
    duration: null,
    selectionType: _SleepTimerSelectionType.off,
  ),
  _FixedSleepOption(
    label: '15分钟',
    duration: Duration(minutes: 15),
    selectionType: _SleepTimerSelectionType.minutes15,
  ),
  _FixedSleepOption(
    label: '30分钟',
    duration: Duration(minutes: 30),
    selectionType: _SleepTimerSelectionType.minutes30,
  ),
  _FixedSleepOption(
    label: '60分钟',
    duration: Duration(minutes: 60),
    selectionType: _SleepTimerSelectionType.minutes60,
  ),
  _FixedSleepOption(
    label: '90分钟',
    duration: Duration(minutes: 90),
    selectionType: _SleepTimerSelectionType.minutes90,
  ),
  _FixedSleepOption(
    label: '自定义',
    duration: _customDurationSentinel,
    selectionType: _SleepTimerSelectionType.custom,
  ),
];

const Duration _customDurationSentinel = Duration(days: -1);

class SleepTimerPage extends ConsumerStatefulWidget {
  const SleepTimerPage({super.key});

  @override
  ConsumerState<SleepTimerPage> createState() => _SleepTimerPageState();
}

class _SleepTimerPageState extends ConsumerState<SleepTimerPage> {
  ProviderSubscription<SleepTimerState>? _sleepTimerSubscription;
  Timer? _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _syncTicker(ref.read(sleepTimerControllerProvider));
    _sleepTimerSubscription = ref.listenManual<SleepTimerState>(
      sleepTimerControllerProvider,
      (_, SleepTimerState next) {
        _syncTicker(next);
      },
    );
  }

  @override
  void dispose() {
    _sleepTimerSubscription?.close();
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final SleepTimerState sleepTimerState = ref.watch(
      sleepTimerControllerProvider,
    );
    final Duration remaining = _remainingDuration(sleepTimerState);
    final _SleepTimerSelectionType selection = _deriveSelection(
      sleepTimerState,
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text('定时关闭'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: <Widget>[
            _SectionTitle(title: '倒计时'),
            const SizedBox(height: 12),
            _CountdownCard(
              displayText: sleepTimerState.isActive
                  ? _formatDuration(remaining)
                  : '未开启',
              isActive: sleepTimerState.isActive,
            ),
            const SizedBox(height: 28),
            const _SectionTitle(title: '选择定时'),
            const SizedBox(height: 12),
            _OptionsCard(
              selectedType: selection,
              onOptionTap: (Duration? duration) {
                _handleOptionTap(context, duration);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _syncTicker(SleepTimerState state) {
    if (!state.isActive || state.expiresAt == null) {
      _ticker?.cancel();
      _ticker = null;
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
      return;
    }

    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _now = DateTime.now();
      });
    });

    if (mounted) {
      setState(() {
        _now = DateTime.now();
      });
    }
  }

  Duration _remainingDuration(SleepTimerState state) {
    final DateTime? expiresAt = state.expiresAt;
    if (!state.isActive || expiresAt == null) {
      return Duration.zero;
    }

    final Duration remaining = expiresAt.difference(_now);
    if (remaining.isNegative) {
      return Duration.zero;
    }
    return remaining;
  }

  Future<void> _handleOptionTap(
    BuildContext context,
    Duration? duration,
  ) async {
    if (duration == null) {
      ref.read(sleepTimerControllerProvider.notifier).cancel();
      return;
    }

    if (duration == _customDurationSentinel) {
      final Duration? customDuration = await showSleepTimerPickerSheet(context);
      if (!mounted || customDuration == null) {
        return;
      }
      if (customDuration > Duration.zero) {
        ref.read(sleepTimerControllerProvider.notifier).start(customDuration);
      } else {
        ref.read(sleepTimerControllerProvider.notifier).cancel();
      }
      return;
    }

    ref.read(sleepTimerControllerProvider.notifier).start(duration);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CountdownCard extends StatelessWidget {
  const _CountdownCard({required this.displayText, required this.isActive});

  final String displayText;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('剩余时间', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 14),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              style: theme.textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: isActive
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
              ),
              child: Text(displayText),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionsCard extends StatelessWidget {
  const _OptionsCard({required this.selectedType, required this.onOptionTap});

  final _SleepTimerSelectionType selectedType;
  final ValueChanged<Duration?> onOptionTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Column(
        children: List<Widget>.generate(_fixedSleepOptions.length, (int index) {
          final _FixedSleepOption option = _fixedSleepOptions[index];
          final bool isSelected = option.selectionType == selectedType;
          final bool isLast = index == _fixedSleepOptions.length - 1;
          return Column(
            children: <Widget>[
              _OptionTile(
                label: option.label,
                isSelected: isSelected,
                onTap: () => onOptionTap(option.duration),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 18,
                  endIndent: 18,
                  color: theme.colorScheme.outlineVariant,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  width: 1.6,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

Future<Duration?> showSleepTimerPickerSheet(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  int selectedHours = 0;
  int selectedMinutes = 30;

  return showModalBottomSheet<Duration>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return SafeArea(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const SizedBox(width: 48),
                        const Expanded(
                          child: Center(
                            child: Text(
                              '自定义时间',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(
                              Duration(
                                hours: selectedHours,
                                minutes: selectedMinutes,
                              ),
                            );
                          },
                          child: const Text('确定'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 220,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: _PickerColumn(
                              label: '小时',
                              child: CupertinoPicker(
                                itemExtent: 42,
                                scrollController: FixedExtentScrollController(
                                  initialItem: selectedHours,
                                ),
                                onSelectedItemChanged: (int value) {
                                  setModalState(() {
                                    selectedHours = value;
                                  });
                                },
                                children: List<Widget>.generate(24, (
                                  int index,
                                ) {
                                  return Center(child: Text('$index'));
                                }),
                              ),
                            ),
                          ),
                          Expanded(
                            child: _PickerColumn(
                              label: '分钟',
                              child: CupertinoPicker(
                                itemExtent: 42,
                                scrollController: FixedExtentScrollController(
                                  initialItem: selectedMinutes,
                                ),
                                onSelectedItemChanged: (int value) {
                                  setModalState(() {
                                    selectedMinutes = value;
                                  });
                                },
                                children: List<Widget>.generate(60, (
                                  int index,
                                ) {
                                  return Center(
                                    child: Text(
                                      index.toString().padLeft(2, '0'),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class _PickerColumn extends StatelessWidget {
  const _PickerColumn({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      children: <Widget>[
        Text(label, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 10),
        Expanded(child: child),
      ],
    );
  }
}

_SleepTimerSelectionType _deriveSelection(SleepTimerState state) {
  final Duration? selectedDuration = state.duration;
  if (!state.isActive || state.expiresAt == null || selectedDuration == null) {
    return _SleepTimerSelectionType.off;
  }

  for (final _FixedSleepOption option in _fixedSleepOptions) {
    final Duration? duration = option.duration;
    if (duration == null || duration == _customDurationSentinel) {
      continue;
    }
    if (duration == selectedDuration) {
      return option.selectionType;
    }
  }

  return _SleepTimerSelectionType.custom;
}

String _formatDuration(Duration duration) {
  final Duration safeDuration = duration.isNegative ? Duration.zero : duration;
  final int hours = safeDuration.inHours;
  final int minutes = safeDuration.inMinutes.remainder(60);
  final int seconds = safeDuration.inSeconds.remainder(60);
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

class _FixedSleepOption {
  const _FixedSleepOption({
    required this.label,
    required this.duration,
    required this.selectionType,
  });

  final String label;
  final Duration? duration;
  final _SleepTimerSelectionType selectionType;
}

enum _SleepTimerSelectionType {
  off,
  minutes15,
  minutes30,
  minutes60,
  minutes90,
  custom,
}
