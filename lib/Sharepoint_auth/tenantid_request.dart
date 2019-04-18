import 'package:spmconnectapp/Sharepoint_auth/config.dart';

class TokenRequestDetails {
  String url;
  Map<String, String> params;
  Map<String, String> headers;

  TokenRequestDetails(Config config, String code) {
    this.url = config.sharepointtokenUrl;
    this.params = {
      "grant_type": "client_credentials",
      "client_id": config.sharepointClientId,
      "client_secret": config.sharepointClientSecret,
      "resource": config.sharepointResource,
    };
    this.headers = {
      "Accept": "application/json",
      "Content-Type": config.contentType
    };
  }
}
