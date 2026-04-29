// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_logic.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ThemeLogic)
final themeLogicProvider = ThemeLogicProvider._();

final class ThemeLogicProvider
    extends $NotifierProvider<ThemeLogic, ThemeUiModel> {
  ThemeLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeLogicProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeLogicHash();

  @$internal
  @override
  ThemeLogic create() => ThemeLogic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeUiModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeUiModel>(value),
    );
  }
}

String _$themeLogicHash() => r'9d0ff49854b0ba920b9a23cafe1fca6c93f1fdf0';

abstract class _$ThemeLogic extends $Notifier<ThemeUiModel> {
  ThemeUiModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ThemeUiModel, ThemeUiModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeUiModel, ThemeUiModel>,
              ThemeUiModel,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
