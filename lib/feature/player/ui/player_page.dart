import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_main_page.dart';
import 'package:bilimusic/feature/player/ui/components/player_meta_page.dart';
import 'package:bilimusic/feature/player/ui/components/player_shared.dart';
import 'package:bilimusic/feature/player/ui/components/player_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerPage extends ConsumerStatefulWidget {
  const PlayerPage({super.key, this.initialItem});

  final PlayableItem? initialItem;

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage> {
  late final PageController _pageController;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialItem();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PlayerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialItem != widget.initialItem) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadInitialItem();
      });
    }
  }

  void _loadInitialItem() {
    final PlayableItem? item = widget.initialItem;
    if (item == null) {
      return;
    }
    ref.read(playerControllerProvider.notifier).loadFromItem(item);
  }

  @override
  Widget build(BuildContext context) {
    final PlayerState state = ref.watch(playerControllerProvider);
    final PlayerController playerController = ref.read(
      playerControllerProvider.notifier,
    );
    final PlayableItem? item = state.currentItem ?? widget.initialItem;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              colorScheme.surface,
              colorScheme.primary.withValues(alpha: 0.08),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: <Widget>[
            const Positioned(top: -120, left: -90, child: PlayerBackdropOrb()),
            const Positioned(
              right: -70,
              top: 180,
              child: PlayerBackdropOrb(size: 220, opacity: 0.35),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      children: <Widget>[
                        PlayerTopBar(
                          currentPage: _currentPage,
                          onBack: () => Navigator.of(context).maybePop(),
                          onMore: item == null
                              ? null
                              : () => playerController.loadFromItem(item),
                        ),
                        const SizedBox(height: 18),
                        Expanded(
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: (int index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            children: <Widget>[
                              PlayerMetaPage(state: state, item: item),
                              PlayerMainPage(
                                state: state,
                                item: item,
                                onSeek: (double value) {
                                  final int totalMs =
                                      (state.duration ?? Duration.zero)
                                          .inMilliseconds;
                                  final Duration position = Duration(
                                    milliseconds: (totalMs * value).round(),
                                  );
                                  playerController.seek(position);
                                },
                                onBackward: () => playerController.seekBy(
                                  const Duration(seconds: -10),
                                ),
                                onTogglePlayback:
                                    playerController.togglePlayback,
                                onForward: () => playerController.seekBy(
                                  const Duration(seconds: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
