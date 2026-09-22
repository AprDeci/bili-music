import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/auth/data/bili_auth_repository.dart';
import 'package:bilimusic/feature/auth/domain/bili_sms_login_models.dart';
import 'package:bilimusic/feature/auth/logic/bili_auth_controller.dart';
import 'package:bilimusic/feature/auth/logic/bili_sms_login_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const String _captchaPath =
    'https://passport.bilibili.com/x/passport-login/captcha';
const String _sendPath =
    'https://passport.bilibili.com/x/passport-login/web/sms/send';
const String _loginPath =
    'https://passport.bilibili.com/x/passport-login/web/login/sms';

const BiliGeetestResult _geetestResult = BiliGeetestResult(
  challenge: 'challenge-1',
  validate: 'validate-1',
  seccode: 'validate-1|jordan',
);

Response<dynamic> _jsonResponse(
  Map<String, dynamic> body, {
  List<String> setCookie = const <String>[],
}) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: '/'),
    data: body,
    statusCode: 200,
    headers: Headers.fromMap(<String, List<String>>{'set-cookie': setCookie}),
  );
}

Response<dynamic> _captchaResponse(String challenge) {
  return _jsonResponse(<String, dynamic>{
    'code': 0,
    'message': 'OK',
    'data': <String, dynamic>{
      'type': 'geetest',
      'token': 'token-1',
      'geetest': <String, dynamic>{'gt': 'gt-1', 'challenge': challenge},
    },
  });
}

class _ScriptedHttpClient implements BiliHttpClient {
  final List<Response<dynamic> Function(RequestOptions options)> _script =
      <Response<dynamic> Function(RequestOptions options)>[];
  final List<String> paths = <String>[];

  void enqueue(Response<dynamic> Function(RequestOptions options) response) {
    _script.add(response);
  }

  Response<dynamic> _next(String path, RequestOptions options) {
    paths.add(path);
    if (_script.isEmpty) {
      throw StateError('No scripted response left for $path');
    }
    return _script.removeAt(0)(options);
  }

  @override
  BiliSession? get currentSession => null;

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
    bool requiresWbi = false,
    BiliRequestMode mode = BiliRequestMode.defaultCookie,
    Options? options,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    BiliRequestMode mode = BiliRequestMode.defaultCookie,
  }) async {
    final Response<dynamic> response = _next(
      path,
      RequestOptions(path: path, queryParameters: queryParameters),
    );
    return Response<T>(
      requestOptions: response.requestOptions,
      data: response.data as T?,
      statusCode: response.statusCode,
      headers: response.headers,
    );
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final Response<dynamic> response = _next(
      path,
      RequestOptions(path: path, data: data, queryParameters: queryParameters),
    );
    return Response<T>(
      requestOptions: response.requestOptions,
      data: response.data as T?,
      statusCode: response.statusCode,
      headers: response.headers,
    );
  }
}

class _FakeSessionController extends BiliSessionController {
  BiliSession? adopted;
  bool refreshed = false;

  @override
  BiliSession? build() => null;

  @override
  Future<BiliSession> adoptAuthenticatedSession(BiliSession session) async {
    adopted = session;
    return session;
  }

  @override
  Future<BiliSession> refreshSessionFromNav() async {
    refreshed = true;
    return adopted!;
  }
}

class _Harness {
  _Harness() {
    _subscription = container.listen<BiliSmsLoginState>(
      biliSmsLoginControllerProvider,
      (BiliSmsLoginState? previous, BiliSmsLoginState next) {},
    );
    controller = container.read(biliSmsLoginControllerProvider.notifier);
  }

  final _ScriptedHttpClient client = _ScriptedHttpClient();
  final _FakeSessionController session = _FakeSessionController();
  late final ProviderContainer container = ProviderContainer(
    overrides: [
      biliAuthRepositoryProvider.overrideWithValue(BiliAuthRepository(client)),
      biliSessionControllerProvider.overrideWith(() => session),
    ],
  );
  late final ProviderSubscription<BiliSmsLoginState> _subscription;
  late final BiliSmsLoginController controller;

