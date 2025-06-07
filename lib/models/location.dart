class Kabupaten {
  final int id;
  final String value;

  Kabupaten({
    required this.id,
    required this.value,
  });

  factory Kabupaten.fromJson(Map<String, dynamic> json) {
    return Kabupaten(
      id: json['id'] as int,
      value: json['value'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Kabupaten && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Kecamatan {
  final int id;
  final String value;

  Kecamatan({
    required this.id,
    required this.value,
  });

  factory Kecamatan.fromJson(Map<String, dynamic> json) {
    return Kecamatan(
      id: json['id'] as int,
      value: json['value'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Kecamatan && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Desa {
  final int id;
  final String value;

  Desa({
    required this.id,
    required this.value,
  });

  factory Desa.fromJson(Map<String, dynamic> json) {
    return Desa(
      id: json['id'] as int,
      value: json['value'] as String,
    );
  }
}