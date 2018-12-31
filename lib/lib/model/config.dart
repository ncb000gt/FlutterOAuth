class Config {
  final String authorizationUrl;
  final String tokenUrl;
  final String clientId;
  final String clientSecret;
  final String redirectUri;
  final String responseType;
  final String contentType;
  final String redirectedHtml;
  final bool forceWebView;
  final bool forceSafariVC;
  final bool enableJavaScript;
  final Map<String, String> parameters;
  final Map<String, String> headers;
  final String certFile;
  final String keyFile;
  final String keyPassword;

  Config(
    this.authorizationUrl,
    this.tokenUrl,
    this.clientId,
    this.clientSecret,
    this.redirectUri,
    this.responseType,
		{
			this.contentType = 'application/json',
			this.parameters,
			this.headers,
			this.certFile,
			this.keyFile,
			this.keyPassword,
			this.redirectedHtml,
			this.forceWebView,
			this.forceSafariVC,
			this.enableJavaScript,
		}
	);
}
