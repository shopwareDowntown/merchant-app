import 'package:downtown_merchant_app/notifier/access_data_provider.dart';
import 'package:downtown_merchant_app/notifier/authority_provider.dart';
import 'package:downtown_merchant_app/notifier/product_provider.dart';
import 'package:downtown_merchant_app/pages/start_page.dart';
import 'package:downtown_merchant_app/service/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AccessDataChangeNotifier()),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(
          create: (context) => AuthorityProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', 'GB'),
          const Locale('en', 'US'),
          const Locale('de', 'DE'),
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          if (locale == null) {
            return supportedLocales.first;
          }

          // Check if the current device locale is supported
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
          // If the locale of the device is not supported, use the first one
          // from the list (English, in this case).
          return supportedLocales.first;
        },
        theme: ThemeData(
            primaryColor: Color(0xFF0552B5),
            accentColor: Color(0xFF189EFF),
            errorColor: Color(0xFFDE294C),
            primaryTextTheme: TextTheme(
              title: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              headline: TextStyle(
                fontWeight: FontWeight.bold,
                height: 22 / 18,
                fontSize: 18,
                letterSpacing: 0.1,
                color: Color(0xFF4F4F4F),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFD1D9E0)),
              ),
              labelStyle: TextStyle(
                fontSize: 14,
                color: Color(0xFFB3BFCC),
              ),
              hintStyle: TextStyle(
                fontSize: 14,
                color: Color(0xFFB3BFCC),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).accentColor),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFDE294C)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFDE294C)),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            dialogTheme: DialogTheme(
              contentTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                height: 22 / 18,
                letterSpacing: 0.1,
              ),
            ),
            buttonTheme: ButtonThemeData(
              height: 40,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              disabledColor: Color(0xFF607182),
              buttonColor: Theme.of(context).accentColor,
              colorScheme: ColorScheme.dark(),
            ),
            dividerColor: Color(0xC0C4C8),
            backgroundColor: Colors.white),
        home: Material(
          child: StartPage(),
        ),
      ),
    );
  }
}
