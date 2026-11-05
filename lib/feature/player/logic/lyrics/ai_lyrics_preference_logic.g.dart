// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_lyrics_preference_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AiLyricsPreferenceLogic)
final aiLyricsPreferenceLogicProvider = AiLyricsPreferenceLogicProvider._();

final class AiLyricsPreferenceLogicProvider
    extends $NotifierProvider<AiLyricsPreferenceLogic, bool> {
  AiLyricsPreferenceLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiLyricsPreferenceLogicProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiLyricsPreferenceLogicHash();

  @$internal
  @override
  AiLyricsPreferenceLogic create() => AiLyricsPreferenceLogic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$aiLyricsPreferenceLogicHash() =>
    r'b21ad33a5a1225dd4e83767d1e5062567dc30991';

abstract class _$AiLyricsPreferenceLogic extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
