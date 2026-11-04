import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/feature/up/ui/components/favorite_up_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteUpListPage extends ConsumerWidget {
  const FavoriteUpListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: PlatformUtil.isMobile ? AppBar(title: const Text('收藏UP主')) : null,
      body: const FavoriteUpList(),
    );
  }
}
