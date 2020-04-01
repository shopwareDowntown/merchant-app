import 'package:downtown_merchant_app/model/authority.dart';
import 'package:flutter/material.dart';

class AuthorityProvider extends ChangeNotifier {
  List<Authority> _authorities = [];

  List<Authority> get authorities => _authorities;

  bool get hasAuthorities => _authorities.isNotEmpty;

  void setAuthorities(List<Authority> authorities) {
    this._authorities = authorities;

    notifyListeners();
  }

  Authority getById(String id) {
    return _authorities.firstWhere((authority) => authority.id == id);
  }
}
