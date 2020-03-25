import 'package:flutter/material.dart';
import 'package:product_import_app/pages/import_page.dart';
import 'package:product_import_app/service/app_localizations.dart';
import 'package:product_import_app/service/login.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginState createState() {
    return LoginState();
  }
}

class LoginState extends State<LoginPage> {
  LoginService _loginService = LoginService();
  Future<bool> _isLoggedIn;

  @override
  initState() {
    super.initState();
    _isLoggedIn = _loginService.isLoggedIn(context);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return FutureBuilder(
      future: _isLoggedIn,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData && snapshot.data) {
          return ImportPage();
        }

        final _formKey = GlobalKey<FormState>();

        String _shopUrl = '';
        String _username = '';
        String _password = '';

        return new MaterialApp(
          home: new Scaffold(
            appBar: new AppBar(
              title: new Text(localization.translate("loginPageTitle")),
            ),
            body: new Center(
              child: new Column(
                children: <Widget>[
                  new Container(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            decoration: InputDecoration(
                                hintText: "htps://my-store.shopware.store",
                                labelText:
                                    localization.translate("shopUrlLabel")),
                            validator: (value) {
                              if (value.isEmpty) {
                                return localization
                                    .translate("shopUrlValidationEmpty");
                              }

                              bool _validURL = Uri.parse(value).isAbsolute;
                              if (!_validURL) {
                                return localization
                                    .translate("shopUrlValidationNotValid");
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _shopUrl = value.trim();
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                                labelText:
                                    localization.translate("usernameLabel")),
                            validator: (value) {
                              if (value.isEmpty) {
                                return localization
                                    .translate("usernameValidationEmpty");
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _username = value.trim();
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                                labelText:
                                    localization.translate("passwordLabel")),
                            validator: (value) {
                              if (value.isEmpty) {
                                return localization
                                    .translate("passwordValidationEmpty");
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _password = value.trim();
                            },
                            obscureText: true,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Builder(
                              builder: (BuildContext context) {
                                return RaisedButton(
                                  onPressed: () {
                                    if (_formKey.currentState.validate()) {
                                      _formKey.currentState.save();

                                      _loginService
                                          .login(context, _shopUrl, _username,
                                              _password)
                                          .then((wasSuccessful) {
                                        if (!wasSuccessful) {
                                          Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                localization
                                                    .translate("loginError"),
                                              ),
                                            ),
                                          );

                                          return;
                                        }

                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ImportPage(),
                                          ),
                                        );
                                      });
                                    }
                                  },
                                  child: Text(localization
                                      .translate("loginButtonLabel")),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(8.0),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
