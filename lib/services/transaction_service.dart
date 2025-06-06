import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/transactions.dart';

class TransactionService {
  final ApiService _apiService = ApiService();
  
  // Get member's general transactions
  Future<List<Transaction>> getMemberTransactions(int memberId) async {
    try {
      String endpoint = 'tabungan/$memberId';

      final response = await _apiService.get(endpoint);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final responseData = response.data['data'];
        
        // Format API: data berisi objek dengan array 'tabungan'
        if (responseData is Map<String, dynamic> && responseData.containsKey('tabungan')) {
          final tabunganList = responseData['tabungan'] as List;
          
          if (tabunganList.isEmpty) {
            return [];
          }
          
          final transactions = tabunganList.map((item) {
            // Tambahkan anggota_id ke setiap item transaksi jika belum ada
            if (!item.containsKey('anggota_id') && responseData.containsKey('anggota_id')) {
              item['anggota_id'] = responseData['anggota_id'];
            }
            return Transaction.fromTabungan(item);
          }).toList();
  
          return transactions;
        } 
        // Untuk format API lama (jika ada)
        else if (responseData is List) {
          return responseData.map((item) => Transaction.fromJson(item)).toList();
        }
        // Jika data kosong
        else {
          return [];
        }
      } else {
        return [];
      }
    } on DioException {
      rethrow; // Re-throw to allow detailed error handling in the UI
    } catch (e) {
      rethrow; // Re-throw to allow detailed error handling in the UI
    }
  } 
  
  // Create a new transaction for a member
  Future<Transaction> createTransaction(
    int anggotaId,
    int jenisTransaksiId,
    double nominal,
    String tanggal,
  ) async {
    try {
      // Prepare the data for the transaction
      final transactionData = {
        'anggota_id': anggotaId,
        'trx_id': jenisTransaksiId, 
        'trx_nominal': nominal,
        'trx_tanggal': tanggal,
      };
        // Use the tabungan endpoint to create the transaction
      final response = await _apiService.post('tabungan', transactionData);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // If the response contains the created transaction
        if (response.data != null && response.data['data'] != null) {
          try {
            return Transaction.fromJson(response.data['data']);
          } catch (e) {
            // Fallback to create a transaction from the data we sent
            return Transaction(
              tanggal: tanggal,
              jenisTransaksiId: jenisTransaksiId,
              nominal: nominal,
            );
          }
        } else {
          // Create a transaction object from the submitted data if not returned
          return Transaction(
            tanggal: tanggal,
            jenisTransaksiId: jenisTransaksiId,
            nominal: nominal,
          );
        }
      }
      
      throw Exception('Failed to create transaction: ${response.statusMessage}');
    } on DioException catch (e) {
      print('Error creating transaction: ${e.message}');
      rethrow; // Re-throw to allow detailed error handling in the UI
    } catch (e) {
      print('Unexpected error: $e');
      rethrow; // Re-throw to allow detailed error handling in the UI
    }
  }

  // Get member balance from API
  Future<double> getMemberBalance(int memberId) async {
    try {
      // Using the endpoint for fetching member balance
      final response = await _apiService.get('saldo/$memberId');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final saldoData = response.data['data'];
        
        // Check if data is available
        if (saldoData != null) {
          // Convert saldo to double, handling different data types
          if (saldoData is num) {
            return saldoData.toDouble();
          } else if (saldoData is String) {
            return double.tryParse(saldoData) ?? 0.0;
          } else if (saldoData is Map && saldoData.containsKey('saldo')) {
            // If saldo is in a nested object
            var saldo = saldoData['saldo'];
            if (saldo is num) {
              return saldo.toDouble();
            } else if (saldo is String) {
              return double.tryParse(saldo) ?? 0.0;
            }
          }
        }
        
        // If data format is unexpected
        print('Unexpected saldo data format: $saldoData');
        return 0.0;
      } else {
        print('API returned error or invalid status code: ${response.statusCode}');
        print('Error message: ${response.data['message'] ?? "No message"}');
        return 0.0;
      }
    } on DioException catch (e) {
      print('Error fetching member balance: ${e.message}');
      print('Error response: ${e.response?.data}');
      return 0.0; // Return 0.0 on error
    } catch (e) {
      print('Unexpected error fetching balance: $e');
      return 0.0; // Return 0.0 on error
    }
  }
}