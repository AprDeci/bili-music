import 'dart:async';

import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/core/hive/hive.dart';
import 'package:bilimusic/core/theme/desktop_chinese_font.dart';
import 'package:bilimusic/core/window/desktop_app_lifecycle.dart';
import 'package:bilimusic/core/window/desktop_hotkey_controller.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/player/logic/app_audio_handler.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/desktop_lyrics_window_app.dart';
import 'package:bilimusic/feature/setting/logic/clipboard_sync_controller.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:bilimusic/myApp.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:media_kit/media_kit.dart';

Future<DesktopAppLifecycle?> bootstrap(ProviderContainer container) async {
  MediaKit.ensureInitialized();
  await PlayerAudioService.initialize();
  if (PlatformUtil.isMobile) {
    await LiquidGlassWidgets.initialize();
  }
  await initHive();
  SmartDialog.config.attach = SmartConfigAttach(
    useAnimation: false,
    usePenetrate: false,
  );

  if (PlatformUtil.isDesktop) {
    return DesktopAppLifecycle.initialize(container);
  }
  return null;
}

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (_isDesktopLyricsWindow(args)) {
    await DesktopChineseFont.load();
    runApp(
      DesktopLyricsWindowApp(
        windowController: WindowController.fromWindowId(int.parse(args[1])),
        initialPayload: parseDesktopLyricsInitialPayload(args[2]),
      ),
    );
    return;
  }

  await DesktopChineseFont.load();
  final ProviderContainer container = ProviderContainer();
  final DesktopAppLifecycle? desktopLifecycle = await bootstrap(container);
  // 如果桌面端 不用LiquidGlassWidgets.wrap
  if (PlatformUtil.isDesktop) {
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: _AppBootstrap(
          desktopLifecycle: desktopLifecycle,
          child: const MyApp(),
        ),
      ),
    );
    return;
  }
  runApp(
    LiquidGlassWidgets.wrap(
      adaptiveQuality: true,
      child: UncontrolledProviderScope(
        container: container,
        child: _AppBootstrap(
          desktopLifecycle: desktopLifecycle,
          child: const MyApp(),
        ),
      ),
    ),
  );
}

bool _isDesktopLyricsWindow(List<String> args) {
  if (args.length < 3 || args.first != 'multi_window') {
    return false;
  }
  final String rawPayload = args[2];
  return rawPayload.contains('"window":"desktopLyrics"');
}

class _AppBootstrap extends ConsumerStatefulWidget {
  const _AppBootstrap({required this.child, this.desktopLifecycle});

  final Widget child;
  final DesktopAppLifecycle? desktopLifecycle;

  @override
  ConsumerState<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends ConsumerState<_AppBootstrap> {
  bool _didBootstrap = false;
  DesktopHotkeyController? _desktopHotkeyController;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      if (!mounted || _didBootstrap) {
        return;
      }
      _didBootstrap = true;
      await ref.read(favoritesControllerProvider.notifier).initialize();
      await ref.read(biliSessionControllerProvider.notifier).bootstrap();
      ref.read(clipboardSyncControllerProvider.notifier).activate();
      await ref
          .read(playerControllerProvider.notifier)
          .restoreFromPersistence();
      if (PlatformUtil.isDesktop) {
        _desktopHotkeyController = DesktopHotkeyController();
        await _desktopHotkeyController!.attach(ref);
        widget.desktopLifecycle?.attachHotkeyController(
          _desktopHotkeyController!,
        );
      }
    });
  }

  @override
  void dispose() {
    final DesktopHotkeyController? desktopHotkeyController =
        _desktopHotkeyController;
    if (desktopHotkeyController != null) {
      unawaited(
        widget.desktopLifecycle?.detachHotkeyController(
              desktopHotkeyController,
            ) ??
            desktopHotkeyController.detach(),
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(metadataControllerProvider, (previous, next) {});
    return widget.child;
  }
}
