import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/configs.dart';

class NoorHttpClient {
  static final NoorHttpClient _instance = NoorHttpClient._internal();
  factory NoorHttpClient() => _instance;
  NoorHttpClient._internal();

  static const Map<String, String> _defaultHeaders = {
    "Content-Type": "application/json",
  };

  /// Generic GET request.
  /// [url] can be a full URL or a path relative to [NoorConfig.apiBaseUrl].
  Future<Map<String, dynamic>?> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      final combinedHeaders = {..._defaultHeaders, ...?headers};
      Uri uri;
      if (url.startsWith("http")) {
        uri = Uri.parse(url);
      } else {
        final path = url.startsWith('/') ? url.substring(1) : url;
        uri = Uri.parse('${NoorConfig.apiBaseUrl}/$path');
      }

      final response = await http.get(uri, headers: combinedHeaders);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
