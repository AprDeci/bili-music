// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appSettingsStore)
final appSettingsStoreProvider = AppSettingsStoreProvider._();

final class AppSettingsStoreProvider
    extends
        $FunctionalProvider<
          AppSettingsStore,
          AppSettingsStore,
          AppSettingsStore
        >
    with $Provider<AppSettingsStore> {
  AppSettingsStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appSettingsStoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appSettingsStoreHash();

  @$internal
  @override
  $ProviderElement<AppSettingsStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppSettingsStore create(Ref ref) {
    return appSettingsStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppSettingsStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppSettingsStore>(value),
    );
  }
}

String _$appSettingsStoreHash() => r'27c33af436f3cfb8d6dd754a3d8af0944d46f8ac';