  BiliSmsLoginState get state => _subscription.read();

  /// 走到「验证码已发送」状态。
  Future<void> sendCode({String challenge = 'challenge-1'}) async {
    client.enqueue((RequestOptions options) => _captchaResponse(challenge));
    await controller.sendCode('13800000000');
    client.enqueue(
      (RequestOptions options) => _jsonResponse(<String, dynamic>{
        'code': 0,
        'message': '0',
        'data': <String, dynamic>{'captcha_key': 'captcha-key-1'},
      }),
    );
    await controller.submitCaptcha(_geetestResult);
  }
}

_Harness _createHarness() {
  final _Harness harness = _Harness();
  addTearDown(harness.container.dispose);
  return harness;
}

void main() {
  test('非法手机号直接失败且不发请求', () async {
    final _Harness harness = _createHarness();

    await harness.controller.sendCode('12345');

    expect(harness.state.status, BiliSmsLoginStatus.failure);
    expect(harness.state.message, contains('11 位'));
    expect(harness.client.paths, isEmpty);
  });

  test('申请极验参数后进入等待人机验证状态', () async {
    final _Harness harness = _createHarness();
    harness.client.enqueue(
      (RequestOptions options) => _captchaResponse('challenge-9'),
    );

    await harness.controller.sendCode('138 0000 0000');

    expect(harness.state.status, BiliSmsLoginStatus.awaitingCaptcha);
    expect(harness.state.tel, '13800000000');
    expect(harness.state.captcha?.token, 'token-1');
    expect(harness.state.captcha?.gt, 'gt-1');
    expect(harness.state.captcha?.challenge, 'challenge-9');
    expect(harness.client.paths, <String>[_captchaPath]);
  });

  test('极验通过后发送短信并开始 60s 倒计时', () async {
    final _Harness harness = _createHarness();

    await harness.sendCode();

    expect(harness.state.status, BiliSmsLoginStatus.codeSent);
    expect(harness.state.captchaKey, 'captcha-key-1');
    expect(harness.state.countdownSeconds, 60);
    expect(harness.state.captcha, isNull);
    expect(harness.client.paths, <String>[_captchaPath, _sendPath]);
  });

  test('极验被拒（2406）时重新申请 captcha 并重试一次', () async {
    final _Harness harness = _createHarness();
    harness.client.enqueue(
      (RequestOptions options) => _captchaResponse('challenge-1'),
    );
    await harness.controller.sendCode('13800000000');

    harness.client.enqueue(
      (RequestOptions options) =>
          _jsonResponse(<String, dynamic>{'code': 2406, 'message': '验证极验服务出错'}),
    );
    harness.client.enqueue(
      (RequestOptions options) => _captchaResponse('challenge-2'),
    );
    await harness.controller.submitCaptcha(_geetestResult);

    expect(harness.state.status, BiliSmsLoginStatus.awaitingCaptcha);
    expect(harness.state.captcha?.challenge, 'challenge-2');

    harness.client.enqueue(
      (RequestOptions options) => _jsonResponse(<String, dynamic>{
        'code': 0,
        'message': '0',
        'data': <String, dynamic>{'captcha_key': 'captcha-key-2'},
      }),
    );
    await harness.controller.submitCaptcha(_geetestResult);

    expect(harness.state.status, BiliSmsLoginStatus.codeSent);
    expect(harness.state.captchaKey, 'captcha-key-2');
    expect(harness.client.paths, <String>[
      _captchaPath,
      _sendPath,
      _captchaPath,
      _sendPath,
    ]);
  });

  test('只重试一次，第二次 2406 直接失败', () async {
    final _Harness harness = _createHarness();
    harness.client.enqueue(
      (RequestOptions options) => _captchaResponse('challenge-1'),
    );
    await harness.controller.sendCode('13800000000');

    harness.client.enqueue(
      (RequestOptions options) =>
          _jsonResponse(<String, dynamic>{'code': 2406, 'message': '验证极验服务出错'}),
    );
    harness.client.enqueue(
      (RequestOptions options) => _captchaResponse('challenge-2'),
    );
    await harness.controller.submitCaptcha(_geetestResult);

    harness.client.enqueue(
      (RequestOptions options) =>
          _jsonResponse(<String, dynamic>{'code': 2406, 'message': '验证极验服务出错'}),
    );
    await harness.controller.submitCaptcha(_geetestResult);

    expect(harness.state.status, BiliSmsLoginStatus.failure);
    expect(harness.state.message, contains('人机验证'));
    expect(harness.client.paths, <String>[
      _captchaPath,
      _sendPath,
      _captchaPath,
      _sendPath,
    ]);
  });

  test('取消人机验证回到 idle', () async {
    final _Harness harness = _createHarness();
    harness.client.enqueue(
      (RequestOptions options) => _captchaResponse('challenge-1'),
    );
    await harness.controller.sendCode('13800000000');

    harness.controller.cancelCaptcha();

    expect(harness.state.status, BiliSmsLoginStatus.idle);
    expect(harness.state.captcha, isNull);
  });

  test('提交验证码成功后落库并刷新 nav', () async {
    final _Harness harness = _createHarness();
    await harness.sendCode();

    harness.client.enqueue(
      (RequestOptions options) => _jsonResponse(
        <String, dynamic>{
          'code': 0,
          'message': '0',
          'data': <String, dynamic>{'is_new': false, 'status': 0},
        },
        setCookie: <String>[
          'SESSDATA=sess-value; Path=/',
          'bili_jct=jct-value; Path=/',
          'DedeUserID=42; Path=/',
        ],
      ),
    );

    await harness.controller.submitCode('123456');

    expect(harness.state.status, BiliSmsLoginStatus.success);
    expect(harness.session.adopted?.sessData, 'sess-value');
    expect(harness.session.adopted?.biliJct, 'jct-value');
    expect(harness.session.adopted?.dedeUserId, '42');
    expect(harness.session.adopted?.isLoggedIn, isTrue);
    expect(harness.session.refreshed, isTrue);
    expect(harness.client.paths.last, _loginPath);
  });

  test('验证码错误时保持登录态不变并给出提示', () async {
    final _Harness harness = _createHarness();
    await harness.sendCode();

    harness.client.enqueue(
      (RequestOptions options) => _jsonResponse(<String, dynamic>{
        'code': 1006,
        'message': '请输入正确的短信验证码',
      }),
    );

    await harness.controller.submitCode('000000');

    expect(harness.state.status, BiliSmsLoginStatus.failure);
    expect(harness.state.message, contains('短信验证码不正确'));
    expect(harness.state.message, contains('1006'));
    expect(harness.session.adopted, isNull);
  });

  test('短信接口返回成功但缺少 captcha_key 时按失败处理', () async {
    final _Harness harness = _createHarness();
    harness.client.enqueue(
      (RequestOptions options) => _captchaResponse('challenge-1'),
    );
    await harness.controller.sendCode('13800000000');

    harness.client.enqueue(
      (RequestOptions options) =>
          _jsonResponse(<String, dynamic>{'code': 0, 'message': '0'}),
    );
    await harness.controller.submitCaptcha(_geetestResult);

    expect(harness.state.status, BiliSmsLoginStatus.failure);
    expect(harness.state.message, contains('登录密钥'));
    expect(harness.state.captchaKey, isNull);
  });

  test('未获取验证码时不允许提交', () async {
    final _Harness harness = _createHarness();

    await harness.controller.submitCode('123456');

    expect(harness.state.status, BiliSmsLoginStatus.failure);
    expect(harness.state.message, '请先获取短信验证码');
    expect(harness.client.paths, isEmpty);
  });
}
