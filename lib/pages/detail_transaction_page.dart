import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transactions.dart';
import '../services/transaction_service.dart';
import 'package:dio/dio.dart';
import 'add_transaction_page.dart';

class DetailTransactionPage extends StatefulWidget {
  final int memberId;
  final String memberName;

  const DetailTransactionPage({
    super.key,
    required this.memberId,
    required this.memberName,
  });

  @override
  State<DetailTransactionPage> createState() => _DetailTransactionPageState();
}

class _DetailTransactionPageState extends State<DetailTransactionPage> {
  final TransactionService _transactionService = TransactionService();
  bool _isLoading = true;
  List<Transaction> _transactions = [];
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _loadMemberTransaction();
    _loadMemberBalance();
  }

  @override
  void dispose() {
    super.dispose();
  }  
  Future<void> _loadMemberTransaction() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load only member transactions
      final transactions = await _transactionService.getMemberTransactions(widget.memberId);
      
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e is DioException
            ? 'Gagal memuat data: ${e.response?.data['message'] ?? e.message}'
            : 'Gagal memuat data: ${e.toString()}';
      });
    }
  }

  String _formatCurrency(double amount) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatCurrency.format(amount);
  }  

  Color _getTransactionColor(Transaction transaction) {
    // Fallback to transaction ID if jenisTransaksi is null
    if (transaction.jenisTransaksiId == 1 || transaction.jenisTransaksiId == 2) {
      return Colors.green; // Deposit/Setoran is green
    } else  {
      return Colors.red;   // Withdrawal/Penarikan is red
    }
  }  
      // Menyimpan nilai saldo dari API
  double _balance = 0.0; // Saldo terkini dari API
  bool _isLoadingBalance = true;  // Status loading saldo

  /// Fungsi untuk mengambil saldo terkini dari API
  /// Menggunakan endpoint /saldo/{memberId}
  /// Nilai saldo dari API lebih akurat daripada kalkulasi lokal
  Future<void> _loadMemberBalance() async {
    setState(() {
      _isLoadingBalance = true;
    });
    
    try {
      // Menggunakan service untuk mengambil saldo dari API
      final balance = await _transactionService.getMemberBalance(widget.memberId);
      setState(() {
        _balance = balance;
        _isLoadingBalance = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBalance = false;
        // Jika gagal, tampilkan pesan notifikasi yang tidak mengganggu
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat memperbarui saldo, periksa koneksi internet.'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaksi ${widget.memberName}'),
        centerTitle: true,
      ), 
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionPage(
                memberId: widget.memberId,
                memberName: widget.memberName,
              ),
            ),
          );
            if (result != null) {
            // If transaction was created successfully, reload data and refresh balance
            _loadMemberTransaction();
            _loadMemberBalance();
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        tooltip: 'Tambah Transaksi',
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMemberTransaction,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _buildTransactionList(),
    );
  }
  Widget _buildTransactionList() {
    // Saldo dari API atau fallback ke kalkulasi lokal jika API gagal
    final displayBalance = _balance;
    
    return Column(
      children: [
        // Ringkasan Transaksi
        Card(
          margin: const EdgeInsets.all(16.0),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ringkasan Transaksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Saldo Saat Ini:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    _isLoadingBalance
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _formatCurrency(displayBalance),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: displayBalance > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Daftar Transaksi (bagian ini tidak berubah)
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await _loadMemberTransaction();
              await _loadMemberBalance();
            },
            child: ListView.builder(
              itemCount: _transactions.length,
              padding: const EdgeInsets.all(16.0),
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                final transactionType = transaction.jenisTransaksi;
                final color = _getTransactionColor(transaction);

                return Column(
                  children: [
                    Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.2),
                          child: Icon(
                            transaction.jenisTransaksiId == 1 ? Icons.drag_handle
                                : transaction.jenisTransaksiId == 2 ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: color,
                          ),
                        ),
                        title: Text(
                          transactionType?.nama ?? 
                          (transaction.jenisTransaksiId == 1 ? 'Saldo Awal' 
                           : transaction.jenisTransaksiId == 2 ? 'Simpanan' : 'Penarikan'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text((transaction.tanggal)),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatCurrency(transaction.nominal),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: color,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'ID: ${transaction.id}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}