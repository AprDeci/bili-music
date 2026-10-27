// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_media_session_sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(playerMediaSessionSync)
final playerMediaSessionSyncProvider = PlayerMediaSessionSyncProvider._();

final class PlayerMediaSessionSyncProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  PlayerMediaSessionSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerMediaSessionSyncProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerMediaSessionSyncHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return playerMediaSessionSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$playerMediaSessionSyncHash() =>
    r'771224a30945fbea6af2a53894313dbdf7a12648';
