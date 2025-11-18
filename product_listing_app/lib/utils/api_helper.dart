import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class ApiHelper {
  // Singleton
  static ApiHelper? _instance;
  static ApiHelper get instance {
    _instance ??= ApiHelper._privateConstructor();
    return _instance!;
  }

  late final String baseUrl;
  late final String apiKey;
  late final Dio dio;

  // CancelToken accessible via instance
  CancelToken cancelToken = CancelToken();

  final _noNetworkController = StreamController<void>.broadcast();
  Stream<void> get onNoNetwork => _noNetworkController.stream;

  final _networkStatusController = StreamController<bool>.broadcast();
  Stream<bool> get onNetworkStatusChanged => _networkStatusController.stream;

  ApiHelper._privateConstructor() {
    // Read env values
    baseUrl = dotenv.env['BASE_URL'] ?? '';
    apiKey = dotenv.env['API_KEY'] ?? '';

    final useMock = dotenv.env['USE_MOCK'] == 'true';

    if (useMock) {
      debugPrint('✅ Running in MOCK MODE — API not initialized.');
      return;
    }

    if (baseUrl.isEmpty) {
      throw Exception('❌ BASE_URL not found in .env file!');
    }

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Content-Type': 'application/json', 'x-api-key': apiKey},
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) {
          if (e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            cancelRequests();
            _noNetworkController.add(null);
            _networkStatusController.add(false);
            return handler.resolve(
              Response(
                requestOptions: e.requestOptions,
                data: {'cancelled': true},
              ),
            );
          }
          return handler.next(e);
        },
      ),
    );

    Connectivity().onConnectivityChanged.listen((result) async {
      final hasNet = await hasNetwork();
      _networkStatusController.add(hasNet);
    });

    debugPrint('🌐 ApiHelper initialized with baseUrl: $baseUrl');
  }

  /// Cancel all ongoing requests
  void cancelRequests() {
    cancelToken.cancel('Network connection lost');
    cancelToken = CancelToken(); // refresh for future requests
  }

  Future<bool> hasNetwork() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    // ignore: unrelated_type_equality_checks
    if (connectivityResult == ConnectivityResult.none) return false;
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  void dispose() {
    _noNetworkController.close();
    _networkStatusController.close();
  }
}
