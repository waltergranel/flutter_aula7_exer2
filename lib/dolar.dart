class Dolar {
  String? dolarHigh;
  String? dolarLow;
  String data = '';

  Dolar({
    this.dolarHigh,
    this.dolarLow,
  });

  Dolar.fromJson(Map<String, dynamic> json) {
    dolarHigh = json['high'];
    dolarLow = json['low'];
  }
}