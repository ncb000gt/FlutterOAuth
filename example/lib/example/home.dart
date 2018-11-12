import 'package:flutter/material.dart';
import 'package:flutter_oauth/lib/flutter_auth.dart';
import 'package:flutter_oauth/lib/model/config.dart';
import 'package:flutter_oauth/lib/oauth.dart';
import 'package:flutter_oauth/lib/token.dart';

void main() => runApp(FlutterView());

class FlutterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter OAuth',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: Main(),
    );
  }
}

class Main extends StatefulWidget {
  @override
  MainState createState() => MainState();
}

class MainState extends State<Main> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Center(
              child: RaisedButton(
                child: Text("Authorise"),
                onPressed: () => authorise(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  authorise() async {
    final OAuth flutterOAuth = FlutterOAuth(
      Config(
          "https://www.strava.com/oauth/authorize",
          "https://www.strava.com/oauth/token",
          "CLIENT_ID",
          "CLIENT_SECRET",
          "http://localhost:8080",
          "code"),
    );
    Token token = await flutterOAuth.performAuthorization();
    var alert = AlertDialog(
      title: Text("Access Token"),
      content: Text(token.accessToken),
    );
    showDialog(
      context: context,
      builder: (context) => alert,
    );
  }
}
