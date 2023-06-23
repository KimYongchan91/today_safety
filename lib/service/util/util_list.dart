import 'dart:math';

List<List<T>> getListSlice<T>(List<T> list, int interval) {
  List<T> _listOrigin = [...list];
  List<List<T>> _result = [];

  while (_listOrigin.isNotEmpty) {
    _result.add(_listOrigin.sublist(0, min(interval, _listOrigin.length)));
    _listOrigin.removeRange(0, min(interval, _listOrigin.length));
  }

  return _result;
}