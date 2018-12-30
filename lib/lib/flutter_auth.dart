import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_oauth/lib/auth_code_information.dart';
import 'package:flutter_oauth/lib/model/config.dart';
import 'package:flutter_oauth/lib/oauth.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class FlutterOAuth extends OAuth {
  final StreamController<String> onCodeListener = StreamController();

  final FlutterWebviewPlugin webView = FlutterWebviewPlugin();

  var isBrowserOpen = false;
  var server;
  var onCodeStream;
  var configuration;

  Stream<String> get onCode =>
      onCodeStream ??= onCodeListener.stream.asBroadcastStream();

  FlutterOAuth(Config configuration)
    : super(configuration, AuthorizationRequest(configuration)) {
    this.configuration = configuration;
  }

  Future<String> requestCode() async {
    if (shouldRequestCode() && !isBrowserOpen) {
      webView.close();
      isBrowserOpen = true;

      server = await createServer();
      listenForServerResponse(server);

      final String urlParams = constructUrlParams();
      webView.onDestroy.first.then((_) => close());

      webView.launch(
        "${requestDetails.url}?$urlParams",
        clearCookies: requestDetails.clearCookies,
      );

      code = await onCode.first;
      close();
    }

    return code;
  }

  void close() {
    if (isBrowserOpen) {
      server.close(force: true);
      webView.close();
    }
    isBrowserOpen = false;
  }

  Future<HttpServer> createServer() async {

    if (configuration.certPath != null && configuration.keyPath != null) {
      SecurityContext context = new SecurityContext();
      var certString = await rootBundle.loadString(configuration.certPath);
      var keyString = await rootBundle.loadString(configuration.keyPath);
      context.useCertificateChainBytes(
        utf8.encode(certString)
      );
      context.usePrivateKeyBytes(
        utf8.encode(keyString),
        password: configuration.keyPW != null ? configuration.keyPW : ''
      );

      return await HttpServer.bindSecure(
        InternetAddress.loopbackIPv4,
        8080,
        context,
        shared: true,
      );
    } else {
      return await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        8080,
        shared: true,
      );
    }
  }

  listenForServerResponse(HttpServer server) {
    server.listen((HttpRequest request) async {
      final uri = request.uri;
      request.response
        ..statusCode = 200
        ..headers.set("Content-Type", ContentType.html.mimeType);

      final code = uri.queryParameters["code"];
      final error = uri.queryParameters["error"];
      await request.response.close();
      if (code != null && error == null) {
        onCodeListener.add(code);
      } else if (error != null) {
        onCodeListener.add(null);
        onCodeListener.addError(error);
      }
    });
  }
}
