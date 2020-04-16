import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';


class LoginPage extends StatelessWidget {

  final void Function(GoogleSignInAccount user, String idToken, String accessToken) _setUser;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
  clientId: 'mobileapp-1586697250135'
);

  Future<void> _handleSignIn() async {
  try {
    var result = await this._googleSignIn.signIn();
    var key = await result.authentication;
    
    this._setUser(this._googleSignIn.currentUser, key.idToken, key.accessToken);
  } catch (error) {
    print(error);
  }
}
  LoginPage(this._setUser);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log into app'),
      ),
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Login into app using:',
              ),
              RaisedButton(
                child: Text('Google Account'), 
                onPressed: (){
                  this._handleSignIn();
                },
              ),
              RaisedButton(
                child: Text('Go to main screen'), 
                onPressed: (){
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      
    );
  } 
}