// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_progress_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(playerProgress)
final playerProgressProvider = PlayerProgressProvider._();

final class PlayerProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<PlayerProgressSnapshot>,
          PlayerProgressSnapshot,
          Stream<PlayerProgressSnapshot>
        >
    with
        $FutureModifier<PlayerProgressSnapshot>,
        $StreamProvider<PlayerProgressSnapshot> {
  PlayerProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerProgressProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerProgressHash();

  @$internal
  @override
  $StreamProviderElement<PlayerProgressSnapshot> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PlayerProgressSnapshot> create(Ref ref) {
    return playerProgress(ref);
  }
}

String _$playerProgressHash() => r'dbca36555b525f53da64a6dd760aa81b3b193e0b';
