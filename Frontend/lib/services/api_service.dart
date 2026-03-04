import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8000';
  String? _token;

  void setToken(String token) => _token = token;
  String? get token => _token;

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<http.Response> get(String path) async {
    final url = Uri.parse('$baseUrl$path');
    return await http.get(url, headers: headers);
  }

  Future<http.Response> postJson(String path, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$path');
    return await http.post(url, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> post(String path, Map<String, dynamic>? body) async {
    final url = Uri.parse('$baseUrl$path');
    return await http.post(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$path');
    return await http.put(url, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': username, 'password': password},
    );
  }

  Future<http.StreamedResponse> postMultipart(
    String path,
    Map<String, String> fields,
    List<http.MultipartFile> files,
  ) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
    request.headers.addAll(headers);
    request.fields.addAll(fields);
    request.files.addAll(files);
    return await request.send();
  }
}