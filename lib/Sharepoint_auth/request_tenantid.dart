import 'dart:async';
import 'package:http/http.dart' as http;

class RequestTenantId {
  RequestTenantId();

  Future<String> requestTenantId() async {
    String code;

    http.Response response = await http.get(
      Uri.encodeFull(
          "https://spmautomation.sharepoint.com/sites/SPMConnect/sharepoint.com/_vti_bin/client.svc/"),
      headers: {
        "Authorization": "Bearer",
      },
    );
    // response.headers.forEach((k, v) {
    //   print('Header: $k, value: $v');
    // });
    
    var data = (response.headers["www-authenticate"]);
    List rest = data.split(',');
    print(rest[0]);
    code = rest[0];
    return code;
  }
}
