import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/core/hive/hive.dart';
import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/notification/app_notification_host.dart';
import 'package:bilimusic/core/window/desktop_window_state_controller.dart';
import 'package:bilimusic/core/window/desktop_window_state_store.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/player/logic/app_audio_handler.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/player_lyrics_controller.dart';
import 'package:bilimusic/myApp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hive_ce/hive.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:window_manager/window_manager.dart';

Future<void> bootstrap() async {
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
    await windowManager.ensureInitialized();

    final DesktopWindowStateStore windowStateStore = DesktopWindowStateStore(
      Hive.box<String>(HiveBoxNames.prefs),
    );
    final DesktopWindowState? savedWindowState = windowStateStore.read();
    final WindowOptions windowOptions = WindowOptions(
      size: savedWindowState?.size ?? defaultDesktopWindowSize,
      minimumSize: defaultDesktopWindowSize,
      center: savedWindowState == null,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      if (savedWindowState != null) {
        await windowManager.setPosition(savedWindowState.position);
      }
      await windowManager.show();
      if (savedWindowState?.isMaximized == true) {
        await windowManager.maximize();
      }
      await windowManager.focus();
    });
    DesktopWindowStateController(windowStateStore).attach();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap();
  runApp(
    LiquidGlassWidgets.wrap(
      const ProviderScope(
        child: AppNotificationHost(child: _AppBootstrap(child: MyApp())),
      ),
    ),
  );
}

class _AppBootstrap extends ConsumerStatefulWidget {
  const _AppBootstrap({required this.child});

  final Widget child;

  @override
  ConsumerState<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends ConsumerState<_AppBootstrap> {
  bool _didBootstrap = false;

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
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(playerLyricsControllerProvider, (previous, next) {});
    return widget.child;
  }
}
