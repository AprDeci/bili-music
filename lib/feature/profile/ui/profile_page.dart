import 'package:bilimusic/common/components/search.dart';
import 'package:bilimusic/feature/profile/ui/components/user_card.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 搜索栏
      appBar: AppBar(
        // 调整高度
        toolbarHeight: 48,
        title: CommonSearchBar(),
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
