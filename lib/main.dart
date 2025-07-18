import 'dart:async';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:bunny/constants/theme.dart';
import 'package:bunny/providers/setting/setting.dart';
import 'package:bunny/services/service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:sharebox/providers/courier/courier.dart';

import 'constants/sizes.dart';
import 'life_cycle.dart';
import 'router.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    await setUp();
  }, (exception, stackTrace) async {});
}

Future<void> setUp() async {
  WidgetsFlutterBinding.ensureInitialized();

  final courierBloc = CourierBloc();
  await Services.initialize(courierBloc);

  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('zh'),
        Locale('en'),
      ],
      path: "assets/langs",
      fallbackLocale: Locale('en'),
      startLocale: Locale('en'),
      saveLocale: true,
      child: MyApp(),
    ),
  );

  doWhenWindowReady(() {
    appWindow.minSize = minSplashWindowSize;
    appWindow.size = minSplashWindowSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SettingCubit(SettingRepository()),
        ),
        BlocProvider.value(value: CourierBloc())
      ],
      child: BlocConsumer<SettingCubit, SettingState>(
        builder: (context, state) {
          return AppLifeCycle(
            child: MaterialApp.router(
              builder: (context, child) {
                return FlutterSmartDialog.init()(context, child);
              },
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: state.model.lang != null
                  ? Locale(state.model.lang!)
                  : context.locale,
              routerConfig: router,
              debugShowCheckedModeBanner: false,
              theme: kShrineTheme,
              // darkTheme: darkTheme,
              // themeMode: state.model.themeMode == null
              //     ? ThemeMode.system
              //     : ThemeMode.values.firstWhere(
              //         (e) => e.toString() == state.model.themeMode,
              //         orElse: () => ThemeMode.system,
              //       ),
              onGenerateTitle: (context) {
                return tr("title");
              },
            ),
          );
        },
        buildWhen: (previous, current) {
          return (previous.model.themeMode != current.model.themeMode ||
              previous.model.lang != current.model.lang);
        },
        listener: (BuildContext context, SettingState state) {
          appWindow.alwaysOnTop = state.model.alwaysOnTop ?? false;
        },
      ),
    );
  }
}
