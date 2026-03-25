import 'package:bilimusic/feature/auth/domain/bili_auth_models.dart';
import 'package:bilimusic/feature/auth/logic/bili_auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthPage extends ConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BiliAuthState authState = ref.watch(biliAuthControllerProvider);
    final BiliAuthController controller = ref.read(
      biliAuthControllerProvider.notifier,
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFFF4F7FB),
              Color(0xFFE5EEF8),
              Color(0xFFDDE7F4),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x140D1B2A),
                        blurRadius: 32,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: authState.status == BiliQrLoginStatus.success
                        ? _LoggedInView(
                            state: authState,
                            onLogout: controller.logout,
                          )
                        : _QrLoginView(
                            state: authState,
                            onStart: controller.startQrLogin,
                            onRetry: controller.restartQrLogin,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QrLoginView extends StatelessWidget {
  const _QrLoginView({
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
    final bool showLoading =
        state.status == BiliQrLoginStatus.loading && !hasQr;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'BiliMusic',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF18324B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '使用 B 站 App 扫码登录，成功后会自动保存 SESSDATA、bili_jct 和 refresh_token。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF52657A),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: hasQr
              ? _QrCard(qrUrl: qrUrl)
              : showLoading
              ? Container(
                  height: 280,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAFD),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFD7E3F0)),
                  ),
                  child: const CircularProgressIndicator(),
                )
              : const _QrPlaceholder(),
        ),
        const SizedBox(height: 20),
        _StatusBanner(state: state),
        if (hasQr) ...<Widget>[
          const SizedBox(height: 16),
          _QrUrlRow(qrUrl: qrUrl),
        ],
        const SizedBox(height: 24),
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
            backgroundColor: const Color(0xFF133B5C),
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
              fontWeight: FontWeight.w600,
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
        return '重试登录';
      case BiliQrLoginStatus.loading:
        return '正在请求二维码...';
      case BiliQrLoginStatus.waitingForScan:
        return '等待扫码中';
      case BiliQrLoginStatus.waitingForConfirm:
        return '等待确认中';
      default:
        return '开始二维码登录';
    }
  }
}

class _QrPlaceholder extends StatelessWidget {
  const _QrPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFD),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD7E3F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          Icon(Icons.qr_code_2_rounded, size: 72, color: Color(0xFF4A6075)),
          SizedBox(height: 14),
          Text('点击下方按钮生成登录二维码'),
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
        border: Border.all(color: const Color(0xFFD7E3F0)),
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
              errorBuilder: (_, __, ___) {
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
          const Text(
            '打开 B 站 App，使用扫码功能完成登录',
            textAlign: TextAlign.center,
          ),
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
          text: state.message ?? '已扫码，等待确认',
        );
      case BiliQrLoginStatus.expired:
        return (
          background: const Color(0xFFFFEFEF),
          foreground: const Color(0xFFB42318),
          text: state.message ?? '二维码已失效',
        );
      case BiliQrLoginStatus.failure:
        return (
          background: const Color(0xFFFFEFEF),
          foreground: const Color(0xFFB42318),
          text: state.message ?? '登录失败，请稍后重试',
        );
      default:
        return (
          background: const Color(0xFFF5F7FA),
          foreground: const Color(0xFF4B5D70),
          text: '点击下方按钮开始二维码登录',
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
            child: Text(
              qrUrl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: qrUrl));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('登录链接已复制')),
                );
              }
            },
            child: const Text('复制'),
          ),
        ],
      ),
    );
  }
}

class _LoggedInView extends StatelessWidget {
  const _LoggedInView({required this.state, required this.onLogout});

  final BiliAuthState state;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final BiliAuthSession session = state.authSession!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFD9E6F2),
              backgroundImage: session.face != null && session.face!.isNotEmpty
                  ? NetworkImage(session.face!)
                  : null,
              child: session.face == null || session.face!.isEmpty
                  ? const Icon(Icons.person_rounded, color: Color(0xFF34516E))
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    session.uname?.isNotEmpty == true
                        ? session.uname!
                        : '已登录 B 站账号',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF18324B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'mid: ${session.mid ?? '-'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF52657A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SessionTile(label: 'SESSDATA', value: session.sessData),
        const SizedBox(height: 12),
        _SessionTile(label: 'bili_jct', value: session.biliJct),
        const SizedBox(height: 12),
        _SessionTile(label: 'refresh_token', value: session.refreshToken),
        const SizedBox(height: 12),
        _SessionTile(label: 'WBI img_key', value: session.imgKey ?? '-'),
        const SizedBox(height: 28),
        OutlinedButton(
          onPressed: () {
            onLogout();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF18324B),
            side: const BorderSide(color: Color(0xFFB7C9DB)),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text('退出登录'),
        ),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7E3F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: const Color(0xFF52657A),
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(value),
        ],
      ),
    );
  }
}
