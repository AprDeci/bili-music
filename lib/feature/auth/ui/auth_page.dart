import 'package:bilimusic/feature/auth/domain/bili_auth_models.dart';
import 'package:bilimusic/feature/auth/logic/bili_auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  bool _didScheduleStart = false;
  bool _didPopAfterSuccess = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<BiliAuthState>(biliAuthControllerProvider, (previous, next) {
      final bool becameSuccessful =
          previous?.status != BiliQrLoginStatus.success &&
          next.status == BiliQrLoginStatus.success;

      if (!becameSuccessful || _didPopAfterSuccess) {
        return;
      }

      _didPopAfterSuccess = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('登录成功')));
        if (context.canPop()) {
          context.pop();
        }
      });
    });

    final BiliAuthState authState = ref.watch(biliAuthControllerProvider);
    final BiliAuthController controller = ref.read(
      biliAuthControllerProvider.notifier,
    );

    if (!_didScheduleStart &&
        authState.status == BiliQrLoginStatus.initial &&
        authState.qrSession == null) {
      _didScheduleStart = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        controller.startQrLogin();
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        title: const Text('扫码登录'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF17324D),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Color(0xFFFFFFFF), Color(0xFFF8FBFE)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x120A2239),
                      blurRadius: 30,
                      offset: Offset(0, 16),
                    ),
                  ],
                ),
                child: _AuthContent(
                  state: authState,
                  onStart: controller.startQrLogin,
                  onRetry: controller.restartQrLogin,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthContent extends StatelessWidget {
  const _AuthContent({
    required this.state,
    required this.onStart,
    required this.onRetry,
  });

  final BiliAuthState state;
  final Future<void> Function() onStart;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? qrUrl = state.qrSession?.url;
    final bool hasQr = qrUrl != null && qrUrl.isNotEmpty;
    final bool canRetry =
        state.status == BiliQrLoginStatus.expired ||
        state.status == BiliQrLoginStatus.failure;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: hasQr
              ? _QrCard(qrUrl: qrUrl)
              : state.status == BiliQrLoginStatus.loading
              ? const _QrLoadingCard()
              : const _QrPlaceholder(),
        ),
        const SizedBox(height: 18),
        _StatusBanner(state: state),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: state.isBusy
              ? null
              : () {
                  if (canRetry) {
                    onRetry();
                  } else {
                    onStart();
                  }
                },
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF163B5C),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Text(
            _primaryButtonText(state.status),
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  String _primaryButtonText(BiliQrLoginStatus status) {
    switch (status) {
      case BiliQrLoginStatus.expired:
        return '重新获取二维码';
      case BiliQrLoginStatus.failure:
        return '重新开始登录';
      case BiliQrLoginStatus.loading:
        return '正在生成二维码...';
      case BiliQrLoginStatus.waitingForScan:
        return '等待扫码中';
      case BiliQrLoginStatus.waitingForConfirm:
        return '等待确认中';
      case BiliQrLoginStatus.success:
        return '登录成功';
      default:
        return '立即登录';
    }
  }
}

class _QrLoadingCard extends StatelessWidget {
  const _QrLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('loading'),
      height: 320,
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFD),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD5E2EE)),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _QrPlaceholder extends StatelessWidget {
  const _QrPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('placeholder'),
      height: 320,
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFD),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD5E2EE)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Icon(Icons.qr_code_2_rounded, size: 72, color: Color(0xFF4A6075)),
          SizedBox(height: 14),
          Text('正在准备登录二维码'),
        ],
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard({required this.qrUrl});

  final String qrUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey<String>(qrUrl),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFD),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD5E2EE)),
      ),
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              'https://api.qrserver.com/v1/create-qr-code/?size=280x280&data=${Uri.encodeComponent(qrUrl)}',
              width: 240,
              height: 240,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return Container(
                  width: 240,
                  height: 240,
                  alignment: Alignment.center,
                  color: Colors.white,
                  child: const Text('二维码加载失败'),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text('请打开 B 站 App 扫码，并在手机上确认登录', textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _StepHint extends StatelessWidget {
  const _StepHint();

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: const Color(0xFF60788C),
      height: 1.5,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('登录步骤', style: style?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('1. 打开 B 站 App 的扫一扫', style: style),
          Text('2. 扫描当前页面二维码', style: style),
          Text('3. 在手机上确认后自动返回', style: style),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.state});

  final BiliAuthState state;

  @override
  Widget build(BuildContext context) {
    final ({Color background, Color foreground, String text}) appearance =
        _resolveAppearance();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: appearance.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        appearance.text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: appearance.foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  ({Color background, Color foreground, String text}) _resolveAppearance() {
    switch (state.status) {
      case BiliQrLoginStatus.loading:
        return (
          background: const Color(0xFFE8F2FB),
          foreground: const Color(0xFF184C79),
          text: '正在向 B 站申请二维码...',
        );
      case BiliQrLoginStatus.waitingForScan:
        return (
          background: const Color(0xFFEAF8EF),
          foreground: const Color(0xFF276749),
          text: state.message ?? '二维码已就绪，请扫码',
        );
      case BiliQrLoginStatus.waitingForConfirm:
        return (
          background: const Color(0xFFFFF5E8),
          foreground: const Color(0xFFA35B00),
          text: state.message ?? '已扫码，等待手机确认',
        );
      case BiliQrLoginStatus.expired:
        return (
          background: const Color(0xFFFFEFEF),
          foreground: const Color(0xFFB42318),
          text: state.message ?? '二维码已失效，请重新获取',
        );
      case BiliQrLoginStatus.failure:
        return (
          background: const Color(0xFFFFEFEF),
          foreground: const Color(0xFFB42318),
          text: state.message ?? '登录失败，请稍后重试',
        );
      case BiliQrLoginStatus.success:
        return (
          background: const Color(0xFFEAF8EF),
          foreground: const Color(0xFF276749),
          text: '登录成功，正在返回个人页...',
        );
      default:
        return (
          background: const Color(0xFFF5F7FA),
          foreground: const Color(0xFF4B5D70),
          text: '二维码生成后即可扫码登录',
        );
    }
  }
}

class _QrUrlRow extends StatelessWidget {
  const _QrUrlRow({required this.qrUrl});

  final String qrUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7E3F0)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.link_rounded, color: Color(0xFF4A6075)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(qrUrl, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: qrUrl));
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('登录链接已复制')));
              }
            },
            child: const Text('复制'),
          ),
        ],
      ),
    );
  }
}
