import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({ Key? key }) : super(key: key);

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

  saveJournalEntry(BuildContext context) {
    // print("Date: " + _whichDate.toString());
    var currentDoc = firestore.collection('users').doc(user?.uid).collection('journal').where('date', isEqualTo: DateFormat("yyyy-MM-dd").format(_whichDate));
    currentDoc.get().then((data) {
      // for(var instance in data.docs) {
      //   instance.reference.set({'date': DateFormat("yyyy-MM-dd").format(DateTime.now()), 'entry': _journalController.text.toString()});
      // }
      if(data.docs.length == 0) {
        firestore.collection('users').doc(user?.uid).collection('journal').doc().set({'date': DateFormat("yyyy-MM-dd").format(_whichDate), 'entry': _journalController.text.toString()});
        print("New entry");
      }
      else {
        data.docs[0].reference.set({'date': DateFormat("yyyy-MM-dd").format(_whichDate), 'entry': _journalController.text.toString()});
      }
    });
  }

  @override
  void initState() {
    user = auth.currentUser;
    super.initState();
    var currentDoc = firestore.collection('users').doc(user?.uid).collection('journal').where('date', isEqualTo: DateFormat("yyyy-MM-dd").format(DateTime.now()));
    currentDoc.get().then((data) {
      _journalController.text = data.docs[0]['entry'];
    });
    // print("Init run");
  }

  void changeEntryDate() {
    setState(() {
      var currentDoc = firestore.collection('users').doc(user?.uid).collection('journal').where('date', isEqualTo: DateFormat("yyyy-MM-dd").format(_whichDate));
      currentDoc.get().then((data) {
        if(data.docs.length == 0) {
          _journalController.text = "";
        }
        else {
          _journalController.text = data.docs[0]['entry'];
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    
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
      body: Padding(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      child: Icon(
                        Icons.save
                      ),
                      onPressed: saved ? null : () {
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