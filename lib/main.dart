import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/core/hive/hive.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/myApp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';

Future<void> bootstrap() async {
  JustAudioMediaKit.ensureInitialized();
  await initHive();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap();
  runApp(const ProviderScope(child: _AppBootstrap(child: MyApp())));
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
      await ref.read(biliSessionControllerProvider.notifier).bootstrap();
      await ref
          .read(playerControllerProvider.notifier)
          .restoreFromPersistence();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
