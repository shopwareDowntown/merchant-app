import 'package:flutter/material.dart';
import 'package:product_import_app/pages/import_page.dart';
import 'package:product_import_app/pages/login_page.dart';
import 'package:product_import_app/service/login.dart';
import 'package:product_import_app/service/shopware_service.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  LoginService _loginService = LoginService();
  Future<bool> _isLoggedIn;

  @override
  initState() {
    super.initState();
    _isLoggedIn = _loginService.isLoggedIn(context).then((loggedIn) {
      if (loggedIn) {
        return loggedIn;
      }
      ShopwareService().getAuthorities(context);

      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _isLoggedIn,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData && snapshot.data) {
          return ImportPage();
        }

        return LoginPage();
      },
    );
  }
}
