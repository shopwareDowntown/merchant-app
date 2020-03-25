import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  Future<bool> login(String shopUrl, String username, String password) async {
    while (shopUrl.endsWith("/")) {
      shopUrl = shopUrl.substring(0, shopUrl.length -1);
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

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.containsKey("accessToken");
  }
}