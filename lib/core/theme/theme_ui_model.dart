import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme_ui_model.freezed.dart';
part 'theme_ui_model.g.dart';

enum ThemeVariant {
  classicGreen,
  frostTeaWhite,
  skyBlue,
  irisPurple,
  blossomPink,
  sunsetOrange,
}

@freezed
abstract class ThemeUiModel with _$ThemeUiModel {
  const factory ThemeUiModel({
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(ThemeVariant.classicGreen) ThemeVariant themeVariant,
  }) = _ThemeUiModel;

  factory ThemeUiModel.fromJson(Map<String, dynamic> json) =>
      _$ThemeUiModelFromJson(json);
}
