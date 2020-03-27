import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:product_import_app/model/authority.dart';
import 'package:product_import_app/notifier/access_data_provider.dart';
import 'package:product_import_app/notifier/authority_provider.dart';
import 'package:product_import_app/service/shopware_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  static const BASE_URL = 'https://sw6.ovh'; // TODO? Correct url

  Future<bool> login(
    BuildContext context,
    Authority authority,
    String username,
    String password,
  ) async {
    try {
      Response response =
          await Dio().post(BASE_URL + "/sales-channel-api/v1/customer/login",
              data: {
                "username": username,
                "password": password,
              },
              options: Options(
                headers: {"sw-access-key": authority.accessKey},
              ));

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString("authorityId", authority.id);
        await prefs.setString("accessKey", authority.accessKey);
        await prefs.setString(
            "contextToken", response.data["sw-context-token"]);

        Provider.of<AccessDataChangeNotifier>(context, listen: false).update(
          contextToken: response.data["sw-context-token"],
          authority: authority,
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
    await ShopwareService().getAuthorities(context);

    final prefs = await SharedPreferences.getInstance();

    final authorityProvider =
        Provider.of<AuthorityProvider>(context, listen: false);

    accessData.update(
      contextToken: prefs.getString('contextToken'),
      authority: authorityProvider.getById(prefs.getString('authorityId')),
    );

    accessData.companyName = prefs.getString('companyName');

    return prefs.containsKey("contextToken");
  }

  void logout(BuildContext context) async {
    final accessData =
        Provider.of<AccessDataChangeNotifier>(context, listen: false);
    accessData.reset();

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("contextToken");
    await prefs.remove('companyName');
  }
}
