import 'package:flutter/material.dart';

class AccessDataChangeNotifier extends ChangeNotifier {
  String _accessToken;
  String _refreshToken;
  String _shopUrl;
  bool _initialized = false;

  bool get hasData => _initialized;

  bool get isLoggedIn =>
      this._accessToken != null && this._refreshToken != null;

  String get shopUrl => _shopUrl;

  String get refreshToken => _refreshToken;

  String get accessToken => _accessToken;

  void init({
    String accessToken,
    String refreshToken,
    String shopUrl,
  }) {
    this._accessToken = accessToken ?? this._accessToken;
    this._refreshToken = refreshToken ?? this._refreshToken;
    this._shopUrl = shopUrl ?? this._shopUrl;

    this._initialized = true;

    notifyListeners();
  }
}
