import 'package:bilimusic/common/components/searchBar.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/profile/ui/components/user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BiliSession? session = ref.watch(biliSessionControllerProvider);

    return Scaffold(
      // 搜索栏
      appBar: AppBar(
        // 调整高度
        toolbarHeight: 48,
        title: CommonSearchBar(onTap: () => context.push('/search')),
        actions: [IconButton(icon: Icon(Icons.settings), onPressed: () {})],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [UserCard()],
          ),
        ),
      ),
    );
  }
}
