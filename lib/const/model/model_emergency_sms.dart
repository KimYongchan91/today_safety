class ModelEmergencySms {
  final DateTime dateTime;
  final String id;
  final String locaionId;
  final String locaionName;
  final String msg;

  ModelEmergencySms({
    required this.dateTime,
    required this.id,
    required this.locaionId,
    required this.locaionName,
    required this.msg,
  });
}
