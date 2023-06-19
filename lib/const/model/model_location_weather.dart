class ModelLocationWeather {
  double lat;
  double lng;

  String si;
  String gu;
  String dong;
  String code; //행정 구역 코드 (H)

  ModelLocationWeather({
    required this.lat,
    required this.lng,
    required this.si,
    required this.gu,
    required this.dong,
    required this.code,
  });

  @override
  String toString() {
    return 'lat : $lat\n'
        'lng : $lng\n'
        'si : $si\n'
        'gu : $gu\n'
        'dong : $dong\n'
        'code : $code';
  }
}
