import 'package:connectivity_plus/connectivity_plus.dart';

class NetUtil {
  const NetUtil._();

  static Future<bool> isOffline() async {
    return (await Connectivity().checkConnectivity()).contains(
      ConnectivityResult.none,
    );
  }
}
