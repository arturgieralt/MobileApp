import 'package:flutter/material.dart';
import 'package:mobile_app/screens/login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleSignInAccount _user;
  String _idToken;
  String _accessToken;

  void setUser(GoogleSignInAccount user, String idToken, String accessToken) {
    setState(() {
      _user = user;
      _idToken = idToken;
      _accessToken = accessToken;
    });

    print(idToken);
    print(accessToken);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: 
              AssetImage('lib/assets/icon.png'),
            ),
            Text(
              'Hello ${_user != null ? _user.displayName : 'Guest'}',
              style: Theme.of(context).textTheme.display1,
            ),
            RaisedButton(
              child: Text('Go to Login Page'), 
              onPressed: (){
                  Navigator.push(
                  context,
      
                  MaterialPageRoute(builder: (context) => LoginPage(this.setUser)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
