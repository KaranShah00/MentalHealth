import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:mental_health/screens/stats_screen.dart';

import 'dart:math' as math;

class EditVariablesScreen extends StatefulWidget {
  const EditVariablesScreen({Key? key}) : super(key: key);

  @override
  State<EditVariablesScreen> createState() => _EditVariablesScreenState();
}

class _EditVariablesScreenState extends State<EditVariablesScreen> with SingleTickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user;
  late Stream stream;
  var docs;
  // int variableIndex = 0;

  // void _onItemTapped(int index) {
  //   setState(() {
  //     range = index;
  //   });
  // }
  int getColor(String color) {
    String formattedHex =  "FF" + color.toUpperCase().replaceAll("#", "");
    return int.parse(formattedHex, radix: 16);
  }

  // List<Variable> getVariables() {
  //   return variables;
  // }
  final _formKey = GlobalKey<FormState>();

  String colorPicker = "#000000";
  Widget buildAddColorPicker() =>ColorPicker(
    pickerColor: Colors.black,
    onColorChanged: (color) => setState(() {
      // print("#" + color.toString().substring(10,16));
      colorPicker = "#" + color.toString().substring(10,16);
    }),
    pickerAreaHeightPercent: 0.25,
    enableAlpha: false,
  );

  Widget buildEditColorPicker(String color) {
    colorPicker = color;
    return ColorPicker(
      pickerColor: Color(getColor(color)),
      onColorChanged: (color) => setState(() {
        // print("#" + color.toString().substring(10,16));
        colorPicker = "#" + color.toString().substring(10,16);
      }),
      pickerAreaHeightPercent: 0.25,
      enableAlpha: false,
    );
  }

  addVariableDialog(BuildContext context) {

    TextEditingController _nameController = TextEditingController();
    TextEditingController _unitController = TextEditingController();
    TextEditingController _targetController = TextEditingController();
    TextEditingController _colorController = TextEditingController();

    String name, unit, color;
    int target, achieved;

    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        actionsPadding: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("New Variable"),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Name"),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter a name';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                  cursorColor: Colors.yellow.shade700,
                  decoration: InputDecoration(
                    hintText: "Name",
                  // fillColor: Colors.yellow.shade700,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.yellow.shade700,
                        width: 2,
                      ),
                    ),
                  ),
                  controller: _nameController,
                ),
                SizedBox(height: 30,),
                Text("Unit"),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter a unit';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                  cursorColor: Colors.yellow.shade700,
                  decoration: InputDecoration(
                    hintText: "Unit",
                  // fillColor: Colors.yellow.shade700,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.yellow.shade700,
                        width: 2,
                      ),
                    ),
                  ),
                  controller: _unitController,
                ),
                SizedBox(height: 30,),
                Text("Daily Target"),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter a value';
                    }
                    return null;
                  },
                  cursorColor: Colors.yellow.shade700,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Target",
                  // fillColor: Colors.yellow.shade700,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.yellow.shade700,
                        width: 2,
                      ),
                    ),
                  ),
                  controller: _targetController,
                ),
                SizedBox(height: 30,),
                Text("Color"),
                buildAddColorPicker(),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          MaterialButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            elevation: 5,
            child: Text("Add"),
            color: Colors.yellow.shade700,
            onPressed: (){
              if (_formKey.currentState!.validate()) {
                Variable newVariable = Variable(_nameController.text.toString(), _unitController.text.toString(), int.parse(_targetController.text.toString()), 0, colorPicker);
                  // If the form is valid, display a Snackbar.
                  Navigator.of(context).pop(newVariable);
                }
            }
          )
        ],
      );
    });
  }

  editVariableDialog(BuildContext context, QueryDocumentSnapshot variable, QueryDocumentSnapshot variableInstance) {

    // TextEditingController _nameController = TextEditingController(text: variable['name'] + " (uneditable)");
    // TextEditingController _unitController = TextEditingController(text: variable['unit'] + " (uneditable)");
    TextEditingController _targetController = TextEditingController(text: variableInstance['target'].toString());
    TextEditingController _colorController = TextEditingController();

    String name, unit, color;
    int target, achieved;

    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        actionsPadding: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Edit Variable"),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Name"),
                // TextFormField(
                //   enabled: false,
                //   validator: (value) {
                //     if (value!.isEmpty) {
                //       return 'Enter a name';
                //     }
                //     return null;
                //   },
                //   cursorColor: Colors.yellow.shade700,
                //   decoration: InputDecoration(
                //     hintText: "Name",
                //   // fillColor: Colors.yellow.shade700,
                //     focusedBorder: UnderlineInputBorder(
                //       borderSide: BorderSide(
                //         color: Colors.yellow.shade700,
                //         width: 2,
                //       ),
                //     ),
                //   ),
                //   controller: _nameController,
                // ),
                Text(
                  variable['name'],
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 30,),
                Text("Unit"),
                // TextFormField(
                //   enabled: false,
                //   validator: (value) {
                //     if (value!.isEmpty) {
                //       return 'Enter a unit';
                //     }
                //     return null;
                //   },
                //   cursorColor: Colors.yellow.shade700,
                //   decoration: InputDecoration(
                //     hintText: "Unit",
                //   // fillColor: Colors.yellow.shade700,
                //     focusedBorder: UnderlineInputBorder(
                //       borderSide: BorderSide(
                //         color: Colors.yellow.shade700,
                //         width: 2,
                //       ),
                //     ),
                //   ),
                //   controller: _unitController,
                // ),
                Text(
                  variable['unit'],
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 30,),
                Text("Daily Target"),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter a value';
                    }
                    return null;
                  },
                  cursorColor: Colors.yellow.shade700,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Target",
                  // fillColor: Colors.yellow.shade700,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.yellow.shade700,
                        width: 2,
                      ),
                    ),
                  ),
                  controller: _targetController,
                ),
                SizedBox(height: 30,),
                Text("Color"),
                buildEditColorPicker(variable['color']),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          MaterialButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            elevation: 5,
            child: Text("Save"),
            color: Colors.yellow.shade700,
            onPressed: (){
              if (_formKey.currentState!.validate()) {
                Variable newVariable = Variable(variable['name'], variable['unit'], int.parse(_targetController.text.toString()), 0, colorPicker);
                  // If the form is valid, display a Snackbar.
                Navigator.of(context).pop(newVariable);
              }
            }
          )
        ],
      );
    });
  }

  deleteVariableDialog(BuildContext context) {

    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        actionsPadding: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Delete variable?"),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("This cannot be undone."),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          MaterialButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            elevation: 5,
            child: Text("Delete"),
            color: Colors.yellow.shade700,
            onPressed: (){
              if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a Snackbar.
                  Navigator.of(context).pop(true);
                }
            }
          ),
          MaterialButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            elevation: 5,
            child: Text("Cancel"),
            color: Colors.yellow.shade700,
            onPressed: (){
              if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a Snackbar.
                  Navigator.of(context).pop(false);
                }
            }
          )
        ],
      );
    });
  }

  // late TabController _tabController;

  // int i = 0;
  
  // List<Variable> variables = [
  //   Variable("Water", "Cups", 8, 5, "#05b1d8"),
  //   Variable("Coffee", "Cups", 4, 1, "#613204"),
  //   Variable("Exercise", "Minutes", 60, 20, "#11c808"),
  //   Variable("Meditation", "Minutes", 30, 5, "#b6b903"),
  //   Variable("Rest", "Hours", 8, 2, "#681bb6"),
  // ];

  // late QueryDocumentSnapshot _variable;
  // var now = DateFormat("dd-MM-yy").format(DateTime.now());
  // String currentVariable = "Water";

  // List<Data> spotsWater = List<Data>.generate(365, (i) =>
  //   Data(
  //     DateTime.utc(
  //       DateTime.now().year,
  //       DateTime.now().month,
  //       DateTime.now().day,
  //     ).subtract(Duration(days: i)), (math.Random().nextInt(20))
  //   )
  // );
  // List<Data> spotsCoffee = List<Data>.generate(365, (i) =>
  //   Data(
  //     DateTime.utc(
  //       DateTime.now().year,
  //       DateTime.now().month,
  //       DateTime.now().day,
  //     ).subtract(Duration(days: i)), (math.Random().nextInt(20))
  //   )
  // );
  // List<Data> spotsExercise = List<Data>.generate(365, (i) =>
  //   Data(
  //     DateTime.utc(
  //       DateTime.now().year,
  //       DateTime.now().month,
  //       DateTime.now().day,
  //     ).subtract(Duration(days: i)), (math.Random().nextInt(20))
  //   )
  // );
  // List<Data> spotsMeditation = List<Data>.generate(365, (i) =>
  //   Data(
  //     DateTime.utc(
  //       DateTime.now().year,
  //       DateTime.now().month,
  //       DateTime.now().day,
  //     ).subtract(Duration(days: i)), (math.Random().nextInt(20))
  //   )
  // );
  // List<Data> spotsRest = List<Data>.generate(365, (i) =>
  //   Data(
  //     DateTime.utc(
  //       DateTime.now().year,
  //       DateTime.now().month,
  //       DateTime.now().day,
  //     ).subtract(Duration(days: i)), (math.Random().nextInt(20))
  //   )
  // );
  //   List<Data> spotsMood = List<Data>.generate(365, (i) =>
  //   Data(
  //     DateTime.utc(
  //       DateTime.now().year,
  //       DateTime.now().month,
  //       DateTime.now().day,
  //     ).subtract(Duration(days: i)), (math.Random().nextInt(20))
  //   )
  // );

  // List<Data> getData() {
  //   switch (currentVariable) {
  //     case "Water":
  //       return spotsWater;
  //     case "Coffee":
  //       return spotsCoffee;
  //     case "Exercise":
  //       return spotsExercise;
  //     case "Meditation":
  //       return spotsMeditation;
  //     case "Rest":
  //       return spotsRest;
  //   }
  //   return spotsWater;
  // }

  @override
  void initState() {
    user = auth.currentUser;
    super.initState();
    stream = firestore.collection('users').doc(user?.uid).collection('variables').snapshots();
    // print("Init run");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Color(0xffffba00),
        title: Text('Mental Wellness'),
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
        flexibleSpace: Container(
          decoration: new BoxDecoration(
            gradient: const LinearGradient(
                colors: [
                  const Color(0xffffd93b),
                  const Color(0xffffba00),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () {
          Navigator.pop(context, docs.length);
          return new Future(() => false);
        },
        child: StreamBuilder(
          stream: stream,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (!snapshot.hasData) return const Text('Loading...');
            docs = snapshot.data.docs;
            return Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Text(
                        "YOUR VARIABLES",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          // color: Colors.yellow[800],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: SafeArea(
                      child: GlowingOverscrollColorChanger(
                        color: Colors.amber,
                        child: ListView(
                          children: List.generate(docs.length, (index) {
                            return 
                            StreamBuilder(
                              stream: firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).collection('data').snapshots(),
                              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                if (!snapshot.hasData) {
                                  // print("Loading\n");
                                  return const Text('Loading values...');
                                }
                                var data = snapshot.data.docs;
                                data = data.sublist(data.length - 1, data.length);
                                if(docs[index]['name'] != "Mood")
                                {
                                  return Container(
                                    height: 130,
                                    margin: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow:[ 
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 7,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  Text(docs[index]['name']),
                                                  SizedBox(width: 120),
                                                  Text(docs[index]['unit']),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 15, right: 15),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(50),
                                                  child: LinearProgressIndicator(
                                                    value: data.last['score']/data.last['target'],
                                                    minHeight: 10,
                                                    backgroundColor: Colors.grey.shade100,
                                                    color: Color(getColor(docs[index]['color'])),
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 15),
                                                    child: Text(data.last['score'].toString() + "/" + data.last['target'].toString()),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                FloatingActionButton(
                                                  heroTag: null,
                                                  backgroundColor: Color(getColor(docs[index]['color'])),
                                                  foregroundColor: Colors.white,
                                                  child: Icon(Icons.delete),
                                                  mini: true,
                                                  onPressed: () async {
                                                    bool delete = await deleteVariableDialog(context);
                                                    // print(delete);
                                                    if (delete) {
                                                      firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).delete();
                                                    }
                                                    // firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).update({'achieved': docs[index]['achieved'] + 1});
                                                  },
                                                ),
                                                FloatingActionButton(
                                                  heroTag: null,
                                                  backgroundColor: Color(getColor(docs[index]['color'])),
                                                  foregroundColor: Colors.white,
                                                  child: Icon(Icons.edit),
                                                  mini: true,
                                                  onPressed: () async {
                                                    // print(docs[index]);
                                                    Variable newVariable = await editVariableDialog(context, docs[index], data.last);
                                                    for(var i in data) {
                                                      // print(DateFormat("yyyy-MM-dd").format(i['date'].toDate()));
                                                      // print(DateFormat("yyyy-MM-dd").format(DateTime.now()));
                                                      if (DateFormat("yyyy-MM-dd").format(i['date'].toDate()) == DateFormat("yyyy-MM-dd").format(DateTime.now())) {
                                                        // print(i['date']);
                                                        // print("Date found");
                                                        firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).collection('data').doc(DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day,).toString()).update({'target': newVariable.target});
                                                        break;
                                                      }
                                                      else {
                                                        // print("New document");
                                                        firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).collection('data').doc(DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day,).toString()).set({'date': DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day,), 'score': 0, 'target': newVariable.target});
                                                      }
                                                    }
                                                    // firestore.collection('users').doc(user?.uid).collection('variables').doc(newVariable.name).collection('data').doc(DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day,).toString()).set({'date': DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day,), 'score': 0, 'target': newVariable.target});
                                                    // // print(delete);
                                                    // if (delete) {
                                                    //   firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).delete();
                                                    // }
                                                    // firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).update({'achieved': docs[index]['achieved'] + 1});
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                else {
                                  return Container();
                                }
                              }
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: FloatingActionButton(
                        heroTag: null,
                        backgroundColor: Colors.yellow.shade700,
                        foregroundColor: Colors.white,
                        child: Icon(Icons.add),
                        onPressed: () async {
                          Variable newVariable = await addVariableDialog(context);
                          firestore.collection('users').doc(user?.uid).collection('variables').doc(newVariable.name).set({'name': newVariable.name, 'unit': newVariable.unit, 'target': newVariable.target, 'achieved': newVariable.achieved, 'color': newVariable.color});
                          firestore.collection('users').doc(user?.uid).collection('variables').doc(newVariable.name).collection('data').doc(DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day, ).toString()).set(
                            {
                              'date': DateTime.utc(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                              ),
                              'score': 0,
                              'target': newVariable.target
                            });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}

/// Overrides the [GlowingOverscrollIndicator] color used by descendant widgets.
class GlowingOverscrollColorChanger extends StatelessWidget {
  // Change colour of overflow scroll glow
  final Widget child;
  final Color color;

  const GlowingOverscrollColorChanger({Key? key, required this.child, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: SpecifiableOverscrollColorScrollBehavior(color),
      child: child,
    );
  }
}

class SpecifiableOverscrollColorScrollBehavior extends ScrollBehavior {
  final Color _overscrollColor;

  const SpecifiableOverscrollColorScrollBehavior(this._overscrollColor);

  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return child;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      default:
        return GlowingOverscrollIndicator(
          child: child,
          axisDirection: axisDirection,
          color: _overscrollColor,
        );
    }
  }
}

class Variable {
  String name;
  String unit;
  int target;
  int achieved;
  String color;
  List<Data>? data;

  Variable(this.name, this.unit, this.target, this.achieved, this.color);
  int getColor() {
    String formattedHex =  "FF" + color.toUpperCase().replaceAll("#", "");
    return int.parse(formattedHex, radix: 16);
  }
}

class Data {
  DateTime date;
  int score;
  Data(this.date, this.score);
}