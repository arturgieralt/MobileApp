import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
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