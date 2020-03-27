import 'package:flutter/material.dart';
import 'package:product_import_app/pages/import_page.dart';
import 'package:product_import_app/pages/product_list_page.dart';
import 'package:product_import_app/pages/start_page.dart';
import 'package:product_import_app/service/app_localizations.dart';
import 'package:product_import_app/service/login.dart';

class DefaultDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Drawer(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            FittedBox(
              fit: BoxFit.fitWidth,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.person,
                      size: 50,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'TODO, merchant name?',
                      style: Theme.of(context).textTheme.headline,
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              thickness: 2,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: OutlineButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImportPage(),
                    ),
                  );
                },
                textColor: Theme.of(context).accentColor,
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: Theme.of(context).accentColor,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      localization.translate('importProducts'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: OutlineButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductListPage(),
                    ),
                  );
                },
                textColor: Theme.of(context).accentColor,
                child: Row(
                  children: [
                    Icon(
                      Icons.local_parking, // TODO
                      color: Theme.of(context).accentColor,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      localization.translate('modifyProducts'),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: RaisedButton.icon(
                  label: Text(
                    localization.translate("logoutButtonLabel"),
                  ),
                  color: Theme.of(context).accentColor.withOpacity(0.1),
                  textColor: Theme.of(context).accentColor,
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    LoginService().logout(context);

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StartPage(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
