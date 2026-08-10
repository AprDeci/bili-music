import 'dart:async';

import 'package:bilimusic/feature/player/domain/player_event.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_event_hub.g.dart';

@Riverpod(keepAlive: true)
PlayerEventHub playerEventHub(Ref ref) {
  final PlayerEventHub hub = PlayerEventHub();
  ref.onDispose(hub.dispose);
  return hub;
}

class PlayerEventHub {
  final StreamController<PlayerEvent> _controller =
      StreamController<PlayerEvent>.broadcast();

  Stream<PlayerEvent> get events => _controller.stream;

  void add(PlayerEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  Future<void> dispose() => _controller.close();
}
