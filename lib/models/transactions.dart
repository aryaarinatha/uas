class TransactionType {
  final int id;
  final String nama;

  TransactionType({
    required this.id,
    required this.nama,
  });

  factory TransactionType.fromJson(Map<String, dynamic> transaksi) {
    // Langsung ambil ID sebagai int
    int id = transaksi['id'] as int? ?? 0;
    
    return TransactionType(
      id: id,
      nama: transaksi['nama'] ?? '',
    );
  }
}

class Transaction {
  final int? id;
  final String tanggal;
  final int jenisTransaksiId;
  final double nominal;
  
  // Relationship data fields
  final TransactionType? jenisTransaksi;
  final Map<String, dynamic>? anggota;

  Transaction({
    this.id,
    required this.tanggal,
    required this.jenisTransaksiId,
    required this.nominal,
    this.jenisTransaksi,
    this.anggota,
  });
    factory Transaction.fromJson(Map<String, dynamic> transaksi) {
    try {
      // Langsung ambil ID sebagai int
      int? id = transaksi['id'] as int?;
      
      // Langsung ambil jenis_transaksi_id sebagai int
      int jenisTransaksiId = transaksi['jenis_transaksi_id'] as int? ?? 0;
      
      return Transaction(
        id: id,
        tanggal: transaksi['tanggal'] ?? DateTime.now().toString().substring(0, 10),
        jenisTransaksiId: jenisTransaksiId,
        nominal: transaksi['nominal'] != null ? double.parse(transaksi['nominal'].toString()) : 0.0,
        jenisTransaksi: transaksi['jenis_transaksi'] != null 
            ? TransactionType.fromJson(transaksi['jenis_transaksi']) 
            : null,
        anggota: transaksi['anggota'],
      );    } catch (e) {
      return Transaction(
        id: transaksi['id'] as int?,
        tanggal: transaksi['tanggal'] ?? DateTime.now().toString().substring(0, 10),
        jenisTransaksiId: transaksi['jenis_transaksi_id'] as int? ?? 0, 
        nominal: 0.0,
      );
    }
  }
    factory Transaction.fromTabungan(Map<String, dynamic> transaksi) {
    try {
      // Langsung ambil trx_id sebagai int
      int trxId = transaksi['trx_id'] as int? ?? 0;
      
      final nama = trxId == 1 ? 'Saldo Awal' : trxId == 2 ? 'Simpanan' : 'Penarikan';
      
      // Langsung ambil ID sebagai int
      int? id = transaksi['id'] as int?;

      return Transaction(
        id: id,
        tanggal: transaksi['trx_tanggal'] ?? DateTime.now().toString(),
        jenisTransaksiId: trxId,
        nominal: transaksi['trx_nominal'] != null ? 
            (transaksi['trx_nominal'] is num ? 
                (transaksi['trx_nominal'] as num).toDouble() : 
                double.tryParse(transaksi['trx_nominal'].toString()) ?? 0.0) : 
            0.0,
        jenisTransaksi: TransactionType(
          id: trxId,
          nama: nama,
        ),
      );    } catch (e) {
      return Transaction(
        id: transaksi['id'] as int?,
        tanggal: transaksi['trx_tanggal'] ?? DateTime.now().toString(),
        jenisTransaksiId: transaksi['trx_id'] as int? ?? 0,
        nominal: transaksi['trx_nominal'] != null ? 
            (transaksi['trx_nominal'] is num ? (transaksi['trx_nominal'] as num).toDouble() : 
            double.tryParse(transaksi['trx_nominal'].toString()) ?? 0.0) : 0.0,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'tanggal': tanggal,
      'jenis_transaksi_id': jenisTransaksiId,
      'nominal': nominal,
    };
  }
}