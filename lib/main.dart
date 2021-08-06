import 'package:devicelocale/devicelocale.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:ioc_chatbot/Logics/userProvider.dart';
import 'package:ioc_chatbot/both_apps.dart';
import 'package:provider/provider.dart';

import 'Logics/app_state.dart';
import 'Logics/errorStrings.dart';
import 'Logics/signUpBusinissLogic.dart';
import 'Backend/services/authServices.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );
  Locale locale = await Devicelocale.currentAsLocale;
  print("locale : $locale");
  runApp(
    EasyLocalization(
      startLocale: locale,
      supportedLocales: [
        Locale('ur', 'UR'),
        Locale('en', 'US'),
      ],
      path: 'assets/translations',
      fallbackLocale: Locale('en', 'US'),
      child: MultiProvider(providers: [
        ChangeNotifierProvider(create: (_) => SignUpBusinessLogic()),
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => ErrorString()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthServices.instance(),
        ),
        StreamProvider(
          create: (context) => context.read<AuthServices>().authState,
        )
      ], child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        home: BothApps());
  }
}
