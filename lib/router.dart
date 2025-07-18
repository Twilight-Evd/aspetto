import 'package:bunny/constants/global.dart';
import 'package:bunny/pages/courier/air_courier.dart';
import 'package:bunny/pages/download/index.dart';
import 'package:bunny/pages/online/index.dart';
import 'package:bunny/pages/setting/index.dart';
import 'package:bunny/pages/splash/splash.dart';
import 'package:bunny/providers/download/download.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sharebox/providers/courier/courier.dart';

import 'pages/layout.dart';

CustomTransitionPage myTransitionPage(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation.drive(
          Tween(begin: 0.0, end: 1.0).chain(
            CurveTween(curve: Curves.linear),
          ),
        ),
        child: child,
      );
    },
  );
}

class MyRouter {
  final String name;
  final String path;
  final Page view;

  const MyRouter({
    required this.name,
    required this.path,
    required this.view,
  });

  GoRoute toGoRoute() {
    return GoRoute(
      path: path,
      name: name,
      pageBuilder: (context, state) => view,
    );
  }
}

List<MyRouter> routes = [
  MyRouter(
    name: "video",
    path: '/',
    view: myTransitionPage(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => DownloadCubit(DownloadRepository()),
          ),
          BlocProvider(
            create: (context) => DownloadListCubit(DownloadRepository()),
          )
        ],
        child: DownloadPage(),
      ),
    ),
  ),
  MyRouter(
    name: "browser",
    path: '/browser',
    view: myTransitionPage(BrowserPage()),
  ),
  MyRouter(
    name: "airdrop",
    path: "/airdrop",
    view: myTransitionPage(BlocProvider.value(
      value: CourierBloc(),
      child: AirCourier(),
    )),
  ),
  // MyRouter(
  //   name: "convert",
  //   path: "/convert",
  //   view: myTransitionPage(MyHomePage(
  //       // maxWidth: 500,
  //       )),
  // ),
  MyRouter(
    name: "setting",
    path: "/setting",
    view: myTransitionPage(MenuApp()),
  )
];

final GoRouter router = GoRouter(navigatorKey: rootNavigatorKey, initialLocation: "/splash", routes: [
  GoRoute(
    path: "/splash",
    pageBuilder: (context, state) => myTransitionPage(Splash()),
  ),
  StatefulShellRoute.indexedStack(
    pageBuilder: (context, state, navigationShell) {
      return myTransitionPage(Layout(
        key: Key("layout"),
        child: navigationShell,
      ));
    },
    branches: routes.map((route) {
      return StatefulShellBranch(
        routes: <RouteBase>[route.toGoRoute()],
      );
    }).toList(),
  ),
], observers: []);
