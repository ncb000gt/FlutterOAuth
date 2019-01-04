import 'package:flutter_oauth/lib/configuration.dart';

class AuthorizationRequest {
  String url;
  Map<String, String> parameters;
  Map<String, String> headers;
  bool fullScreen;
  bool clearCookies;

  AuthorizationRequest(
    Configuration configuration, {
    bool fullScreen: true,
    bool clearCookies: true,
  }) {
    this.url = configuration.authorizationUrl;
    this.parameters = {
      "client_id": configuration.clientId,
      "response_type": configuration.responseType,
      "redirect_uri": configuration.redirectUri
    };
    if (configuration.parameters != null) {
      this.parameters.addAll(configuration.parameters);
    }
    this.fullScreen = fullScreen;
    this.clearCookies = clearCookies;
    this.headers = configuration.headers;
  }
}
