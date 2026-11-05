// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_chart_resolver.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(musicChartResolver)
final musicChartResolverProvider = MusicChartResolverProvider._();

final class MusicChartResolverProvider
    extends
        $FunctionalProvider<
          MusicChartResolver,
          MusicChartResolver,
          MusicChartResolver
        >
    with $Provider<MusicChartResolver> {
  MusicChartResolverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'musicChartResolverProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$musicChartResolverHash();

  @$internal
  @override
  $ProviderElement<MusicChartResolver> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MusicChartResolver create(Ref ref) {
    return musicChartResolver(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MusicChartResolver value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MusicChartResolver>(value),
    );
  }
}

String _$musicChartResolverHash() =>
    r'426d1b738372f2b84ac70459d66b8fdf7034d147';
