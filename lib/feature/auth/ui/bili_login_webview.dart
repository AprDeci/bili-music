import 'dart:async';

import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/auth/data/bili_login_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_all/webview_all.dart';

// B 站官方登录页；登录成功后取 Cookie 写入会话并回调 onLoggedIn
class BiliLoginWebView extends ConsumerStatefulWidget {
  const BiliLoginWebView({super.key, required this.onLoggedIn});

  static const String loginUrl = 'https://passport.bilibili.com/login';
  static const String cookieDomain = 'https://www.bilibili.com';

  final VoidCallback onLoggedIn;

  @override
  ConsumerState<BiliLoginWebView> createState() => _BiliLoginWebViewState();
}

class _BiliLoginWebViewState extends ConsumerState<BiliLoginWebView> {
  static const Duration _pollInterval = Duration(seconds: 2);

  final WebViewCookieManager _cookieManager = WebViewCookieManager();
  late final WebViewController _controller;
  Timer? _pollTimer;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (WebResourceError error) {
            debugPrint('[BiliLogin] 资源加载失败：${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(BiliLoginWebView.loginUrl));

    // 网页登录没有回调，靠轮询 Cookie 判断是否登录完成
    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkLogin());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkLogin() async {
    if (_finishing) {
      return;
    }

    final BiliSession? session = await _readSession();
    if (session == null) {
      return;
    }

    // 置位挡住后续轮询，失败时放开重试
    _finishing = true;
    try {
      final BiliSessionController sessionController = ref.read(
        biliSessionControllerProvider.notifier,
      );
      await sessionController.adoptAuthenticatedSession(session);
      await sessionController.refreshSessionFromNav();
      if (!mounted) {
        return;
      }
      _pollTimer?.cancel();
      widget.onLoggedIn();
    } on Object catch (error) {
      debugPrint('[BiliLogin] 登录态写入失败：$error');
      _finishing = false;
    }
  }

  Future<BiliSession?> _readSession() async {
    try {
      final List<WebViewCookie> cookies = await _cookieManager.getCookies(
        domain: Uri.parse(BiliLoginWebView.cookieDomain),
      );
      final Map<String, String> cookieMap = <String, String>{
        for (final WebViewCookie cookie in cookies) cookie.name: cookie.value,
      };
      return sessionFromCookies(cookieMap);
    } on Object catch (error) {
      debugPrint('[BiliLogin] Cookie 读取失败：$error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      children: <Widget>[
        Expanded(child: WebViewWidget(controller: _controller)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Text(
            '登录成功后会自动完成',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
