import 'package:bilimusic/feature/auth/domain/bili_sms_login_models.dart';
import 'package:bilimusic/feature/auth/logic/bili_sms_login_controller.dart';
import 'package:bilimusic/feature/auth/ui/bili_geetest_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BiliSmsLoginView extends ConsumerStatefulWidget {
  const BiliSmsLoginView({super.key});

  @override
  ConsumerState<BiliSmsLoginView> createState() => _BiliSmsLoginViewState();
}

class _BiliSmsLoginViewState extends ConsumerState<BiliSmsLoginView> {
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String? _openedChallenge;

  @override
  void dispose() {
    _telController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  /// 控制器拿到极验参数后弹出全屏验证页；2406 重试会带来新的 challenge，
  /// 因此这里用 challenge 而不是布尔标记判断是否需要重新弹出。
  void _openGeetest(BiliCaptchaParams captcha) {
    if (_openedChallenge == captcha.challenge) {
      return;
    }
    _openedChallenge = captcha.challenge;

    Navigator.of(context)
        .push<void>(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (BuildContext context) => BiliGeetestPage(params: captcha),
          ),
        )
        .then((_) async {
          _openedChallenge = null;

          // 用户直接返回（系统返回键 / 关闭按钮）时控制器还停在等待验证状态，
          // 不复位的话「获取短信验证码」会被 isBusy 一直禁用。
          final BiliSmsLoginState latest = ref.read(
            biliSmsLoginControllerProvider,
          );
          if (latest.status == BiliSmsLoginStatus.awaitingCaptcha &&
              latest.captcha?.challenge == captcha.challenge) {
            ref.read(biliSmsLoginControllerProvider.notifier).cancelCaptcha();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final BiliSmsLoginState state = ref.watch(biliSmsLoginControllerProvider);
    final BiliSmsLoginController controller = ref.read(
      biliSmsLoginControllerProvider.notifier,
    );
    final bool canSendCode = !state.isBusy && state.countdownSeconds == 0;
    final bool canSubmitCode =
        state.hasCaptchaKey && state.status != BiliSmsLoginStatus.submitting;

    ref.listen<BiliSmsLoginState>(biliSmsLoginControllerProvider, (
      previous,
      next,
    ) {
      final BiliCaptchaParams? nextCaptcha = next.captcha;
      if (nextCaptcha != null && mounted) {
        _openGeetest(nextCaptcha);
      }
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          controller: _telController,
          keyboardType: TextInputType.phone,
          maxLength: 11,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: const InputDecoration(
            labelText: '手机号',
            prefixText: '+86  ',
            counterText: '',
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: canSendCode
              ? () => controller.sendCode(_telController.text)
              : null,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            state.countdownSeconds > 0
                ? '${state.countdownSeconds}s 后可重新获取'
                : '获取短信验证码',
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          enabled: state.hasCaptchaKey,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: const InputDecoration(
            labelText: '短信验证码',
            counterText: '',
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: canSubmitCode
              ? () => controller.submitCode(_codeController.text)
              : null,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            state.status == BiliSmsLoginStatus.submitting ? '登录中...' : '登录',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if ((state.message?.isNotEmpty ?? false) &&
            state.status != BiliSmsLoginStatus.success) ...<Widget>[
          const SizedBox(height: 14),
          Text(
            state.message!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: state.status == BiliSmsLoginStatus.failure
                  ? colorScheme.error
                  : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
