class Token {
  String accessToken;
  String tokenType;
  String refreshToken;
  String scope;

  Token();

  factory Token.fromJson(Map<String, dynamic> json) =>
      Token.fromMap(json);

  Map toMap() => Token.toJsonMap(this);

  @override
  String toString() => Token.toJsonMap(this).toString();

  static Map toJsonMap(Token model) {
    Map ret = Map();
    if (model != null) {
      if (model.accessToken != null) {
        ret["access_token"] = model.accessToken;
      }

      if (model.tokenType != null) {
        ret["token_type"] = model.tokenType;
      }

      if (model.refreshToken != null) {
        ret["refresh_token"] = model.refreshToken;
      }

      if (model.scope != null) {
        ret["scope"] = model.scope;
      }
    }
    return ret;
  }

  static Token fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    Token model = Token();
    model.accessToken = map["access_token"];
    model.tokenType = map["token_type"];
    model.refreshToken = map["refresh_token"];
    model.scope = map["scope"];
    return model;
  }
}
