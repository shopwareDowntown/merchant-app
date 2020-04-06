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

        final accessData =
            Provider.of<AccessDataChangeNotifier>(context, listen: false);
        accessData.update(
          contextToken: response.data["sw-context-token"],
        );

        await ShopwareService().loadCompanyInfo(context);
        await prefs.setString("companyName", accessData.companyName);
        await prefs.setString("companyCover", accessData.companyCover);

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
    accessData.companyCover = prefs.getString('companyCover');

    return true;
  }

  Future logout(BuildContext context) async {
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

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("contextToken");
    await prefs.remove('companyName');
    await prefs.remove('companyCover');

    accessData.reset();
  }
}
