class ModelEmergencySms {
  final DateTime dateTime;
  final String id;
  final String locationId;
   String locationName;
  final String msg;
  bool isNearRegion; //내가 속한 지역이라면

  ModelEmergencySms({
    required this.dateTime,
    required this.id,
    required this.locationId,
    required this.locationName,
    required this.msg,
    required this.isNearRegion,

  });
}
