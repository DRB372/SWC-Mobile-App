import 'package:flutter/material.dart';
import 'rounded_button.dart';
import 'constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'google_map.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:uuid/uuid.dart';



class LoginScreen extends StatefulWidget {

  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

    final formKey = GlobalKey<FormState>();
    final globalKey = GlobalKey<ScaffoldState>();
//    final auth = FirebaseAuth.instance;
    String email, password;
    bool showSpinner = false;
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool _loading = false;

  Future<http.Response> sendData(data) async {
    log('data:$data');

    var url = 'http://192.168.1.11:3000/api/auth/login';
    Map<String, String> headers = {"Content-type": "application/json"};
//    Map<String, String> headers = {"Content-type": "application/json", "Authorization":"Bearer ${token}"};


    return await http.post(url, headers: headers, body: jsonEncode(data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Flexible(
                  child: Hero(
                    tag: Uuid(),
                    child: Container(
                      height: 200.0,
                      child: Image.asset('images/logo.png'),
                    ),
                  ),
                ),
                SizedBox(
                  height: 48.0,
                ),
                TextFormField(
                  controller: emailController,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => Focus.of(context).nextFocus(),
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  validator: (value){
                    if (value.isEmpty){
                      return 'Please enter email';
                    }
                    return null;
                  },
                  onChanged: (value){
                    email = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(hintText: 'Enter your email'),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextFormField(
                  controller: passwordController,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => Focus.of(context).unfocus(),
                  obscureText: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  onChanged: (value){
                    password = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(hintText: 'Enter your password'),
                  validator: (value){
                    if (value.isEmpty){
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 24.0,
                ),
                RoundedButton(
                  title: 'Log In',
                  color: Colors.lightBlueAccent,
                  onPress: () async {

                  setState(() => _loading = true);



                  if (formKey.currentState.validate()) {
                    var formData = {
                      'email': emailController.text,
                      'password': passwordController.text,

    };

                  http.Response resp = await sendData(formData);
                  log('data: $resp');

                  setState(() => _loading = false);
                  if (resp.statusCode == 201) {
                  String message = jsonDecode(resp.body)['message'];
                  showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                  AlertDialog(
                      title: Text('Success!'),
                       content: Text(message),
                  ));

                  Navigator.push(context, MaterialPageRoute(builder: (context) =>MapView()));
                  emailController.clear();
                  passwordController.clear();

                  } else if (resp.statusCode == 400) {
                    String message = jsonDecode(resp.body)['message'];
                    showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            AlertDialog(
                              title: Text('Success!'),
                              content: Text(message),
                            ));

                  }
                  else {
                    Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("Oops! Something went wrong.")));

                  }
                  }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


