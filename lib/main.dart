import 'package:ez/constant/constant.dart';
import 'package:ez/screens/view/newUI/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';

const iOSLocalizedLabels = false;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  SharedPreferences.getInstance().then(
    (prefs) async {
      runApp(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "EZShield",
          theme: new ThemeData(
              accentColor: Colors.black,
              primaryColor: Colors.black,
              primaryColorDark: Colors.black),
          home: SplashScreen(),
          routes: <String, WidgetBuilder>{
            App_Screen: (BuildContext context) => AppScreen(prefs),
          },
        ),
      );
    },
  );
}
