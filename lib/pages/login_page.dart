import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
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
  bool _isError = false;
  bool _isLogginIn = false;
  final _formKey = GlobalKey<FormState>();
  final _shopFocus = FocusNode();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _shopController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final accessData =
        Provider.of<AccessDataChangeNotifier>(context, listen: false);

    _shopController.text = _shopController.text.isEmpty
        ? accessData.shopUrl ?? ''
        : _shopController.text;

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate("loginPageTitle")),
        titleSpacing: 40,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.shop), // TODO: SW-Icon?
          ),
        ],
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
                    // TODO: Replace with select
                    TextFormField(
                      focusNode: _shopFocus,
                      decoration: InputDecoration(
                          hintText: "https://my-store.shopware.store",
                          labelText: localization.translate("shopUrlLabel")),
                      controller: _shopController,
                      textInputAction: TextInputAction.next,
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
                      onFieldSubmitted: (value) {
                        _fieldFocusChange(context, _shopFocus, _usernameFocus);
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      autocorrect: false,
                      focusNode: _usernameFocus,
                      decoration: InputDecoration(
                        labelText: localization.translate("usernameLabel"),
                      ),
                      controller: _usernameController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return localization
                              .translate("usernameValidationEmpty");
                        }

                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) {
                        _fieldFocusChange(
                          context,
                          _usernameFocus,
                          _passwordFocus,
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      focusNode: _passwordFocus,
                      decoration: InputDecoration(
                        labelText: localization.translate("passwordLabel"),
                        suffixIcon: ClipRRect(
                          borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(6),
                          ),
                          child: Container(
                            margin: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: Color(0xFFD1D9E0),
                                ),
                              ),
                              color: Color(0xFFF9FAFB),
                            ),
                            child: Icon(Icons.vpn_key),
                          ),
                        ),
                      ),
                      controller: _passwordController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return localization
                              .translate("passwordValidationEmpty");
                        }

                        return null;
                      },
                      obscureText: true,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: RaisedButton(
                            onPressed: _isLogginIn ? null : submitForm,
                            child: Text(
                              localization.translate("loginButtonLabel"),
                            ),
                          ),
                        ),
                      ],
                    ),
                    AnimatedOpacity(
                      duration: Duration(milliseconds: 200),
                      opacity: this._isError ? 1 : 0,
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
  }

  void submitForm() async {
    if (_isLogginIn) {
      return;
    }

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      setState(() {
        _isLogginIn = true;
        _isError = false;
      });

      final wasSuccessful = await _loginService.login(
        context,
        _shopController.text,
        _usernameController.text,
        _passwordController.text,
      );
      if (!wasSuccessful) {
        this.setState(() {
          _isError = true;
          _isLogginIn = false;
        });

        return;
      }

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ImportPage(),
        ),
      );
    }
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
