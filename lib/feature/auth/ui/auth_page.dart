import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:bilimusic/feature/auth/domain/bili_auth_models.dart';
import 'package:bilimusic/feature/auth/logic/bili_auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

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
      appBar: AppBar(
        title: const Text('扫码登录'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(16),
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
    final ColorScheme colorScheme = theme.colorScheme;
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
        _StatusBanner(state: state),
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
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      key: const ValueKey<String>('loading'),
      height: 320,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _QrPlaceholder extends StatelessWidget {
  const _QrPlaceholder();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      key: const ValueKey<String>('placeholder'),
      height: 320,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.qr_code_2_rounded,
            size: 72,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 14),
          Text(
            '正在准备登录二维码',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard({required this.qrUrl});

  final String qrUrl;

  Future<void> _saveQrImage(BuildContext context) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      if (!Platform.isAndroid && !Platform.isIOS) {
        messenger.showSnackBar(
          const SnackBar(content: Text('当前平台暂不支持直接保存到系统相册')),
        );
        return;
      }

      const double qrSize = 1200.0;

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      final Paint bgPaint = Paint()..color = Colors.white;
      canvas.drawRect(Rect.fromLTWH(0, 0, qrSize, qrSize), bgPaint);

      final QrPainter painter = QrPainter(
        data: qrUrl,
        version: QrVersions.auto,
        gapless: true,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Color(0xFF111111),
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Color(0xFF111111),
        ),
      );

      // 在中心绘制二维码
      painter.paint(canvas, Size(qrSize, qrSize));

      final ui.Image image = await recorder.endRecording().toImage(
        qrSize.toInt(),
        qrSize.toInt(),
      );
      final ByteData? imageData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List? bytes = imageData?.buffer.asUint8List();
      if (bytes == null || bytes.isEmpty) {
        throw const FormatException('二维码数据为空');
      }

      final String fileName =
          'bilimusic_qr_${DateTime.now().millisecondsSinceEpoch}.png';
      final SaveResult result = await SaverGallery.saveImage(
        bytes,
        fileName: fileName,
        skipIfExists: false,
        androidRelativePath: Platform.isAndroid ? 'Pictures/Bilimusic' : null,
      );

      if (!context.mounted) {
        return;
      }

      if (result.isSuccess) {
        messenger.showSnackBar(const SnackBar(content: Text('二维码已保存到系统相册')));
        return;
      }

      messenger.showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? '保存二维码失败')),
      );
    } on Object catch (_) {
      if (!context.mounted) {
        return;
      }
      messenger.showSnackBar(const SnackBar(content: Text('保存二维码失败，请稍后重试')));
    }
  }

  // 其他App打开二维码
  Future<void> _openQrUrl(BuildContext context) async {
    final Uri uri = Uri.parse(
      'bilibili://browser?url=${Uri.encodeComponent(qrUrl)}',
    );
    try {
      if (!await launchUrl(
        uri,
        mode: LaunchMode.externalNonBrowserApplication,
      )) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('打开二维码失败')));
      }
    } catch (_) {
      // 处理异常
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      key: ValueKey<String>(qrUrl),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(),
      child: Column(
        children: <Widget>[
          Container(
            width: 240,
            height: 240,
            color: Colors.white,
            alignment: Alignment.center,
            child: QrImageView(
              data: qrUrl,
              version: QrVersions.auto,
              size: 240,
              padding: EdgeInsets.zero,
              backgroundColor: Colors.white,
              gapless: true,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF111111),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF111111),
              ),
              errorStateBuilder: (_, __) {
                return const Center(child: Text('二维码生成失败'));
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                onPressed: () => _saveQrImage(context),
                icon: const Icon(Icons.download_rounded),
                label: const Text('保存'),
              ),
              TextButton.icon(
                onPressed: () => _openQrUrl(context),
                icon: const Icon(Icons.open_in_new),
                label: const Text('其他App打开'),
              ),
            ],
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
    final ThemeData theme = Theme.of(context);
    final ({Color background, Color foreground, String text}) appearance =
        _resolveAppearance(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        appearance.text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: appearance.foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  ({Color background, Color foreground, String text}) _resolveAppearance(
    BuildContext context,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    switch (state.status) {
      case BiliQrLoginStatus.loading:
        return (
          background: colorScheme.primaryContainer,
          foreground: colorScheme.onPrimaryContainer,
          text: '正在向 B 站申请二维码...',
        );
      case BiliQrLoginStatus.waitingForScan:
        return (
          background: colorScheme.secondaryContainer,
          foreground: colorScheme.onSecondaryContainer,
          text: state.message ?? '二维码已就绪，请扫码',
        );
      case BiliQrLoginStatus.waitingForConfirm:
        return (
          background: colorScheme.tertiaryContainer,
          foreground: colorScheme.onTertiaryContainer,
          text: state.message ?? '已扫码，等待手机确认',
        );
      case BiliQrLoginStatus.expired:
        return (
          background: colorScheme.errorContainer,
          foreground: colorScheme.onErrorContainer,
          text: state.message ?? '二维码已失效，请重新获取',
        );
      case BiliQrLoginStatus.failure:
        return (
          background: colorScheme.errorContainer,
          foreground: colorScheme.onErrorContainer,
          text: state.message ?? '登录失败，请稍后重试',
        );
      case BiliQrLoginStatus.success:
        return (
          background: colorScheme.secondaryContainer,
          foreground: colorScheme.onSecondaryContainer,
          text: '登录成功，正在返回个人页...',
        );
      default:
        return (
          background: colorScheme.surfaceContainerLow,
          foreground: colorScheme.onSurfaceVariant,
          text: '二维码生成后即可扫码登录',
        );
    }
  }
}
