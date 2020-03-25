import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:product_import_app/notifier/access_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  Future<bool> login(
    BuildContext context,
    String shopUrl,
    String username,
    String password,
  ) async {
    while (shopUrl.endsWith("/")) {
      shopUrl = shopUrl.substring(0, shopUrl.length - 1);
    }

    try {
      Response response = await Dio().post(shopUrl + "/api/oauth/token", data: {
        "grant_type": "password",
        "client_id": "administration",
        "scopes": "write",
        "username": username,
        "password": password,
      });

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        prefs.setString("shopUrl", shopUrl);
        prefs.setString("accessToken", response.data["access_token"]);
        prefs.setString("refreshToken", response.data["refresh_token"]);

        Provider.of<AccessDataChangeNotifier>(context, listen: false).init(
          shopUrl: shopUrl,
          accessToken: response.data["access_token"],
          refreshToken: response.data["refresh_token"],
        );

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isLoggedIn(BuildContext context) async {
    final accessData =
        Provider.of<AccessDataChangeNotifier>(context, listen: false);
    if (accessData.hasData && accessData.isLoggedIn) {
      return true;
    }

    final prefs = await SharedPreferences.getInstance();

    Provider.of<AccessDataChangeNotifier>(context, listen: false).init(
      shopUrl: prefs.getString('shopUrl'),
      accessToken: prefs.getString("access_token"),
      refreshToken: prefs.getString("refresh_token"),
    );

    return prefs.containsKey("accessToken");
  }
}
