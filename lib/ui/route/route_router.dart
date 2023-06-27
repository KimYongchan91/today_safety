import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:today_safety/const/value/router.dart';
import 'package:today_safety/ui/route/route_check_list_daily.dart';
import 'package:today_safety/ui/route/route_check_list_detail.dart';
import 'package:today_safety/ui/route/route_init.dart';
import 'package:today_safety/ui/route/route_login.dart';
import 'package:today_safety/ui/route/route_check_list_new.dart';
import 'package:today_safety/ui/route/route_notice_detail.dart';
import 'package:today_safety/ui/route/route_site_detail.dart';
import 'package:today_safety/ui/route/route_site_new.dart';
import 'package:today_safety/ui/route/route_site_search.dart';
import 'package:today_safety/ui/route/route_check_list_check.dart';
import 'package:today_safety/ui/route/route_unknown.dart';
import 'package:today_safety/ui/route/route_user_check_history_detail.dart';

import 'route_main.dart';

class RouteRouter extends StatelessWidget {
  const RouteRouter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TodaySafety',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.white,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      onUnknownRoute: (settings) {
        return GetPageRoute(settings: RouteSettings(name: keyRouteUnknown, arguments: settings.arguments));
      },
      navigatorObservers: const [
        //GetObserver(),
        //FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
      getPages: [
        GetPage(
          name: keyRouteInit,
          page: () => const RouteInit(),
        ),
        GetPage(
          name: keyRouteMain,
          page: () => const RouteMain(),
        ),

        GetPage(
          name: keyRouteUnknown,
          page: () => const RouteUnknown(),
        ),
        GetPage(
          name: keyRouteLogin,
          page: () => const RouteLogin(),
        ),
        GetPage(
          name: keyRouteSiteNew,
          page: () => const RouteSiteNew(),
        ),
        GetPage(
          name: keyRouteSiteSearch,
          page: () => const RouteSiteSearch(),
        ),
        GetPage(
          name: '$keyRouteSiteDetail/:$keySiteId',
          page: () => const RouteSiteDetail(),
        ),
        GetPage(
          name: keyRouteCheckListNew,
          page: () => const RouteCheckListNew(),
        ),
        GetPage(
          name: '$keyRouteCheckListDetail/:$keyCheckListId',
          page: () => const RouteCheckListDetail(),
        ),
        GetPage(
          name: '$keyRouteCheckListDetail/:$keyCheckListId/$keyRouteCheckListCheckWithOutSlash',
          page: () => const RouteCheckListCheck(),
        ),
        GetPage(
          name:
              '$keyRouteCheckListDetail/:$keyCheckListId/$keyRouteCheckListDailyWithOutSlash/:$keyDailyDateFormatted',
          page: () => const RouteCheckListDaily(),
        ),
        GetPage(
          name: '$keyRouteNoticeDetail/:$keyNoticeId',
          page: () => const RouteNoticeDetail(),
        ),

        //
        GetPage(
          name: '$keyRouteUserCheckHistoryDetail/:$keyUserCheckHistoryId',
          page: () => const RouteUserCheckHistoryDetail(),
        ),

        /*  GetPage(
          name: keyRouteWelcome,
          page: () => const RouteWelcome(),
        ),
        GetPage(
          name: keyRouteReviewRequest,
          page: () => const RouteReviewRequest(),
        ),
        GetPage(
          name: keyRouteReviewWaitingResult,
          page: () => const RouteReviewWaitingResult(),
        ),
        GetPage(
          name: keyRouteReviewResult,
          page: () => const RouteReviewResult(),
        ),
        GetPage(
          name: keyRouteLogin,
          page: () => const RouteLogin(),
        ),
        GetPage(
          name: keyRouteJoin,
          page: () => const RouteJoin(),
        ),

        GetPage(
          name: '$keyRouteVoteDetail/:$keyId',
          page: () => const RouteVoteDetail(),
        ),

        GetPage(
          name: '$keyRouteVoteResultDetail/:$keyId',
          page: () => const RouteVoteResultDetail(),
        ),

        GetPage(
          name: keyRouteVoteNew,
          page: () => const RouteVoteNew(),
        ),

        ///계정 관련
        GetPage(
          name: keyRouteAccountModify,
          page: () => const RouteUserDetail(),
        ),

        */ /*GetPage(
          name: keyRouteAppDetail,
          page: () => RouteAppDetail(),
        ),
        GetPage(
          name: '$keyRouteAppDetail/:item',
          page: () => RouteAppDetailItem(),
        ),*/
      ],
      initialRoute: keyRouteInit,
    );
  }
}
