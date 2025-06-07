import 'package:dio/dio.dart';
import 'auth_service.dart';

class ApiService {
  // static menandakan bahwa variable _instance hanya ada satu di seluruh aplikasi
  static final ApiService _instance = ApiService._internal(); // singleton, aplikasi tidak akan pernah membuat dua objek ApiService dan objek yang ada di dalamnya juga
  final Dio _dio = Dio(); // membuat objek dio

  factory ApiService() { // setiap kali ApiService() dipanggil, akan mengembalikan objek yang sama (_instance)
    return _instance;
  }
  ApiService._internal() {
    // Configure Dio instance
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers['Accept'] = 'application/json'; // aplikasi akan menerima data dalam format JSON (karena flutter lebih mudah menggunakan json)
  }

  Dio get dio => _dio; // memberikan akses ke objek dio untuk digunakan diluar kelas ini (karena _dio bersifat private)

  // Base URL for API
  static const String baseUrl = 'https://mobileapis-test.manpits.xyz/api'; // bisa langsung dipanggil dengan ApiService.baseUrl (karena tidak private)

  // Helper method to get headers with authentication
  Future<Map<String, dynamic>> getHeaders() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json', // aplikasi akan mengirim data dalam format JSON
      'Authorization': 'Bearer $token', // menambahkan token ke header untuk otentikasi
    };
  }

  // POST method with authentication
  Future<Response> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await getHeaders();
    final url = '$baseUrl/$endpoint';

    return _dio.post(url, options: Options(headers: headers), data: data);
  }

  // GET method with authentication
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters,
  }) async {
    final headers = await getHeaders();
    final url = '$baseUrl/$endpoint';
    
    // Debug print untuk memastikan endpoint dan token tersedia
    print('\nApiService - URL: $url');
    print('ApiService - Headers: ${headers['Authorization']}');
    
    return _dio.get(
      url,
      options: Options(headers: headers),
      queryParameters: queryParameters,
    );
  }

  // DELETE method with authentication
  Future<Response> delete(String endpoint) async {
    final headers = await getHeaders();
    final url = '$baseUrl/$endpoint';

    return _dio.delete(url, options: Options(headers: headers));
  }

  // PATCH method with authentication
  Future<Response> patch(String endpoint, Map<String, dynamic> data) async {
    final headers = await getHeaders();
    final url = '$baseUrl/$endpoint';

    return _dio.patch(url, options: Options(headers: headers), data: data);
  }
}
