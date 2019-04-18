
class Config {
  
  final String sharepointClientId;
  String tenantidUrl;
  String tokenUrl;
  final String sharepointClientSecret;
  final String sharepointSite;
  final String redirectUri;
  final String responseType;
  final String contentType;
  final String sharepointResource;

  Config(
    this.sharepointClientId,
    this.sharepointClientSecret,
    this.sharepointResource,
    this.sharepointSite, {
    this.redirectUri = "https://login.live.com/oauth20_desktop.srf",
    this.responseType = "code",
    this.contentType = "application/x-www-form-urlencoded",
  }) {
    this.tenantidUrl =
        "https://$sharepointSite/sharepoint.com/_vti_bin/client.svc/";
    this.tokenUrl =
        "https://accounts.accesscontrol.windows.net/$sharepointClientId/tokens/OAuth/2";
  }
}
