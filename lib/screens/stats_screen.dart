import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mental_health/screens/edit_variables_screen.dart';
import 'dart:math' as math;
import 'dart:async';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  // static const List<Color> lineColor = [
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user;
  late Stream stream;
  var docs;
  int range = 0;
  int variableIndex = 0;

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

  late TabController _tabController;

  // int i = 0;
  
  // List<Variable> variables = [
  //   Variable("Water", "Cups", 8, 5, "#05b1d8"),
  //   Variable("Coffee", "Cups", 4, 1, "#613204"),
  //   Variable("Exercise", "Minutes", 60, 20, "#11c808"),
  //   Variable("Meditation", "Minutes", 30, 5, "#b6b903"),
  //   Variable("Rest", "Hours", 8, 2, "#681bb6"),
  // ];

  late QueryDocumentSnapshot _variable;
  var now = DateFormat("dd-MM-yy").format(DateTime.now());
  String currentVariable = "Water";

  List<Data> spotsWater = List<Data>.generate(365, (i) =>
    Data(
      DateTime.utc(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ).subtract(Duration(days: i)), (math.Random().nextInt(20))
    )
  );
  List<Data> spotsCoffee = List<Data>.generate(365, (i) =>
    Data(
      DateTime.utc(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ).subtract(Duration(days: i)), (math.Random().nextInt(20))
    )
  );
  List<Data> spotsExercise = List<Data>.generate(365, (i) =>
    Data(
      DateTime.utc(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ).subtract(Duration(days: i)), (math.Random().nextInt(20))
    )
  );
  List<Data> spotsMeditation = List<Data>.generate(365, (i) =>
    Data(
      DateTime.utc(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ).subtract(Duration(days: i)), (math.Random().nextInt(20))
    )
  );
  List<Data> spotsRest = List<Data>.generate(365, (i) =>
    Data(
      DateTime.utc(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ).subtract(Duration(days: i)), (math.Random().nextInt(20))
    )
  );
  List<Data> spotsMood = List<Data>.generate(365, (i) =>
    Data(
      DateTime.utc(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ).subtract(Duration(days: i)), (math.Random().nextInt(20))
    )
  );

  Future<List<Data>> _getData() async {
    List<Data> returnData = [];
    var singularData = firestore.collection('users').doc(user?.uid).collection('variables').doc(_variable['name']).collection('data').where('date', isGreaterThan: DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day,).subtract(Duration(days: 365))).orderBy('date');
    // var singularData = firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).collection('data').get();
    await singularData.get().then((data){
      // print(data.docs.length);
      for(var instance in data.docs) {
        var d = instance.data();
        returnData.add(Data(d['date'].toDate(), d['score']));
        // print("This is what is returned:\n");
        // print(returnData[0].date);
        // print(d['date'].toDate());
      }
    });
    return returnData;
    // switch (currentVariable) {
    //   case "Water":
    //     return spotsWater;
    //   case "Coffee":
    //     return spotsCoffee;
    //   case "Exercise":
    //     return spotsExercise;
    //   case "Meditation":
    //     return spotsMeditation;
    //   case "Rest":
    //     return spotsRest;
    // }
    // return spotsWater;
  }

  @override
  void initState() {
    user = auth.currentUser;
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    stream = firestore.collection('users').doc(user?.uid).collection('variables').snapshots();
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
      body: StreamBuilder(
        stream: stream,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          // print("Test print");
          if (!snapshot.hasData) {
            // print("Loading\n");
            return const Text('Loading...');
          }
          docs = snapshot.data.docs;
          _variable = docs[variableIndex];
          // print("Here is the data:\n");
          // print(_getData().length);
          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                height: 300,
                width: 450,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), //color of shadow
                      spreadRadius: 5, //spread radius
                      blurRadius: 7, // blur radius
                      offset: Offset(0, 2),
                    )
                  ],
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.yellow,Colors.yellow.shade700]
                    ),
                ),
                child: Column(
                  children: [
                    Text(
                      "YOUR MOOD",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(width: 200,),
                        Container(
                          child: Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(child: Icon(Icons.remove, color: Colors.white,)),
                                    Expanded(child: Text("Your Mood")),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(child: Icon(Icons.remove, color: Color(getColor(_variable['color'])),)),
                                    Expanded(child: Text(_variable['name'])),
                                  ],
                                ),
                              ],
                            )
                          ),
                        )
                      ],
                    ),
                    FutureBuilder<Object>(
                      future: _getData(),
                      builder: (context, snapshot) {
                        // print("Data is:");
                        // print(_getData());
                        if(!snapshot.hasData) {
                          return const Text('Loading...');
                        }
                        Object? finalData = snapshot.data;
                        List<FlSpot> data = [];
                        if(finalData is List<Data>) {
                        // print("Final Data is:");
                        //   print(finalData[0]);
                          data = finalData.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value.score.toDouble());
                          }).toList();
                        }
                        return Expanded(
                          child: TabBarView (
                            controller: _tabController,
                            children: <Widget>[
                              LineChart(
                                LineChartData(
                                  minX: 0,
                                  maxX: 7,
                                  minY: 0,
                                  maxY: 20,
                                  titlesData: LineTilesWeek.getTitleData(),
                                  gridData: FlGridData(
                                    show: false,
                                  ),
                                  borderData: FlBorderData(
                                    show: false,
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(
                                      // spots: data.sublist(0,7).asMap().entries.map((e) {
                                      //   // print("Data for FL spots:");
                                      //   // print(e.key.toDouble().toString() + e.value.score.toDouble().toString());
                                      //   return FlSpot(e.key.toDouble(), e.value.score.toDouble());
                                      // }).toList(),
                                      spots: data.sublist(0,math.min(7, data.length)),
                                      shadow: const Shadow(
                                        color: Color(0xffaaaaaa),
                                        blurRadius: 1,
                                        ),
                                      isCurved: true,
                                      isStrokeCapRound: true,
                                      barWidth: 5,
                                      colors: [Color(getColor(_variable['color'])),],
                                      dotData: FlDotData(show: false),
                                    ),
                                    LineChartBarData(
                                      spots:  spotsMood.sublist(0,7).asMap().entries.map((e) {
                                        return FlSpot(e.key.toDouble(), e.value.score.toDouble());
                                      }).toList(),
                                      shadow: const Shadow(
                                        color: Color(0xffaaaaaa),
                                        blurRadius: 1,
                                        ),
                                      isCurved: true,
                                      isStrokeCapRound: true,
                                      barWidth: 5,
                                      colors: [const Color(0xffffffff),],
                                      dotData: FlDotData(show: false),
                                    ),
                                  ]
                                ),
                                // swapAnimationDuration: const Duration(milliseconds: 150),
                                // swapAnimationCurve: Curves.linear,
                              ),
                              LineChart(
                                LineChartData(
                                  minX: 0,
                                  maxX: 31,
                                  minY: 0,
                                  maxY: 20,
                                  titlesData: LineTilesMonth.getTitleData(),
                                  gridData: FlGridData(
                                    show: false,
                                  ),
                                  borderData: FlBorderData(
                                    show: false,
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(
                                      // spots: data.sublist(0,31).asMap().entries.map((e) {
                                      //   return FlSpot(e.key.toDouble(), e.value.score.toDouble());
                                      // }).toList(),
                                      spots: data.sublist(0,math.min(31, data.length)),
                                      shadow: const Shadow(
                                        color: Color(0xffaaaaaa),
                                        blurRadius: 1,
                                        ),
                                      isCurved: true,
                                      isStrokeCapRound: true,
                                      barWidth: 5,
                                      colors: [Color(getColor(_variable['color'])),],
                                      dotData: FlDotData(show: false),
                                    ),
                                    LineChartBarData(
                                      spots:  spotsMood.sublist(0,31).asMap().entries.map((e) {
                                        return FlSpot(e.key.toDouble(), e.value.score.toDouble());
                                      }).toList(),
                                      shadow: const Shadow(
                                        color: Color(0xffaaaaaa),
                                        blurRadius: 1,
                                        ),
                                      isCurved: true,
                                      isStrokeCapRound: true,
                                      barWidth: 5,
                                      colors: [const Color(0xffffffff),],
                                      dotData: FlDotData(show: false),
                                    ),
                                  ]
                                ),
                                // swapAnimationDuration: const Duration(milliseconds: 150),
                                // swapAnimationCurve: Curves.linear,
                              ),
                              LineChart(
                                LineChartData(
                                  minX: 0,
                                  maxX: 12,
                                  minY: 0,
                                  maxY: 20,
                                  titlesData: LineTilesYear.getTitleData(),
                                  gridData: FlGridData(
                                    show: false,
                                  ),
                                  borderData: FlBorderData(
                                    show: false,
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(
                                      // spots: data.sublist(0,12).asMap().entries.map((e) {
                                      //   return FlSpot(e.key.toDouble(), e.value.score.toDouble());
                                      // }).toList(),
                                      spots: data.sublist(0,math.min(365, data.length)),
                                      shadow: const Shadow(
                                        color: Color(0xffaaaaaa),
                                        blurRadius: 1,
                                        ),
                                      isCurved: true,
                                      isStrokeCapRound: true,
                                      barWidth: 5,
                                      colors: [Color(getColor(_variable['color'])),],
                                      dotData: FlDotData(show: false),
                                    ),
                                    LineChartBarData(
                                      spots: spotsMood.sublist(0,12).asMap().entries.map((e) {
                                        return FlSpot(e.key.toDouble(), e.value.score.toDouble());
                                      }).toList(),
                                      shadow: const Shadow(
                                        color: Color(0xffaaaaaa),
                                        blurRadius: 1,
                                        ),
                                      isCurved: true,
                                      isStrokeCapRound: true,
                                      barWidth: 5,
                                      colors: [const Color(0xffffffff),],
                                      dotData: FlDotData(show: false),
                                    ),
                                  ]
                                ),
                                // swapAnimationDuration: const Duration(milliseconds: 150),
                                // swapAnimationCurve: Curves.linear,
                              ),
                            ],
                          ),
                        );
                      }
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 400,
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.black,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5), //color of shadow
                            spreadRadius: 5, //spread radius
                            blurRadius: 7, // blur radius
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.yellow.shade700,
                        ),
                        controller: _tabController,
                        tabs: [
                          Tab(text: "Past Week"),
                          Tab(text: "Past Month"),
                          Tab(text: "Past Year"),
                        ]
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "YOUR VARIABLES",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints.tightFor(width: 60, height: 60),
                        child: FloatingActionButton(
                          heroTag: null,
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                          child: Icon(Icons.edit),
                          onPressed: () async {
                            int result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return EditVariablesScreen();
                                }
                              ),
                            );
                            if (variableIndex >= result) {
                              variableIndex = result -1;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                child: Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      GlowingOverscrollColorChanger(
                        color: Colors.amber,
                        child: ListView(
                          children: docs.length == 0 ? [Text("Add variables")]: List.generate(docs.length, (index) {
                            return 
                            Container(
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
                                    flex: 1,
                                    child: Radio<QueryDocumentSnapshot>(
                                      value: docs[index],
                                      groupValue: _variable,
                                      onChanged: (value) {
                                        setState(() {
                                          _variable = value!;
                                          currentVariable = docs[index]['name'];
                                          variableIndex = index;
                                        });
                                      },
                                      activeColor: Color(getColor(docs[index]['color'])),
                                    ),
                                  ),
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
                                              value: docs[index]['achieved']/docs[index]['target'],
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
                                              child: Text(docs[index]['achieved'].toString() + "/" + docs[index]['target'].toString()),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          FloatingActionButton(
                                            heroTag: null,
                                            backgroundColor: Color(getColor(docs[index]['color'])),
                                            foregroundColor: Colors.white,
                                            child: Icon(Icons.add),
                                            mini: true,
                                            onPressed: () {
                                              // firestore.runTransaction((transaction) async {
                                              //   DocumentSnapshot freshSnap = await transaction.get(docs.reference);
                                              //   await transaction.update(freshSnap.reference, {
                                              //     'achieved': freshSnap['achieved'] + 1,
                                              //   });
                                              // });
                                              // QuerySnapshot docRef = ;
                                              firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).update({'achieved': docs[index]['achieved'] + 1});
                                            },
                                          ),
                                          FloatingActionButton(
                                            heroTag: null,
                                            backgroundColor: Color(getColor(docs[index]['color'])),
                                            foregroundColor: Colors.white,
                                            child: Icon(Icons.remove),
                                            mini: true,
                                            onPressed: () {
                                              // firestore.runTransaction((transaction) async {
                                              //   DocumentSnapshot freshSnap = await transaction.get(docs.reference);
                                              //   await transaction.update(freshSnap.reference, {
                                              //     'achieved': freshSnap['achieved'] - 1,
                                              //   });
                                              // });
                                              // QuerySnapshot docRef = ;
                                              firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).update({'achieved': math.max(docs[index]['achieved'] - 1, 0)});
                                            },
                                          ),
                                        ],
                                      ),
                                    )
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                      ListView(
                        children: List.generate(docs.length, (index) {
                          return 
                          Container(
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
                                  flex: 1,
                                  child: Radio<QueryDocumentSnapshot>(
                                    value: docs[index],
                                    groupValue: _variable,
                                    onChanged: (value) {
                                      setState(() {
                                        _variable = value!;
                                        currentVariable = docs[index]['name'];
                                        variableIndex = index;
                                      });
                                    },
                                    activeColor: Color(getColor(docs[index]['color'])),
                                  ),
                                ),
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
                                            value: docs[index]['achieved']/docs[index]['target'],
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
                                            child: Text(docs[index]['achieved'].toString() + "/" + docs[index]['target'].toString()),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        FloatingActionButton(
                                          heroTag: null,
                                          backgroundColor: Color(getColor(docs[index]['color'])),
                                          foregroundColor: Colors.white,
                                          child: Icon(Icons.add),
                                          mini: true,
                                          onPressed: () {
                                            // firestore.runTransaction((transaction) async {
                                            //   DocumentSnapshot freshSnap = await transaction.get(docs.reference);
                                            //   await transaction.update(freshSnap.reference, {
                                            //     'achieved': freshSnap['achieved'] + 1,
                                            //   });
                                            // });
                                            // QuerySnapshot docRef = ;
                                            firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).update({'achieved': docs[index]['achieved'] + 1});
                                          },
                                        ),
                                        FloatingActionButton(
                                          heroTag: null,
                                          backgroundColor: Color(getColor(docs[index]['color'])),
                                          foregroundColor: Colors.white,
                                          child: Icon(Icons.remove),
                                          mini: true,
                                          onPressed: () {
                                            // firestore.runTransaction((transaction) async {
                                            //   DocumentSnapshot freshSnap = await transaction.get(docs.reference);
                                            //   await transaction.update(freshSnap.reference, {
                                            //     'achieved': freshSnap['achieved'] - 1,
                                            //   });
                                            // });
                                            // QuerySnapshot docRef = ;
                                            firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).update({'achieved': math.max(docs[index]['achieved'] - 1, 0)});
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                      ListView(
                        children: List.generate(docs.length, (index) {
                          return 
                          Container(
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
                                  flex: 1,
                                  child: Radio<QueryDocumentSnapshot>(
                                    value: docs[index],
                                    groupValue: _variable,
                                    onChanged: (value) {
                                      setState(() {
                                        _variable = value!;
                                        currentVariable = docs[index]['name'];
                                        variableIndex = index;
                                      });
                                    },
                                    activeColor: Color(getColor(docs[index]['color'])),
                                  ),
                                ),
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
                                            value: docs[index]['achieved']/docs[index]['target'],
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
                                            child: Text(docs[index]['achieved'].toString() + "/" + docs[index]['target'].toString()),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        FloatingActionButton(
                                          heroTag: null,
                                          backgroundColor: Color(getColor(docs[index]['color'])),
                                          foregroundColor: Colors.white,
                                          child: Icon(Icons.add),
                                          mini: true,
                                          onPressed: () {
                                            // firestore.runTransaction((transaction) async {
                                            //   DocumentSnapshot freshSnap = await transaction.get(docs.reference);
                                            //   await transaction.update(freshSnap.reference, {
                                            //     'achieved': freshSnap['achieved'] + 1,
                                            //   });
                                            // });
                                            // QuerySnapshot docRef = ;
                                            firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).update({'achieved': docs[index]['achieved'] + 1});
                                          },
                                        ),
                                        FloatingActionButton(
                                          heroTag: null,
                                          backgroundColor: Color(getColor(docs[index]['color'])),
                                          foregroundColor: Colors.white,
                                          child: Icon(Icons.remove),
                                          mini: true,
                                          onPressed: () {
                                            // firestore.runTransaction((transaction) async {
                                            //   DocumentSnapshot freshSnap = await transaction.get(docs.reference);
                                            //   await transaction.update(freshSnap.reference, {
                                            //     'achieved': freshSnap['achieved'] - 1,
                                            //   });
                                            // });
                                            // QuerySnapshot docRef = ;
                                            firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).update({'achieved': math.max(docs[index]['achieved'] - 1, 0)});
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                      ]
                  ),
                ),
              )
            ],
          );
        }
      ),
    );
  }
}

