import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isBusy = false;
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  String _codeVerifier;
  String _authorizationCode;
  String _refreshToken;
  String _accessToken;
  final TextEditingController _authorizationCodeTextController =
      TextEditingController();
  final TextEditingController _accessTokenTextController =
      TextEditingController();
  final TextEditingController _accessTokenExpirationTextController =
      TextEditingController();

  final TextEditingController _idTokenTextController = TextEditingController();
  final TextEditingController _refreshTokenTextController =
      TextEditingController();
  String _userInfo = '';

  final String _clientId = 'native.code';
  final String _redirectUrl = 'io.identityserver.demo:/oauthredirect';
  // has to change that each time ngrok is ran
  final String _issuer = 'https://d0447994.ngrok.io/';
  final String _discoveryUrl =
      'https://d0447994.ngrok.io/.well-known/openid-configuration';
  final List<String> _scopes = <String>[
    'openid',
    'profile',
    'email',
    'offline_access',
    'api'
  ];

  final AuthorizationServiceConfiguration _serviceConfiguration =
      AuthorizationServiceConfiguration(
          'https://d0447994.ngrok.io/connect/authorize',
          'https://d0447994.ngrok.io/connect/token');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Visibility(
                visible: _isBusy,
                child: const LinearProgressIndicator(),
              ),
              RaisedButton(
                child: const Text('Sign in with no code exchange'),
                onPressed: _signInWithNoCodeExchange,
              ),
              RaisedButton(
                child: const Text('Exchange code'),
                onPressed: _authorizationCode != null ? _exchangeCode : null,
              ),
              RaisedButton(
                child: const Text('Sign in with auto code exchange'),
                onPressed: _signInWithAutoCodeExchange,
              ),
              RaisedButton(
                child: const Text('Refresh token'),
                onPressed: _refreshToken != null ? _refresh : null,
              ),
              const Text('authorization code'),
              TextField(
                controller: _authorizationCodeTextController,
              ),
              const Text('access token'),
              TextField(
                controller: _accessTokenTextController,
              ),
              const Text('access token expiration'),
              TextField(
                controller: _accessTokenExpirationTextController,
              ),
              const Text('id token'),
              TextField(
                controller: _idTokenTextController,
              ),
              const Text('refresh token'),
              TextField(
                controller: _refreshTokenTextController,
              ),
              const Text('test api results'),
              Text(_userInfo),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    try {
      _setBusyState();
      final TokenResponse result = await _appAuth.token(TokenRequest(
          _clientId, _redirectUrl,
          refreshToken: _refreshToken,
          discoveryUrl: _discoveryUrl,
          scopes: _scopes));
      _processTokenResponse(result);
      await _testApi(result);
    } catch (_) {
      _clearBusyState();
    }
  }

  Future<void> _exchangeCode() async {
    try {
      _setBusyState();
      final TokenResponse result = await _appAuth.token(TokenRequest(
          _clientId, _redirectUrl,
          authorizationCode: _authorizationCode,
          discoveryUrl: _discoveryUrl,
          codeVerifier: _codeVerifier,
          scopes: _scopes));
      _processTokenResponse(result);
      await _testApi(result);
    } catch (_) {
      _clearBusyState();
    }
  }

  Future<void> _signInWithNoCodeExchange() async {
    try {
      _setBusyState();
      // use the discovery endpoint to find the configuration
      final AuthorizationResponse result = await _appAuth.authorize(
        AuthorizationRequest(_clientId, _redirectUrl,
            discoveryUrl: _discoveryUrl, scopes: _scopes, loginHint: 'bob'),
      );

      // or just use the issuer
      // var result = await _appAuth.authorize(
      //   AuthorizationRequest(
      //     _clientId,
      //     _redirectUrl,
      //     issuer: _issuer,
      //     scopes: _scopes,
      //   ),
      // );
      if (result != null) {
        _processAuthResponse(result);
      }
    } catch (_) {
      _clearBusyState();
    }
  }

  Future<void> _signInWithAutoCodeExchange() async {
    try {
      _setBusyState();

      // show that we can also explicitly specify the endpoints rather than getting from the details from the discovery document
      final AuthorizationTokenResponse result =
          await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(_clientId, _redirectUrl,
            serviceConfiguration: _serviceConfiguration, scopes: _scopes),
      );

      // this code block demonstrates passing in values for the prompt parameter. in this case it prompts the user login even if they have already signed in. the list of supported values depends on the identity provider
      // final AuthorizationTokenResponse result = await _appAuth.authorizeAndExchangeCode(
      //   AuthorizationTokenRequest(_clientId, _redirectUrl,
      //       serviceConfiguration: _serviceConfiguration,
      //       scopes: _scopes,
      //       promptValues: ['login']),
      // );

      if (result != null) {
        _processAuthTokenResponse(result);
        await _testApi(result);
      }
    } catch (_) {
      _clearBusyState();
    }
  }

  void _clearBusyState() {
    setState(() {
      _isBusy = false;
    });
  }

  void _setBusyState() {
    setState(() {
      _isBusy = true;
    });
  }

  void _processAuthTokenResponse(AuthorizationTokenResponse response) {
    setState(() {
      _accessToken = _accessTokenTextController.text = response.accessToken;
      _idTokenTextController.text = response.idToken;
      _refreshToken = _refreshTokenTextController.text = response.refreshToken;
      _accessTokenExpirationTextController.text =
          response.accessTokenExpirationDateTime?.toIso8601String();
    });
  }

  void _processAuthResponse(AuthorizationResponse response) {
    setState(() {
      // save the code verifier as it must be used when exchanging the token
      _codeVerifier = response.codeVerifier;
      _authorizationCode =
          _authorizationCodeTextController.text = response.authorizationCode;
      _isBusy = false;
    });
  }

  void _processTokenResponse(TokenResponse response) {
    setState(() {
      _accessToken = _accessTokenTextController.text = response.accessToken;
      _idTokenTextController.text = response.idToken;
      _refreshToken = _refreshTokenTextController.text = response.refreshToken;
      _accessTokenExpirationTextController.text =
          response.accessTokenExpirationDateTime?.toIso8601String();
    });
  }

  Future<void> _testApi(TokenResponse response) async {
    print('testing api');
    try
    {
      HttpClient client = new HttpClient();
    client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
  // this is hack just to get the data from API!
    
    HttpClientRequest request = await client.getUrl(Uri.parse('http://10.0.2.2:5001/weatherforecast'));
    request.headers.set('Authorization', 'Bearer $_accessToken'); 
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    setState(() {

      _userInfo = response.statusCode == 200 ? reply: '';
      _isBusy = false;
    });
    } catch(e)
    {
      print(e);
    }
    
  }
}