import 'package:dio/dio.dart';
import 'package:downtown_merchant_app/notifier/access_data_provider.dart';
import 'package:downtown_merchant_app/service/shopware_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  static const BASE_URL = ShopwareService.BASE_URL;

  Future<bool> login(
    BuildContext context,
    String username,
    String password,
  ) async {
    try {
      Response response = await Dio().post(
        BASE_URL + "/merchant-api/v1/login",
        data: {
          "email": username,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString(
            "contextToken", response.data["sw-context-token"]);

        Provider.of<AccessDataChangeNotifier>(context, listen: false).update(
          contextToken: response.data["sw-context-token"],
        );

        final companyName = await ShopwareService().getCompanyName(context);
        await prefs.setString("companyName", companyName);

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

    if (!prefs.containsKey('contextToken')) {
      return false;
    }

    accessData.update(
      contextToken: prefs.getString('contextToken'),
    );

    accessData.companyName = prefs.getString('companyName');

    return true;
  }

  void logout(BuildContext context) async {
    final accessData =
        Provider.of<AccessDataChangeNotifier>(context, listen: false);

    try {
      await Dio().post(
        BASE_URL + "/merchant-api/v1/logout",
        options: Options(headers: {
          'sw-context-token': accessData.contextToken,
        }),
      );
    } catch (e) {
      // ignore
    }

    accessData.reset();

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("contextToken");
    await prefs.remove('companyName');
  }
}
