class LocalizacaoModel {
  final double latitude;
  final double longitude;
  final String? endereco;
  final DateTime timestamp;

  LocalizacaoModel({
    required this.latitude,
    required this.longitude,
    this.endereco,
    required this.timestamp,
  });

  factory LocalizacaoModel.fromJson(Map<String, dynamic> json) {
    return LocalizacaoModel(
      latitude: json['latitude'],
      longitude: json['longitude'],
      endereco: json['endereco'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'endereco': endereco,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  double distanceTo(LocalizacaoModel other) {
    const double raioTerra = 6371000;
    double dLat = _toRadians(other.latitude - latitude);
    double dLon = _toRadians(other.longitude - longitude);

    double a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(latitude)) *
            _cos(_toRadians(other.latitude)) *
            _sin(dLon / 2) *
            _sin(dLon / 2);
    double c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));

    return raioTerra * c;
  }

  double _toRadians(double degree) => degree * 3.141592653589793 / 180;
  double _sin(double x) => x - x * x * x / 6;
  double _cos(double x) => 1 - x * x / 2;
  double _sqrt(double x) => x > 0 ? x : 0;
  double _atan2(double y, double x) => y / x;
}
