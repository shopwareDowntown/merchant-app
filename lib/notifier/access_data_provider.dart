import 'package:flutter/material.dart';

class AccessDataChangeNotifier extends ChangeNotifier {
  String _contextToken;
  String _companyName;
  String _companyCover;
  bool _initialized = false;

  bool get hasData => _initialized;

  bool get isLoggedIn => this._contextToken != null;

  String get contextToken => _contextToken;
  String get companyName => _companyName;
  String get companyCover => _companyCover;

  set companyName(String value) {
    this._companyName = value;

    notifyListeners();
  }

  set companyCover(String value) {
    this._companyCover = value;

    notifyListeners();
  }

  void update({
    String contextToken,
  }) {
    this._contextToken = contextToken ?? this._contextToken;

    this._initialized = true;

    notifyListeners();
  }

  void reset() {
    this._contextToken = null;
    this._companyName = null;
    this._companyCover = null;

    this._initialized = false;

    notifyListeners();
  }
}
