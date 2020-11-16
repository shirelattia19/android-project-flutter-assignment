import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:hello_me/alert.dart';
import 'package:hello_me/user_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'LoginPage.dart';
import 'SnapSheetProfil.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return ChangeNotifierProvider<UserRepository>(
            create: (_) => UserRepository.instance(),
            child: MyApp(),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        primaryColor: Colors.red,
      ),
      home: RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final List<WordPair> _suggestions = <WordPair>[];
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final _saved = Set<WordPair>();
  final TextStyle _biggerFont = const TextStyle(fontSize: 18);
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SnappingSheetController controller = SnappingSheetController();
  double snapValue = 0.0;
  double blurValue = 0.0;
  String user_url = '';
  final firebase_store = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRepository>(builder: (context, user, _) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Startup Name Generator'),
          actions: [
            IconButton(
                icon: Icon(Icons.list),
                onPressed: () {
                  _pushSaved(user);
                }),
            if (user.status == Status.Authenticated)
              IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    _logout(user);
                  })
            else
              IconButton(
                icon: Icon(Icons.login),
                onPressed: () {
                  _login(user);
                },
              ),
          ],
        ),
        body: user.status == Status.Authenticated
            ? _SnapSheetProfil()
            : _buildSuggestions(),
      );
    });
  }

  Future<void> _join_saved(user, Set<WordPair> wp_saved) async {
    CollectionReference user_favorites =
        db.collection('users').doc(user.user.email).collection('favorites');
    _saved.forEach((wp) {
      _addAuth(user_favorites, wp.asPascalCase);
    });
    await user_favorites.get().then((QuerySnapshot querySnapshot) => {
          querySnapshot.docs.forEach((favorite) {
            final match =
                favorite['WordPair'].toString().split(RegExp(r"(?=[A-Z])"));
            WordPair wp =
                WordPair(match[0].toLowerCase(), match[1].toLowerCase());
            wp_saved.add(wp);
          })
        });
    setState(() {
      wp_saved.forEach((element) {
        _saved.add(element);
      });
      auth_get_image(user.user);
      (context as Element).reassemble();
      blurValue = 0;
    });
  }

  void _logout(UserRepository user) {
    user.signOut();
    setState(() {
      _saved.clear();
      (context as Element).reassemble();
    });
  }

  Future<void> _login(user) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return LoginPage();
        },
      ),
    );
    if (user.status == Status.Authenticated) {
      Set<WordPair> wp_saved = <WordPair>{};
      _join_saved(user, wp_saved);
    }
  }

  void _pushSaved(UserRepository user) {
    if (user.status == Status.Authenticated) {
      CollectionReference user_favorites =
          db.collection('users').doc(user.user.email).collection('favorites');
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return StreamBuilder(
                stream: user_favorites.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Scaffold(
                        key: _scaffoldKey,
                        appBar: AppBar(
                          title: Text('Saved Suggestions'),
                        ),
                        body: ListView(
                          children: snapshot.data.docs.map((favorite) {
                            return ListTile(
                              title: Text(favorite['WordPair'],
                                  style: _biggerFont),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_outline),
                                color: Colors.red,
                                onPressed: () {
                                  _removeAuth(
                                      user_favorites, favorite['WordPair']);
                                  final match = favorite['WordPair']
                                      .split(RegExp(r"(?=[A-Z])"));
                                  WordPair wp = WordPair(match[0].toLowerCase(),
                                      match[1].toLowerCase());
                                  setState(() {
                                    _saved.forEach((element) {
                                      print(element.first);
                                      print(element.second);
                                    });
                                    _saved.remove(wp);
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ));
                  }
                });
          },
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            final tiles = _saved.map(
              (WordPair pair) {
                return ListTile(
                  title: Text(
                    pair.asPascalCase,
                    style: _biggerFont,
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline),
                    color: Colors.red,
                    onPressed: () {
                      setState(() {
                        _saved.remove(pair);
                        (context as Element).reassemble();
                      });
                    },
                  ),
                );
              },
            );
            final divided = ListTile.divideTiles(
              context: context,
              tiles: tiles,
            ).toList();
            return Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                title: Text('Saved Suggestions'),
              ),
              body: ListView(children: divided),
            );
          },
        ),
      );
    }
  }

  Future<void> _removeAuth(
      CollectionReference user_favorites, String pair) async {
    String id;
    await user_favorites.get().then((QuerySnapshot querySnapshot) => {
          querySnapshot.docs.forEach((favorite) {
            if (favorite['WordPair'] == pair) {
              id = favorite.id;
              user_favorites.doc(id.toString()).delete();
            }
          })
        });
  }

  Future<void> _addAuth(CollectionReference user_favorites, String pair) async {
    bool flag = false;
    await user_favorites.get().then((QuerySnapshot querySnapshot) => {
          querySnapshot.docs.forEach((doc) {
            if (doc['WordPair'] == pair) {
              flag = true;
            }
          })
        });
    if (!flag) {
      user_favorites.add({'WordPair': pair});
    }
  }

  Widget _buildRow(WordPair pair) {
    return Consumer<UserRepository>(builder: (context, user, _) {
      bool alreadySaved = _saved.contains(pair);
      return ListTile(
        title: Text(
          pair.asPascalCase,
          style: _biggerFont,
        ),
        trailing: Icon(
          alreadySaved ? Icons.favorite : Icons.favorite_border,
          color: alreadySaved ? Colors.red : null,
        ),
        onTap: () {
          if (user.status == Status.Authenticated) {
            CollectionReference user_favorites = db
                .collection('users')
                .doc(user.user.email)
                .collection('favorites');
            if (alreadySaved) {
              _removeAuth(user_favorites, pair.asPascalCase);
            } else {
              _addAuth(user_favorites, pair.asPascalCase);
            }
          }
          setState(() {
            if (!alreadySaved) {
              _saved.add(pair);
            } else {
              _saved.remove(pair);
            }
          });
        },
      );
    });
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return Divider();
          }
          final int index = i ~/ 2;

          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index]);
        });
  }

  Future<void> auth_add_image(String path, User user) async {
    File file = File(path);
    try {
      await firebase_store.ref('${user.email}/avatar.png').putFile(file);
    } on FirebaseException catch (e) {
      showAlertDialog(context, 'Picture upload Error, please try again');
    }
  }

  Future<void> auth_get_image(User user) async {
    try {
      await firebase_store
          .ref('${user.email}/avatar.png')
          .getDownloadURL()
          .then((value) {
        setState(() {
          user_url = value;
          (context as Element).reassemble();
        });
      });
    } on FirebaseException catch (e) {
      showAlertDialog(context, 'Picture download Error, please try again');
      setState(() {
        user_url = "";
        (context as Element).reassemble();
      });
    }
  }

  Widget _SnapSheetProfil() {
    return Consumer<UserRepository>(builder: (context, user, _) {
      return Stack(
        children: [
          _buildSuggestions(),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
            child: SnappingSheet(
              snappingSheetController: controller,
              onSnapBegin: () {
                setState(() {
                  if (controller.currentSnapPosition.positionPixel == 0.0) {
                    blurValue = 0;
                  } else {
                    blurValue = 3.0;
                  }
                });
              },
              onSnapEnd: () {
                setState(() {
                  if (controller.currentSnapPosition.positionPixel == 0.0) {
                    blurValue = 0;
                  } else {
                    blurValue = 3.0;
                  }
                });
              },
              initSnapPosition: SnapPosition(positionPixel: 0),
              snapPositions: [
                SnapPosition(
                    positionPixel: 0,
                    snappingCurve: Curves.elasticIn,
                    snappingDuration: Duration(milliseconds: 200)),
                SnapPosition(
                    positionPixel: 100,
                    snappingCurve: Curves.elasticOut,
                    snappingDuration: Duration(milliseconds: 200)),
              ],
              grabbingHeight: 50,
              grabbing: InkWell(
                  onTap: () {
                    setState(() {
                      if (controller.currentSnapPosition ==
                          controller.snapPositions.first) {
                        controller.snapToPosition(controller.snapPositions.last);
                        blurValue = 3.0;
                      } else {
                        controller.snapToPosition(controller.snapPositions.first);
                        blurValue = 0;
                      }
                    });
                  },
                  child: GrabSection()),
              sheetBelow: SnappingSheetContent(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white70,
                      border: Border(
                          bottom:
                              BorderSide(color: Colors.grey[300], width: 1.0))),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(
                              top: 8,
                              bottom: 12,
                              left: 10,
                              right: 10),
                          child: Material(
                            elevation: 5,
                            shape: CircleBorder(),
                            child: user_url == ""
                                ? CircleAvatar(
                                    backgroundColor: Colors.black,
                                    radius: 30,
                                  )
                                : CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(user_url.toString()),
                                    radius: 30),
                          ),
                        ),
                        Wrap(children: [
                          Container(
                              padding: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 15,
                                  left: 5,
                                  right: 5),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(user.user.email,
                                        style: TextStyle(fontSize: 17.0)),
                                    ButtonTheme(
                                        minWidth: 25.0,
                                        height: 20.0,
                                        child: RaisedButton(
                                          onPressed: () async {
                                            var picture = await ImagePicker()
                                                .getImage(
                                                    source:
                                                        ImageSource.gallery);
                                            setState(() {
                                            });
                                            if (picture == null) {
                                              showAlertDialog(context,
                                                  'You have to select an image.');
                                            } else {
                                              await auth_add_image(
                                                  picture.path,
                                                  user.user);
                                              await auth_get_image(user.user);
                                            }
                                          },
                                          child: const Text('Change Avatar',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              )),
                                          color: Colors.green[900],
                                        )),
                                  ]))
                        ]),
                      ]),
                ),
                heightBehavior: SnappingSheetHeight.fit(),
              ),
            ),
          )
        ],
      );
    });
  }
}
