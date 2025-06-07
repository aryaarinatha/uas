class Member {
  final int id;
  final int nomorInduk;
  final String nama;
  final String alamat;
  final String tglLahir;
  final String telepon;
  final String? imageUrl;
  final int statusAktif;
  final int kabId;
  final int kecId;
  final int desaId;

  Member({
    required this.id,
    required this.nomorInduk,
    required this.nama,
    required this.alamat,
    required this.tglLahir,
    required this.telepon,
    this.imageUrl,
    required this.statusAktif,
    required this.kabId,
    required this.kecId,
    required this.desaId,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      nomorInduk: json['nomor_induk'],
      nama: json['nama'],
      alamat: json['alamat'],
      tglLahir: json['tgl_lahir'],
      telepon: json['telepon'],
      imageUrl: json['image_url'],
      statusAktif: json['status_aktif'],
      kabId: json['kab_id'],
      kecId: json['kec_id'],
      desaId: json['desa_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomor_induk': nomorInduk,
      'nama': nama,
      'alamat': alamat,
      'tgl_lahir': tglLahir,
      'telepon': telepon,
      'image_url': imageUrl,
      'status_aktif': statusAktif,
      'kab_id': kabId,
      'kec_id': kecId,
      'desa_id': desaId,
    };
  }
}
