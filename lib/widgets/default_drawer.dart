import 'package:flutter/material.dart';
import 'package:product_import_app/pages/import_page.dart';
import 'package:product_import_app/pages/login_page.dart';
import 'package:product_import_app/pages/product_list_page.dart';
import 'package:product_import_app/service/app_localizations.dart';
import 'package:product_import_app/service/login.dart';

class DefaultDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Drawer(
      child: ListView(
        children: <Widget>[
          ListTile(
            title: Text(localization.translate("importProducts")),
            leading: Icon(Icons.exit_to_app),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ImportPage(),
                ),
              );
            },
          ),
          ListTile(
            title: Text(localization.translate("modifyProducts")),
            leading: Icon(Icons.exit_to_app),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductListPage(),
                ),
              );
            },
          ),
          ListTile(
            title: Text(localization.translate("logoutButtonLabel")),
            leading: Icon(Icons.exit_to_app),
            onTap: () {
              LoginService().logout(context);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
