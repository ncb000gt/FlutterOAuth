import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_oauth/lib/auth_code_information.dart';
import 'package:flutter_oauth/lib/configuration.dart';
import 'package:flutter_oauth/lib/oauth.dart';
import 'package:url_launcher/url_launcher.dart';

class FlutterOAuth extends OAuth {
  final StreamController<String> onCodeListener = StreamController();

  var isBrowserOpen = false;
  var server;
  var onCodeStream;
  var configuration;

  Stream<String> get onCode =>
      onCodeStream ??= onCodeListener.stream.asBroadcastStream();

  FlutterOAuth(Configuration configuration)
      : super(configuration, AuthorizationRequest(configuration)) {
    this.configuration = configuration;
  }

  Future<String> requestCode() async {
    if (shouldRequestCode() && !isBrowserOpen) {
      isBrowserOpen = true;
      server = await createServer();
      listenForServerResponse(server);

      final String urlParams = constructUrlParams();

      closeWebView();
      launch("${requestDetails.url}?$urlParams",
          forceWebView: configuration.forceWebView,
          forceSafariVC: configuration.forceSafariVC,
          enableJavaScript: configuration.enableJavaScript);

      code = await onCode.first;
      close();
    }

    return code;
  }

  void close() {
    if (isBrowserOpen) {
      server.close(force: true);
      closeWebView();
    }
    isBrowserOpen = false;
  }

  Future<HttpServer> createServer() async {
    if (configuration.certFile != null && configuration.keyFile != null) {
      SecurityContext context = new SecurityContext();
      var certString = await rootBundle.loadString(configuration.certFile);
      var keyString = await rootBundle.loadString(configuration.keyFile);
      context.useCertificateChainBytes(utf8.encode(certString));
      context.usePrivateKeyBytes(utf8.encode(keyString),
          password: configuration.keyPassword != null
              ? configuration.keyPassword
              : '');

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

      if ((configuration.redirectedHtml != null) &&
          (configuration.forceWebView != true)) {
        request.response.write(configuration.redirectedHtml);
      }

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
