import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class JournalScreen extends StatefulWidget {
  final bool track;
  const JournalScreen(this.track, { Key? key }) : super(key: key);

  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController _journalController = TextEditingController();
  User? user;
  DateTime _whichDate = DateTime.now();
  final dateController = TextEditingController();
  bool saved = true;
  String entext = 'Encrypted Text';
  String dectext = 'Decrypted Text';
  var key;
  var prefs;
  bool _isLoading = true;
  String value = "";
  String link = "";

  void encrypt() async {
    final cryptor = new PlatformStringCryptor();
    final encrypted = await cryptor.encrypt(_journalController.text, key);
    setState(() {
      entext = encrypted;
    });
  }
  Future<String>  decrypt() async {
    final cryptor = new PlatformStringCryptor();
    String decrypted = "";
    try {
      decrypted = await cryptor.decrypt(entext, key);
    }
    on MacMismatchException catch(e) {
      debugPrint("An error occurred in decryption");
    }
    return decrypted;
  }


  saveJournalEntry(BuildContext context) {
    // print("Date: " + _whichDate.toString());
    var currentDoc = firestore.collection('users').doc(user?.uid).collection('journal').where('date', isEqualTo: DateFormat("yyyy-MM-dd").format(_whichDate));
    currentDoc.get().then((data) {
      // for(var instance in data.docs) {
      //   instance.reference.set({'date': DateFormat("yyyy-MM-dd").format(DateTime.now()), 'entry': _journalController.text.toString()});
      // }
      if(data.docs.length == 0) {
        firestore.collection('users').doc(user?.uid).collection('journal').doc().set({'date': DateFormat("yyyy-MM-dd").format(_whichDate), 'entry': entext});
        print("New entry");
      }
      else {
        data.docs[0].reference.set({'date': DateFormat("yyyy-MM-dd").format(_whichDate), 'entry': entext});
      }
    });

  }

  @override
  void initState() {
    user = auth.currentUser;
    super.initState();
    SharedPreferences.getInstance().then((value) {
      prefs = value;
      key = prefs.getString('key');
      if(key == null) {
        final cryptor = new PlatformStringCryptor();
        cryptor.generateRandomKey().then((value) {
          key = value;
          prefs.setString('key', key);
          debugPrint("Key: $key");
          var currentDoc = firestore.collection('users').doc(user?.uid).collection('journal').where('date', isEqualTo: DateFormat("yyyy-MM-dd").format(DateTime.now()));
          currentDoc.get().then((data) {
            if(data.docs.length != 0) {
              // debugPrint("In if");
              entext = data.docs[0]['entry'];
              decrypt().then((value) => _journalController.text = value);
            }
            // debugPrint("Not in if");
            setState(() {
              _isLoading = false;
            });
          });
        });
        }
      else{
        // debugPrint("Key: $key");
        var currentDoc = firestore.collection('users').doc(user?.uid).collection('journal').where('date', isEqualTo: DateFormat("yyyy-MM-dd").format(DateTime.now()));
        currentDoc.get().then((data) {
          if(data.docs.length != 0) {
            // debugPrint("In if");
            entext = data.docs[0]['entry'];
            decrypt().then((value) => _journalController.text = value);
          }
          // debugPrint("Not in if");
          setState(() {
            _isLoading = false;
          });
        });
      }
      });
  }

  void changeEntryDate() {
    setState(() {
      var currentDoc = firestore.collection('users').doc(user?.uid).collection('journal').where('date', isEqualTo: DateFormat("yyyy-MM-dd").format(_whichDate));
      currentDoc.get().then((data) {
        if(data.docs.length == 0) {
          _journalController.text = "";
        }
        else {
          entext = data.docs[0]['entry'];
          decrypt().then((value) => _journalController.text = value);
        }
      });
    });
  }

  uploadText() async {
    if(_journalController.text != "") {
      var response = await http.post(Uri.parse('http://192.168.29.157:5000/text'),
        body: {"message": _journalController.text});
      var result = response.body;
      var emotions = jsonDecode(result);
      debugPrint(response.body);
      var angry = emotions['Angry'];
      var fear = emotions['Fear'];
      var happy = emotions['Happy'];
      var sad = emotions['Sad'];
      var surprise = emotions['Surprise'];
      if (angry + fear + happy + sad + surprise == 0) {
        value = " Sorry, the given text could not be analysed";
      }
      else {
        var max = 0.0;
        if(angry > max) {
          // value = "Angry: $angry";
          value = "You seem angry.";
          link = "Would you like to calm your nerves?";
          max = angry;
        }
        if(fear > max) {
          // value = "Fear: $fear";
          value = "Are you afraid of something?";
          link = "Try engaging in some meditation.";
          max = fear;
        }
        if(happy > max) {
          // value = "Happy: $happy";
          value = "Looks like you're happy.";
          link = "Care to listen to some upbeat music?";
          max = happy;
        }
        if(sad > max) {
          // value = "Sad: $sad";
          value = "Something has got you down.";
          link = "Do you want to try some uplifting techniques?";
          max = sad;
        }
        if(surprise > max) {
          // value = "Surprise: $surprise";
          value = "You seem surprised.";
          link = "Want to get balanced?";
          max = surprise;
        }
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.track);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade500,
        title: Text('My Journal'),
        actions: [
          TextButton(
              child: Icon(
                Icons.logout,
                color: Colors.white,
              ),
              onPressed: () {
                FirebaseAuth.instance.signOut();
              }),
        ],
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator(),) : Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 15, right: 15, bottom: 20),
        child: Container(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat("MMMM dd, yyyy").format(_whichDate),
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    IconButton(
                      splashRadius: 25,
                      icon: Icon(Icons.calendar_today,),
                      onPressed: () async {
                        var date =  await showDatePicker(
                          context: context,
                          initialDate:_whichDate,
                          firstDate:DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        setState(() {
                          _whichDate = date!;
                          changeEntryDate();
                        });
                        // dateController.text = date.toString().substring(0,10);
                      },
                    )
                  ],
                ),
                SizedBox(height: 15,),
                Expanded(
                  child: TextField(
                    controller: _journalController,
                    maxLines: 30,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "What's on your mind?",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.grey.shade400
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.grey.shade400
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      // enabledBorder: UnderlineInputBorder(
                      //   borderSide: BorderSide(color: Colors.grey.shade700)
                      // )
                    ),
                    onChanged: (text) {
                      // saveJournalEntry(context);
                      setState(() {
                        saved = false;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ElevatedButton(
                      //   child: Text('Analyse'),
                      //   onPressed: uploadText,
                      // ),
                      widget.track ? Text(value) : Container(),
                      GestureDetector(
                        child: widget.track ? Text(
                          link,
                          style: TextStyle(
                              color: Colors.blue, decoration: TextDecoration.underline),
                        ) : Container(),
                        onTap: null
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      child: Icon(
                          Icons.save
                      ),
                      onPressed: saved ? null : () {
                        uploadText();
                        encrypt();
                        saveJournalEntry(context);
                        setState(() {
                          saved = true;
                        });
                      },
                      foregroundColor: Colors.white,
                      backgroundColor: saved ? Colors.grey.shade300 : Colors.grey.shade700,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}