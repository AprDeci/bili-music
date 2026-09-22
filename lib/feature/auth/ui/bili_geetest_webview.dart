import 'dart:async';
import 'dart:convert';

import 'package:bilimusic/core/net/net_config.dart';
import 'package:bilimusic/feature/auth/domain/bili_sms_login_models.dart';
import 'package:flutter/material.dart';
import 'package:webview_all/webview_all.dart';

/// 极验三代 Web 验证码，撑满父级（由调用方放在全屏页面里）。
///
/// 验证页来自 Flutter asset（Windows 会映射成私有 HTTPS 虚拟主机，页面因此拥有真实
/// origin）。页面加载完成后主动握手，Dart 收到握手再把 gt/challenge 注入
/// `startBiliGeetest`，验证结果经 JavaScript channel 回传。
class BiliGeetestWebView extends StatefulWidget {
  const BiliGeetestWebView({
    super.key,
    required this.params,
    required this.onResult,
    required this.onError,
    required this.onCancel,
  });

  final BiliCaptchaParams params;
  final ValueChanged<BiliGeetestResult> onResult;
  final ValueChanged<String> onError;
  final VoidCallback onCancel;

  @override
  State<BiliGeetestWebView> createState() => _BiliGeetestWebViewState();
}

class _BiliGeetestWebViewState extends State<BiliGeetestWebView> {
  static const String _channelName = 'BiliMusicGeetest';
  static const String _assetKey = 'assets/geetest/geetest.html';
  static const Duration _loadTimeout = Duration(seconds: 25);

  late final WebViewController _controller;
  Timer? _watchdog;
  bool _settled = false;
  bool _started = false;
  bool _captchaReady = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(NetConfig.defaultHeaders['User-Agent'] as String)
      ..setOnConsoleMessage((JavaScriptConsoleMessage message) {
        if (message.level == JavaScriptLogLevel.error ||
            message.level == JavaScriptLogLevel.warning) {
          debugPrint('[BiliGeetest] ${message.level.name}: ${message.message}');
        }
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) => unawaited(_startCaptcha()),
          onWebResourceError: (WebResourceError error) {
            debugPrint('[BiliGeetest] 资源加载失败：${error.description}');
          },
        ),
      );
    _load();
  }

  @override
  void dispose() {
    _watchdog?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    // 页面侧的计时器要等注入成功后才存在，所以宿主侧必须有兜底超时。
    _watchdog = Timer(_loadTimeout, () {
      if (!_captchaReady && !_settled) {
        _fail('人机验证加载超时，请检查网络后重试');
      }
    });

    // JavaScript channel 只在下一次页面加载后生效，必须先注册再加载页面。
    await _controller.addJavaScriptChannel(
      _channelName,
      onMessageReceived: (JavaScriptMessage message) {
        _handleMessage(message.message);
      },
    );

    try {
      await _controller.loadFlutterAsset(_assetKey);
    } on Object catch (error) {
      _fail('人机验证页面加载失败：$error');
    }
  }

  Future<void> _startCaptcha() async {
    if (_started || _settled) {
      return;
    }
    _started = true;

    try {
      await _controller.runJavaScript(
        'window.startBiliGeetest('
        '${jsonEncode(widget.params.gt)}, '
        '${jsonEncode(widget.params.challenge)});',
      );
    } on Object catch (error) {
      _fail('人机验证初始化失败：$error');
    }
  }

  void _handleMessage(String raw) {
    final Map<String, dynamic> payload;
    try {
      payload = jsonDecode(raw) as Map<String, dynamic>;
    } on Object {
      return;
    }

    switch (payload['type'] as String? ?? '') {
      case 'page-loaded':
        unawaited(_startCaptcha());
      case 'ready':
        _captchaReady = true;
        _watchdog?.cancel();
      case 'success':
        final String validate = payload['validate'] as String? ?? '';
        final String seccode = payload['seccode'] as String? ?? '';
        if (validate.isEmpty || seccode.isEmpty) {
          _fail('人机验证结果无效，请重试');
          return;
        }
        if (_settled) {
          return;
        }
        _settled = true;
        widget.onResult(
          BiliGeetestResult(
            challenge:
                payload['challenge'] as String? ?? widget.params.challenge,
            validate: validate,
            seccode: seccode,
          ),
        );
      case 'error':
        _fail(payload['message'] as String? ?? '人机验证失败，请重试');
      case 'close':
        if (_settled) {
          return;
        }
        _settled = true;
        widget.onCancel();
      default:
        return;
    }
  }

  void _fail(String message) {
    if (_settled) {
      return;
    }
    _settled = true;
    _watchdog?.cancel();
    widget.onError(message);
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
