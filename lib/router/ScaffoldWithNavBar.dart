import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  int _currentIndex = 0;

  @override
  void didUpdateWidget(covariant ScaffoldWithNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentIndex = widget.navigationShell.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: BottomBar(
        fit: StackFit.expand,
        borderRadius: BorderRadius.circular(40),
        offset: 18,
        barColor: Colors.transparent,
        duration: const Duration(milliseconds: 300),
        width: screenWidth * 0.92,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40), // 裁剪 NavigationBar 为圆角
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
              widget.navigationShell.goBranch(
                index,
                initialLocation: index == widget.navigationShell.currentIndex,
              );
            },
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            backgroundColor: Colors.white, // NavigationBar 背景颜色
            elevation: 0,
            height: 60,
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: '首页',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outlined),
                selectedIcon: Icon(Icons.person),
                label: '我的',
              ),
            ],
          ),
        ),

        body: (context, scrollController) => widget.navigationShell,
      ),
    );
  }
}
