import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:today_safety/const/value/router.dart';
import 'package:today_safety/ui/route/route_init.dart';
import 'package:today_safety/ui/route/route_login.dart';
import 'package:today_safety/ui/route/route_site_check_list_new.dart';
import 'package:today_safety/ui/route/route_site_detail.dart';
import 'package:today_safety/ui/route/route_site_new.dart';
import 'package:today_safety/ui/route/route_site_search.dart';
import 'package:today_safety/ui/route/route_verify.dart';

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
        //MyApp.logger.wtf('onUnknownRoute : ${settings.name}');
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
          name: keyRouteLogin,
          page: () => const RouteLogin(),
        ),
        GetPage(
          name: keyRouteVerify,
          page: () => const RouteVerify(),
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
          name: keyRouteSiteCheckListNew,
          page: () => const RouteSiteCheckListNew(),
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
