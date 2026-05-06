import 'dart:async';

import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/core/hive/hive.dart';
import 'package:bilimusic/core/theme/desktop_chinese_font.dart';
import 'package:bilimusic/core/window/desktop_app_lifecycle.dart';
import 'package:bilimusic/core/window/desktop_hotkey_controller.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/player/logic/app_audio_handler.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/player_lyrics_controller.dart';
import 'package:bilimusic/myApp.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

Future<DesktopAppLifecycle?> bootstrap(ProviderContainer container) async {
  await PlayerAudioService.initialize();
  await LiquidGlassWidgets.initialize();
  JustAudioMediaKit.ensureInitialized(
    linux: true, // default: true  - dependency: media_kit_libs_linux
    windows: true, // default: true  - dependency: media_kit_libs_windows_audio
    iOS: true, // default: false - dependency: media_kit_libs_ios_audio
    macOS: true,
    android: true,
  );
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DesktopChineseFont.load();
  final ProviderContainer container = ProviderContainer();
  final DesktopAppLifecycle? desktopLifecycle = await bootstrap(container);
  runApp(
    LiquidGlassWidgets.wrap(
      UncontrolledProviderScope(
        container: container,
        child: _AppBootstrap(
          desktopLifecycle: desktopLifecycle,
          child: const MyApp(),
        ),
      ),
    ),
  );
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
    ref.listen(playerLyricsControllerProvider, (previous, next) {});
    return widget.child;
  }
}
