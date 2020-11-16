import 'package:flutter/material.dart';
import 'package:hello_me/user_repository.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'alert.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email;
  String _password;
  String _confirmed_password;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRepository>(builder: (context, user, _) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: ListView(children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 50, right: 50),
                child: Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                      'Welcome to Startup Names Generator, please log in below'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 50, right: 50),
                child: Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  child: TextField(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    onChanged: (input) => _email = input,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      fillColor: Colors.black,
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 50, right: 50),
                child: Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  child: TextField(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    onChanged: (input) => _password = input,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              if (user.status == Status.Authenticating)
                Padding(
                    padding:
                        const EdgeInsets.only(top: 10, right: 50, left: 50),
                    child: SizedBox(
                      child: LinearProgressIndicator(),
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                    ))
              else
                Padding(
                  padding: const EdgeInsets.only(top: 10, right: 50, left: 50),
                  child: Container(
                    alignment: Alignment.bottomRight,
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: FlatButton(
                      onPressed: () async {
                        bool signed = await user.signIn(_email, _password);
                        if (!signed) {
                          _scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text(
                                  'There was an error logging into the app')));
                        } else {
                          if (user.status == Status.Authenticated) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Log in',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 50, left: 50),
                child: Container(
                  alignment: Alignment.bottomRight,
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.green[900],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: FlatButton(
                    onPressed: () {
                      if (user.status != Status.Authenticating)
                        showBarModalBottomSheet(
                          expand: false,
                          enableDrag: false,
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => Container(
                              alignment: Alignment.topCenter,
                              height: 170,
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 1,
                                          bottom: 2,
                                          left: 50,
                                          right: 50),
                                      child: Text(
                                        'Please confirm your password below:',
                                        style: TextStyle(height: 2),
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.black,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 2,
                                          bottom: 2,
                                          left: 50,
                                          right: 50),
                                      child: Container(
                                        alignment: Alignment.topLeft,
                                        height: 25,
                                        width:
                                            MediaQuery.of(context).size.width +
                                                100,
                                        child: TextField(
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                          onChanged: (input) =>
                                              _confirmed_password = input,
                                          obscureText: true,
                                          decoration: InputDecoration(
                                            border: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.red)),
                                            labelText: 'Password',
                                            labelStyle: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (user.status == Status.Authenticating)
                                      Container(
                                        alignment: Alignment.bottomRight,
                                        height: 40,
                                        width: 120,
                                        child: CircularProgressIndicator(),
                                      )
                                    else
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20,
                                              bottom: 10,
                                              left: 50,
                                              right: 50),
                                          child: Container(
                                              alignment: Alignment.center,
                                              height: 30,
                                              width: 120,
                                              decoration: BoxDecoration(
                                                color: Colors.green[900],
                                                borderRadius:
                                                    BorderRadius.circular(0),
                                              ),
                                              child: FlatButton(
                                                  child: Text('Confirm',
                                                      style: TextStyle(
                                                          fontSize: 15.0,
                                                          color: Colors.white)),
                                                  onPressed: () async {
                                                    bool res = false;
                                                    print('confirmed' +
                                                        _confirmed_password);
                                                    print(
                                                        'password' + _password);
                                                    if (_confirmed_password !=
                                                        _password) {
                                                      showAlertDialog(context,
                                                          'Password must match');
                                                    } else {
                                                      try {
                                                        res =
                                                            await user.add_user(
                                                                _email,
                                                                _password);
                                                      } catch (e) {
                                                        _scaffoldKey
                                                            .currentState
                                                            .showSnackBar(
                                                                SnackBar(
                                                                    content:
                                                                        Text(
                                                                            e)));
                                                      }
                                                      if (!res) {
                                                        _scaffoldKey
                                                            .currentState
                                                            .showSnackBar(SnackBar(
                                                                content: Text(
                                                                    'There was an error logging into the app')));
                                                      } else {
                                                        print(user.status);
                                                        if (user.status ==
                                                            Status
                                                                .Authenticated) {
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context)
                                                              .pop();
                                                        }
                                                      }
                                                    }
                                                  })))
                                  ])),
                        );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'New user? Click to sign up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ]),
      );
    });
  }
}
