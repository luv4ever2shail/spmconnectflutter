class Config {
  final String sharepointClientId;
  String sharepointtenantidUrl;
  String sharepointtokenUrl;
  final String sharepointClientSecret;
  final String sharepointSite;
  final String clientId;
  final String responseType;
  final String contentType;
  final String sharepointResource;

  Config(
    this.sharepointClientId,
    this.sharepointClientSecret,
    this.sharepointResource,
    this.sharepointSite,
    this.clientId, {
    this.responseType = "code",
    this.contentType = "application/x-www-form-urlencoded",
  }) {
    this.sharepointtenantidUrl =
        "https://$sharepointSite/sharepoint.com/_vti_bin/client.svc/";
    this.sharepointtokenUrl =
        "https://accounts.accesscontrol.windows.net/$sharepointClientId/tokens/OAuth/2";
  }
}
