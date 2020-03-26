import 'package:flutter/material.dart';
import 'package:product_import_app/notifier/access_data_provider.dart';
import 'package:product_import_app/pages/import_page.dart';
import 'package:product_import_app/service/app_localizations.dart';
import 'package:product_import_app/service/login.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginState createState() {
    return LoginState();
  }
}

class LoginState extends State<LoginPage> {
  LoginService _loginService = LoginService();
  Future<bool> _isLoggedIn;
  bool _isError = false;

  @override
  initState() {
    super.initState();
    _isLoggedIn = _loginService.isLoggedIn(context);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final accessData =
        Provider.of<AccessDataChangeNotifier>(context, listen: false);

    return FutureBuilder(
      future: _isLoggedIn,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData && snapshot.data) {
          return ImportPage();
        }

        final _formKey = GlobalKey<FormState>();

        String _shopUrl = accessData.shopUrl ?? '';
        String _username = '';
        String _password = '';

        return Scaffold(
          appBar: AppBar(
            title: Text(localization.translate("loginPageTitle")),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 42),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                              hintText: "htps://my-store.shopware.store",
                              labelText:
                                  localization.translate("shopUrlLabel")),
                          initialValue: _shopUrl,
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
                        SizedBox(height: 20),
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
                        SizedBox(height: 20),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
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
                                            this.setState(() {
                                              _isError = true;
                                            });

                                            return;
                                          }

                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ImportPage(),
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
                        Visibility(
                          visible: this._isError,
                          child: Container(
                            padding: EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Color(0xFFDE294C)),
                              color: Color(0xFFFBE5EA),
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 2,
                                  child: Icon(
                                    Icons.error_outline,
                                    color: Color(0xFF758CA3),
                                  ),
                                ),
                                Expanded(
                                  flex: 8,
                                  child: Text(
                                    localization.translate("loginError"),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF52667A),
                                    ),
                                    maxLines: 5,
                                  ),
                                ),
                              ],
                            ),
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
        );
      },
    );
  }
}
