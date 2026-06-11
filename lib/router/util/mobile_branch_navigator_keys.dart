import 'package:flutter/material.dart';

const int mobileBranchNavigatorKeyCount = 6;

// 移动端分支导航键列表
final List<GlobalKey<NavigatorState>> mobileBranchNavigatorKeys =
    List<GlobalKey<NavigatorState>>.generate(
      mobileBranchNavigatorKeyCount,
      (int index) =>
          GlobalKey<NavigatorState>(debugLabel: 'mobileBranch$index'),
    );
