import 'package:flutter/cupertino.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:today_safety/ui/route/route_router.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(const RouteRouter()));
}
