import 'package:flutter/material.dart';
import 'package:product_import_app/model/authority.dart';

class AuthorityProvider extends ChangeNotifier {
  List<Authority> _authorities = [];

  List<Authority> get authorities => _authorities;

  bool get hasAuthorities => _authorities.isNotEmpty;

  void setAuthorities(List<Authority> authorities) {
    this._authorities = authorities;

    notifyListeners();
  }
}
