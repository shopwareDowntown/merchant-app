import 'package:downtown_merchant_app/icon/shopware_icons.dart';
import 'package:downtown_merchant_app/model/authority.dart';
import 'package:downtown_merchant_app/notifier/authority_provider.dart';
import 'package:downtown_merchant_app/pages/import_page.dart';
import 'package:downtown_merchant_app/service/app_localizations.dart';
import 'package:downtown_merchant_app/service/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
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
  final _authorityFocus = FocusNode();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  Authority _authority;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final authorityProvider =
        Provider.of<AuthorityProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate("loginPageTitle")),
        titleSpacing: 40,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(ShopwareIcons.shopware),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 42),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        DropdownButtonFormField(
                          value: _authority,
                          hint: Text(localization.translate("authorityLabel")),
                          items: authorityProvider.authorities
                              .map<DropdownMenuItem<Authority>>((authority) {
                            return DropdownMenuItem<Authority>(
                              value: authority,
                              child: Text(authority.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _authority = value;
                            });
                            _fieldFocusChange(
                              context,
                              _authorityFocus,
                              _usernameFocus,
                            );
                          },
                          isExpanded: true,
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16),
                          ),
                          validator: (Authority value) {
                            if (value == null) {
                              return localization
                                  .translate("authorityValidationEmpty");
                            }

                            return null;
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
                          keyboardType: TextInputType.emailAddress,
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
                                child: Icon(
                                  ShopwareIcons.key,
                                  color: Color(0xFF758CA3),
                                ),
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
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
                                Icon(
                                  ShopwareIcons.times_hexagon,
                                  color: Color(0xFF758CA3),
                                ),
                                SizedBox(width: 14),
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
        _authority,
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
