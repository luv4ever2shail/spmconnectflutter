import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spmconnectapp/sharepoint_auth/helper/token_storage.dart';
import 'package:spmconnectapp/sharepoint_auth/model/config.dart';
import 'package:spmconnectapp/sharepoint_auth/model/token.dart';
import 'package:spmconnectapp/sharepoint_auth/request_token.dart';

class Sharepointauth {
  static SharepointConfig _config;
  Token _token;
  TokenStorage _tokenStorage;
  RequestToken _requestToken;

  factory Sharepointauth(config) {
    if (Sharepointauth._instance == null)
      Sharepointauth._instance = new Sharepointauth._internal(config);
    return _instance;
  }

  static Sharepointauth _instance;

  Sharepointauth._internal(config) {
    Sharepointauth._config = config;
    _tokenStorage = _tokenStorage ?? new TokenStorage();
    _requestToken = new RequestToken(_config);
  }

  Future<void> login() async {
    await _removeOldTokenOnFirstLogin();
    if (!Token.tokenIsValid(_token)) await _performAuthorization();
  }

  Future<String> getAccessToken() async {
    if (!Token.tokenIsValid(_token)) await _performAuthorization();
    return _token.accessToken;
  }

  bool tokenIsValid() {
    // check their is existing token and is valid
    return Token.tokenIsValid(_token);
  }

  Future<void> _performAuthorization() async {
    // load token from cache
    _token = await _tokenStorage.loadTokenToCache();

    if (_token == null) {
      try {
        await _performFullAuthFlow();
      } catch (e) {
        rethrow;
      }
    }
    //save token to cache
    await _tokenStorage.saveTokenToCache(_token);
  }

  Future<void> _performFullAuthFlow() async {
    try {
      // Retrieve the access the token
      _token = await _requestToken.requestToken();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _removeOldTokenOnFirstLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final _keyFreshInstall = "freshInstall";
    if (!prefs.getKeys().contains(_keyFreshInstall)) {
      await logout();
      await prefs.setBool(_keyFreshInstall, false);
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
    _token = null;
    Sharepointauth(_config);
    print("Logged out. Token Cleared.");
  }
}
