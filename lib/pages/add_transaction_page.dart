import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/transaction_service.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class AddTransactionPage extends StatefulWidget {
  final int memberId;
  final String memberName;

  const AddTransactionPage({
    super.key,
    required this.memberId,
    required this.memberName,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final List<Map<String, dynamic>> _jenisTransaksiList = [
    {'id': '2', 'nama': 'Simpanan'},
    {'id': '3', 'nama': 'Penarikan'},
  ];
  // Key yang digunakan untuk validasi dan manipulasi form
  final _formKey = GlobalKey<FormState>();
  // Service untuk melakukan operasi CRUD terkait transaksi ke API
  final TransactionService _transactionService = TransactionService();
  
  // Controller untuk mengelola input nominal transaksi
  final TextEditingController _nominalController = TextEditingController();
  String? _selectedJenisTransaksi;
  
  bool _isLoading = false;
  String _errorMessage = '';
  
  @override
  void dispose() {
    _nominalController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedJenisTransaksi != null) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final nominal = double.parse(_nominalController.text.replaceAll('.', ''));
        
        final transaction = await _transactionService.createTransaction(
          widget.memberId,
          int.parse(_selectedJenisTransaksi!),
          nominal,
          DateFormat('yyyy-MM-dd').format(DateTime.now())
        );
        // Menampilkan isi transaction di konsol
        print('\nTransaction data: ID=${widget.memberId}, Jenis=${int.parse(_selectedJenisTransaksi!)}, Amount=${nominal}, Date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaksi berhasil disimpan'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, transaction);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = e is DioException
              ? 'Gagal menyimpan transaksi: ${e.response?.data['message'] ?? e.message}'
              : 'Gagal menyimpan transaksi: ${e.toString()}';
        });
      }
    } else if (_selectedJenisTransaksi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih jenis transaksi terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Transaksi ${widget.memberName}'),
        centerTitle: true,
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator())
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
                        onPressed: (){},
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height - 150,
                    child: Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.8,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Jenis Transaksi',
                                  border: OutlineInputBorder(),
                                ),
                                value: _selectedJenisTransaksi,
                                items: _jenisTransaksiList.map((item) {
                                  return DropdownMenuItem<String>(
                                    value: item['id'].toString(),
                                    child: Text('${item['nama']}'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedJenisTransaksi = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Jenis transaksi harus dipilih';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              TextFormField(
                                controller: _nominalController,
                                decoration: const InputDecoration(
                                  labelText: 'Nominal',
                                  border: OutlineInputBorder(),
                                  prefixText: 'Rp ',
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nominal tidak boleh kosong';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 30),
                              
                              ElevatedButton(
                                onPressed: _isLoading ? null : _submitForm,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator()
                                    : const Text(
                                        'Simpan Transaksi',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                              ),
                              
                              if (_errorMessage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Text(
                                    _errorMessage,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}