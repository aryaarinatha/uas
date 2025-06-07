import 'package:dio/dio.dart';
import '../models/location.dart';
import 'api_service.dart';

class LocationService {
  final ApiService _apiService = ApiService();

  LocationService();
  Future<List<Kabupaten>> getKabupaten() async {
    try {
      final response = await _apiService.get('kabupaten/1');

      if (response.statusCode == 200) {
        final List<dynamic> kabupaten = response.data['data']['kabupaten'];
        return kabupaten.map((json) => Kabupaten.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load kabupaten: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Error fetching kabupaten: $e');
      rethrow;
    }
  }

  Future<List<Kecamatan>> getKecamatan(kabupatenId) async {
    try {
      final response = await _apiService.get('kecamatan/$kabupatenId');

      if (response.statusCode == 200) {
        final List<dynamic> kecamatan = response.data['data']['kecamatan'];
        return kecamatan.map((json) => Kecamatan.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load kecamatan: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Error fetching kecamatan: $e');
      rethrow;
    }
  }

  Future<List<Desa>> getDesa(int kecamatanId) async {
    try {
      final response = await _apiService.get('desa/$kecamatanId');

      if (response.statusCode == 200) {
        final List<dynamic> desa = response.data['data']['desa'];
        return desa.map((json) => Desa.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load desa: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Error fetching desa: $e');
      rethrow;
    }
  }
}