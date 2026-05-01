// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hotkey_binding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HotkeyBinding _$HotkeyBindingFromJson(Map<String, dynamic> json) =>
    _HotkeyBinding(
      action: $enumDecode(_$HotkeyActionEnumMap, json['action']),
      keyCode: (json['keyCode'] as num).toInt(),
      modifiers: (json['modifiers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      enabled: json['enabled'] as bool? ?? true,
    );

Map<String, dynamic> _$HotkeyBindingToJson(_HotkeyBinding instance) =>
    <String, dynamic>{
      'action': _$HotkeyActionEnumMap[instance.action]!,
      'keyCode': instance.keyCode,
      'modifiers': instance.modifiers,
      'enabled': instance.enabled,
    };

const _$HotkeyActionEnumMap = {
  HotkeyAction.playPause: 'playPause',
  HotkeyAction.previousTrack: 'previousTrack',
  HotkeyAction.nextTrack: 'nextTrack',
  HotkeyAction.toggleDesktop: 'toggleDesktop',
};
