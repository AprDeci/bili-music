import 'package:freezed_annotation/freezed_annotation.dart';

part 'up_profile.freezed.dart';

@freezed
abstract class UpProfile with _$UpProfile {
  const factory UpProfile({
    required int mid,
    required String name,
    required String avatarUrl,
    required int followerCount,
    int? officialType,
  }) = _UpProfile;
}
