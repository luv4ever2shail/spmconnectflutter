import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:spmconnectapp/Sharepoint_auth/config.dart';
import 'package:spmconnectapp/Sharepoint_auth/tenantid_request.dart';
import 'package:spmconnectapp/Sharepoint_auth/token.dart';

class RequestToken {
  final Config config;
  TokenRequestDetails _tokenRequest;

  RequestToken(this.config);

  Future<Token> requestToken(String code) async {
    _generateTokenRequest(code);
    return await _sendTokenRequest(_tokenRequest.params, _tokenRequest.headers);
  }

  Future<Token> _sendTokenRequest(
      Map<String, String> params, Map<String, String> headers) async {
    Response response =
        await post("${_tokenRequest.url}", body: params, headers: headers);
    Map<String, dynamic> tokenJson = json.decode(response.body);
    Token token = new Token.fromJson(tokenJson);
    return token;
  }

  void _generateTokenRequest(String code) {
    _tokenRequest = new TokenRequestDetails(config, code);
  }
}
