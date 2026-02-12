import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  static final Connectivity _connectivity = Connectivity();

  // Check if device has internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await http.get(Uri.parse('https://www.google.com')).timeout(
        const Duration(seconds: 10),
      );
      return result.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Check network status with connectivity plus
  static Future<bool> isOnline() async {
    final connectivityResult = await _connectivity.checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    // Double check with actual internet access test
    return await hasInternetConnection();
  }

  // Listen to network changes
  static Stream<bool> get onNetworkStatusChange {
    return _connectivity.onConnectivityChanged.asyncMap((result) async {
      if (result == ConnectivityResult.none) return false;
      return await hasInternetConnection();
    });
  }
}