class LineTilesWeek {
  static getTitleData() => FlTitlesData(
    show: true,
    topTitles: SideTitles(
      showTitles: false),
    bottomTitles: SideTitles(
      showTitles: true,
      reservedSize: 20,
      getTitles: (value) {
        switch (value.toInt()) {
          case 0:
            return 'MON';
          case 1:
            return 'TUE';
          case 2:
            return 'WED';
          case 3:
            return 'THUR';
          case 4:
            return 'FRI';
          case 5:
            return 'SAT';
          case 6:
            return 'SUN';
        }
        return '';
      },
    ),
    leftTitles: SideTitles(
      showTitles: true,
      reservedSize: 20,
      getTitles: (value) {
        switch (value.toInt()) {
          case 4:
            return '25';
          case 9:
            return '50';
          case 14:
            return '75';
          case 19:
            return '100';
        }
        return '';
      },
    ),
    rightTitles: SideTitles(
      showTitles: false,
    )
  );
}

class LineTilesMonth {
  static getTitleData() => FlTitlesData(
    show: true,
    topTitles: SideTitles(
      showTitles: false),
    bottomTitles: SideTitles(
      showTitles: true,
      reservedSize: 20,
      getTitles: (value) {
        switch (value.toInt()) {
          case 0:
            return '1';
          // case 1:
          //   return '2';
          // case 2:
          //   return '3';
          // case 3:
          //   return '4';
          // case 4:
          //   return '5';
          case 5:
            return '6';
          // case 6:
          //   return '7';
          // case 7:
          //   return '8';
          // case 8:
          //   return '9';
          // case 9:
          //   return '10';
          case 10:
            return '11';
          // case 11:
          //   return '12';
          // case 12:
          //   return '13';
          // case 13:
          //   return '14';
          // case 14:
          //   return '15';
          case 15:
            return '16';
          // case 16:
          //   return '17';
          // case 17:
          //   return '18';
          // case 18:
          //   return '19';
          // case 19:
          //   return '20';
          case 20:
            return '21';
          // case 21:
          //   return '22';
          // case 22:
          //   return '23';
          // case 23:
          //   return '24';
          // case 24:
          //   return '25';
          case 25:
            return '26';
          // case 26:
          //   return '27';
          // case 27:
          //   return '28';
          // case 28:
          //   return '29';
          // case 29:
          //   return '30';
          case 30:
            return '31';
        }
        return '';
      },
      margin: 8,
    ),
    leftTitles: SideTitles(
      showTitles: true,
      reservedSize: 0,
      getTitles: (value) {
        switch (value.toInt()) {
          case 4:
            return '25';
          case 9:
            return '50';
          case 14:
            return '75';
          case 19:
            return '100';
        }
        return '';
      },
    ),
    rightTitles: SideTitles(
      showTitles: false,
      reservedSize: 20,
    )
  );
}

class LineTilesYear {
  static getTitleData() => FlTitlesData(
    show: true,
    topTitles: SideTitles(
      showTitles: false),
    bottomTitles: SideTitles(
      showTitles: true,
      reservedSize: 20,
      getTitles: (value) {
        switch (value.toInt()) {
          case 0:
            return 'JAN';
          // case 1:
          //   return 'FEB';
          case 2:
            return 'MAR';
          // case 3:
          //   return 'APR';
          case 4:
            return 'MAY';
          // case 5:
          //   return 'JUN';
          case 6:
            return 'JUL';
          // case 7:
          //   return 'AUG';
          case 8:
            return 'SEP';
          // case 9:
          //   return 'OCT';
          case 10:
            return 'NOV';
          // case 11:
          //   return 'DEC';
        }
        return '';
      },
      margin: 8,
    ),
    leftTitles: SideTitles(
      showTitles: true,
      reservedSize: 20,
      getTitles: (value) {
        switch (value.toInt()) {
          case 4:
            return '25';
          case 9:
            return '50';
          case 14:
            return '75';
          case 19:
            return '100';
        }
        return '';
      },
    ),
    rightTitles: SideTitles(
      showTitles: false,
    )
  );
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