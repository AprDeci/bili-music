import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_user_item.freezed.dart';

@freezed
abstract class SearchUserItem with _$SearchUserItem {
  const factory SearchUserItem({
    required int mid,
    required String name,
    required String avatarUrl,
    required String sign,
    required String fansText,
    required String videoCountText,
    required int level,
    String? officialTitle,
  }) = _SearchUserItem;
}
