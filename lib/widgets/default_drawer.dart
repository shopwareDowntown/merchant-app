import 'package:downtown_merchant_app/icon/shopware_icons.dart';
import 'package:downtown_merchant_app/notifier/access_data_provider.dart';
import 'package:downtown_merchant_app/pages/import_page.dart';
import 'package:downtown_merchant_app/pages/product_list_page.dart';
import 'package:downtown_merchant_app/pages/start_page.dart';
import 'package:downtown_merchant_app/service/app_localizations.dart';
import 'package:downtown_merchant_app/service/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                      "${Provider.of<AccessDataChangeNotifier>(context).companyName}",
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
                color: Theme.of(context).accentColor,
                textColor: Theme.of(context).accentColor,
                borderSide: BorderSide(color: Theme.of(context).accentColor),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(
                    children: [
                      Icon(
                        ShopwareIcons.plus_circle,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        localization.translate('importProducts'),
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
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
                textColor: Theme.of(context).primaryTextTheme.headline.color,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(
                    children: [
                      Icon(
                        ShopwareIcons.file_edit,
                        color:
                            Theme.of(context).primaryTextTheme.headline.color,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        localization.translate('modifyProducts'),
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
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
                  color: _lighten(Theme.of(context).accentColor, .35),
                  textColor: Theme.of(context).accentColor,
                  icon: Icon(ShopwareIcons.logout),
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

  Color _lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
