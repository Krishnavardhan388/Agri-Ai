import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'local_storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final bool fromServer;

  ApiException(this.message, [this.statusCode = 500, this.fromServer = false]);

  @override
  String toString() => message;
}

class BackendHealthStatus {
  final bool online;
  final bool mongoConnected;
  final bool smsGatewayActive;
  final String databaseLabel;
  final String smsGatewayLabel;

  const BackendHealthStatus({
    required this.online,
    required this.mongoConnected,
    required this.smsGatewayActive,
    required this.databaseLabel,
    required this.smsGatewayLabel,
  });

  factory BackendHealthStatus.offline() {
    return const BackendHealthStatus(
      online: false,
      mongoConnected: false,
      smsGatewayActive: false,
      databaseLabel: 'Backend Unreachable',
      smsGatewayLabel: 'SMS Offline',
    );
  }
}

class ApiClient {
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  static const String productionFallbackUrl = 'https://agriai-snowy.vercel.app';

  final http.Client _client;
  final LocalStorageService? localStorage;

  ApiClient({
    http.Client? client,
    this.localStorage,
  }) : _client = client ?? http.Client();

  String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    final stored = localStorage?.apiUrlOverride;
    if (stored != null && stored.isNotEmpty) return stored;

    if (kIsWeb) {
      final host = Uri.base.host.toLowerCase();
      if (host.isEmpty || host == 'localhost' || host == '127.0.0.1') {
        return 'http://127.0.0.1:8000';
      }
      // Production Web deployed on Vercel or custom domain: same-origin serverless `/api/v1/...`
      return '';
    }

    // Native Android / iOS apps talk directly to the live Vercel cloud backend
    return productionFallbackUrl;
  }

  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final raw = '$baseUrl$normalizedPath';
    final uri = Uri.parse(raw.isEmpty ? '/' : raw);
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = localStorage?.authToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  dynamic _decodeResponse(http.Response response) {
    final body = response.body.trim();
    dynamic decoded;
    if (body.isNotEmpty) {
      try {
        decoded = jsonDecode(body);
      } catch (_) {
        decoded = body;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    String msg = 'Request failed (${response.statusCode})';
    bool hasServerJson = false;
    if (decoded is Map && decoded['detail'] != null) {
      msg = decoded['detail'].toString();
      hasServerJson = true;
    } else if (decoded is Map && decoded['message'] != null) {
      msg = decoded['message'].toString();
      hasServerJson = true;
    }
    throw ApiException(msg, response.statusCode, hasServerJson);
  }

  Future<dynamic> get(String path, {Map<String, String>? queryParameters}) async {
    final resp = await _client
        .get(_buildUri(path, queryParameters), headers: _headers())
        .timeout(const Duration(seconds: 10));
    return _decodeResponse(resp);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final resp = await _client
        .post(
          _buildUri(path),
          headers: _headers(),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(const Duration(seconds: 12));
    return _decodeResponse(resp);
  }

  Future<dynamic> put(String path, {Object? body}) async {
    final resp = await _client
        .put(
          _buildUri(path),
          headers: _headers(),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));
    return _decodeResponse(resp);
  }

  Future<dynamic> patch(String path, {Object? body}) async {
    final resp = await _client
        .patch(
          _buildUri(path),
          headers: _headers(),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));
    return _decodeResponse(resp);
  }

  Future<BackendHealthStatus> checkHealth() async {
    try {
      final data = await get('/api/v1/health');
      if (data is Map<String, dynamic>) {
        return BackendHealthStatus(
          online: data['status'] == 'ONLINE',
          mongoConnected: data['mongodb_connected'] == true,
          smsGatewayActive: data['sms_gateway_active'] == true,
          databaseLabel: data['database']?.toString() ?? 'Database Connected',
          smsGatewayLabel: data['sms_gateway']?.toString() ?? 'SMS Gateway',
        );
      }
    } catch (_) {}
    return BackendHealthStatus.offline();
  }
}
