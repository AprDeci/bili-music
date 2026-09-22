import 'package:bilimusic/feature/auth/domain/bili_sms_login_models.dart';
import 'package:bilimusic/feature/auth/logic/bili_sms_login_controller.dart';
import 'package:bilimusic/feature/auth/ui/bili_geetest_webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 全屏人机验证页：验证结果直接交回短信登录控制器。
class BiliGeetestPage extends ConsumerWidget {
  const BiliGeetestPage({super.key, required this.params});

  final BiliCaptchaParams params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BiliSmsLoginController controller = ref.read(
      biliSmsLoginControllerProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('安全验证'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
            controller.cancelCaptcha();
          },
        ),
      ),
      body: BiliGeetestWebView(
        params: params,
        onResult: (BiliGeetestResult result) {
          Navigator.of(context).pop();
          controller.submitCaptcha(result);
        },
        onError: (String message) {
          Navigator.of(context).pop();
          controller.failCaptcha(message);
        },
        onCancel: () {
          Navigator.of(context).pop();
          controller.cancelCaptcha();
        },
      ),
    );
  }
}
