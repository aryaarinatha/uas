import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/member_service.dart';
import 'package:dio/dio.dart';
import '../services/transaction_service.dart';
import '../services/location_service.dart' as loc_service;
import '../models/location.dart';

class CreateAnggotaPage extends StatefulWidget {
  final List<int> existingNomorInduks;

  const CreateAnggotaPage({super.key, required this.existingNomorInduks});

  @override
  State<CreateAnggotaPage> createState() => _CreateAnggotaPageState();
}

class _CreateAnggotaPageState extends State<CreateAnggotaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomorIndukController = TextEditingController();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _tglLahirController = TextEditingController();
  final _teleponController = TextEditingController();
  final _saldoAwalController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  final _memberService = MemberService();
  final loc_service.LocationService _locationService = loc_service.LocationService();
  List<Kabupaten> _kabupatenList = [];
  Kabupaten? _selectedKabupaten;
  List<Kecamatan> _kecamatanList = [];
  Kecamatan? _selectedKecamatan;
  List<Desa> _desaList = [];
  Desa? _selectedDesa;

  @override
  void dispose() {
    _nomorIndukController.dispose();
    _namaController.dispose();
    _alamatController.dispose();
    _tglLahirController.dispose();
    _teleponController.dispose();
    _saldoAwalController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchKabupaten();
  }

  Future<void> _fetchKabupaten() async {
    try {
      final kabupaten = await _locationService.getKabupaten();
      setState(() {
        _kabupatenList = kabupaten;
        _selectedKabupaten = null;
        _kecamatanList = [];
        _selectedKecamatan = null;
        _desaList = [];
        _selectedDesa = null;
      });
    } catch (e) {
      // Optional: handle error
    }
  }

  Future<void> _fetchKecamatan(int kabupatenId) async {
    try {
      final kecamatan = await _locationService.getKecamatan(kabupatenId);
      setState(() {
        _kecamatanList = kecamatan;
        _selectedKecamatan = null;
        _desaList = [];
        _selectedDesa = null;
      });
      if (kecamatan.isEmpty) {
        setState(() {
          _errorMessage = 'Tidak ada kecamatan untuk kabupaten ini.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mengambil data kecamatan: '
            '${e is DioException ? e.message : e.toString()}';
      });
    }
  }

  Future<void> _fetchDesa(int kecamatanId) async {
    try {
      final desa = await _locationService.getDesa(kecamatanId);
      setState(() {
        _desaList = desa;
        _selectedDesa = null;
      });
    } catch (e) {
      // Optional: handle error
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final nomorInduk = int.parse(_nomorIndukController.text);

      Map<String, dynamic> data = {
        'nomor_induk': nomorInduk,
        'nama': _namaController.text,
        'alamat': _alamatController.text,
        'tgl_lahir': _tglLahirController.text,
        'telepon': _teleponController.text,
        'prov_id': 1,
        'kab_id': _selectedKabupaten?.id,
        'kec_id': _selectedKecamatan?.id,
        'desa_id': _selectedDesa?.id,
      };

      final int memberId = await _memberService.createMember(data);
      await TransactionService().createTransaction(
        memberId,
        1, // Assuming 1 is the ID for "Setoran Awal"
        double.parse(_saldoAwalController.text),
        DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        if (e is DioException) {
          _errorMessage = 'Error: ${e.response?.data['message'] ?? e.message}';
        } else {
          _errorMessage = 'Error: ${e.toString()}';
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _tglLahirController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Anggota')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                TextFormField(
                  controller: _nomorIndukController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Induk',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor Induk wajib diisi';
                    }
    
                    // Check if nomor induk already exists in the list passed from parent
                    final int nomorInduk = int.parse(value);
                    if (widget.existingNomorInduks.contains(nomorInduk)) {
                      return 'Nomor Induk sudah digunakan';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Nama wajib diisi'
                              : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _alamatController,
                  decoration: const InputDecoration(
                    labelText: 'Alamat',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Alamat wajib diisi'
                              : null,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<Kabupaten>(
                  value: _selectedKabupaten,
                  items: [
                    const DropdownMenuItem<Kabupaten>(
                      value: null,
                      child: Text('Pilih Kabupaten'),
                    ),
                    ..._kabupatenList.map((kab) => DropdownMenuItem(
                      value: kab,
                      child: Text(kab.value),
                    ))
                  ],
                  onChanged: (value) async {
                    print('DEBUG: Pilih kabupaten value: $value, id: \'${value?.id}\'');
                    setState(() {
                      _selectedKabupaten = value;
                      _selectedKecamatan = null;
                      _selectedDesa = null;
                      _kecamatanList = [];
                      _desaList = [];
                    });
                    if (value != null) {
                      await _fetchKecamatan(value.id);
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Kabupaten',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null ? 'Kabupaten wajib dipilih' : null,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<Kecamatan>(
                  value: _selectedKecamatan,
                  items: [
                    const DropdownMenuItem<Kecamatan>(
                      value: null,
                      child: Text('Pilih Kecamatan'),
                    ),
                    ..._kecamatanList.map((kec) => DropdownMenuItem(
                      value: kec,
                      child: Text(kec.value),
                    ))
                  ],
                  onChanged: _kecamatanList.isEmpty
                      ? null
                      : (value) async {
                          print('DEBUG: Pilih kecamatan value: $value, id: \'${value?.id}\'');
                          setState(() {
                            _selectedKecamatan = value;
                            _selectedDesa = null;
                            _desaList = [];
                          });
                          if (value != null) {
                            await _fetchDesa(value.id);
                          }
                        },
                  decoration: const InputDecoration(
                    labelText: 'Kecamatan',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null ? 'Kecamatan wajib dipilih' : null,
                  disabledHint: const Text('Pilih kabupaten dulu'),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<Desa>(
                  value: _selectedDesa,
                  items: [
                    const DropdownMenuItem<Desa>(
                      value: null,
                      child: Text('Pilih Desa'),
                    ),
                    ..._desaList.map((desa) => DropdownMenuItem(
                      value: desa,
                      child: Text(desa.value),
                    ))
                  ],
                  onChanged: _desaList.isEmpty
                      ? null
                      : (value) {
                          setState(() {
                            print('DEBUG: Pilih desa value: $value, id: \'${value?.id}\'');
                            _selectedDesa = value;
                          });
                        },
                  decoration: const InputDecoration(
                    labelText: 'Desa',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null ? 'Desa wajib dipilih' : null,
                  disabledHint: const Text('Pilih kecamatan dulu'),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _tglLahirController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Lahir',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: _selectDate,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Tanggal lahir wajib diisi'
                              : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _teleponController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telepon',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Telepon wajib diisi';
                    }
                    if (value.length < 10 || value.length > 13) {
                      return 'Telepon harus 10-13 digit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Saldo Awal',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _saldoAwalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Saldo Awal',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Saldo awal wajib diisi';
                    }
                    if (double.parse(value) < 100000) {
                      return 'Saldo awal minimal Rp 100.000';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                const SizedBox(height: 35),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
