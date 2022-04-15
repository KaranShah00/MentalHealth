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
      ).subtract(Duration(days: i)), (math.Random().nextInt(20)), 0
    )
  );
  List<Data> spotsCoffee = List<Data>.generate(365, (i) =>
    Data(
      DateTime.utc(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ).subtract(Duration(days: i)), (math.Random().nextInt(20)), 0
    )
  );
  List<Data> spotsExercise = List<Data>.generate(365, (i) =>
    Data(
      DateTime.utc(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ).subtract(Duration(days: i)), (math.Random().nextInt(20)), 0
    )
  );
  List<Data> spotsMeditation = List<Data>.generate(365, (i) =>
    Data(
      DateTime.utc(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ).subtract(Duration(days: i)), (math.Random().nextInt(20)), 0
    )
  );
  List<Data> spotsRest = List<Data>.generate(365, (i) =>
    Data(
      DateTime.utc(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ).subtract(Duration(days: i)), (math.Random().nextInt(20)), 0
    )
  );
  List<Data> spotsMood = List<Data>.generate(365, (i) =>
    Data(
      DateTime.utc(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ).subtract(Duration(days: i)), (math.Random().nextInt(20)), 0
    )
  );

  Future<List<Data>> _getData() async {
    List<Data> returnData = [];
    var singularData = firestore.collection('users').doc(user?.uid).collection('variables').doc(_variable['name']).collection('data').where('date', isGreaterThan: DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day,).subtract(Duration(days: 365))).orderBy('date',descending: true);
    // int currentTarget = firestore.collection('users').doc(user?.uid).collection('variables').doc(_variable['target']) as int;
    // var singularData = firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).collection('data').get();
    await singularData.get().then((data){
      // print(data.docs.length);
      for(var instance in data.docs) {
        var d = instance.data();
        returnData.add(Data(d['date'].toDate(), d['score'], 0));
        // print("This is what is returned:\n");
        // print(returnData[0].date);
        // print(d['date'].toDate());
      }
    });
    return returnData;
  }
  // Future<int> _getMonthlyAchievedData() async {
  //   int sum = 0;
  //   var data = firestore.collection('users').doc(user?.uid).collection('variables').doc(_variable['name']).collection('data').where('date', isGreaterThan: DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day,).subtract(Duration(days: 365))).orderBy('date');
  //   await data.get().then((data){
  //     // print(data.docs.length);
  //     for(var instance in data.docs) {
  //       var d = instance.data();
  //       sum += (d['achieved']);
  //       // print("This is what is returned:\n");
  //       // print(returnData[0].date);
  //       // print(d['date'].toDate());
  //     }
  //   });
  //   return sum;
  // }

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
                  Color.fromARGB(255, 255, 217, 59),
                  Color.fromARGB(255, 255, 186, 0),
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
                    StreamBuilder(
                      // future: _getData(),
                      stream: firestore.collection('users').doc(user?.uid).collection('variables').doc(_variable['name']).collection('data').snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                        // print("Data is:");
                        // print(_getData());
                        if(!snapshot.hasData) {
                          return const Text('Loading...');
                        }
                        List finalData = snapshot.data.docs;
                        // List<FlSpot> data = [];
                        // // if(finalData is List<Data>) {
                        // //   print("Final data is List");
                        // // print("Final Data is:");
                        // //   print(finalData[0]);
                        //   data = finalData.asMap().entries.map((e) {
                        //     // print("Getting E as " + e.value.data()['score'].toString());
                        //     return FlSpot(e.key.toDouble(), e.value.data()['score'].toDouble());
                        //   }).toList();
                          List<FlSpot> dataWeek = [];
                          dataWeek = finalData.sublist(math.max(0,finalData.length - 7), finalData.length).asMap().entries.map((e) {
                            // print("Getting E as " + e.value.data()['score'].toString());
                            return FlSpot(e.key.toDouble() + math.max((7 - finalData.length), 0), e.value.data()['score'].toDouble());
                          }).toList();

                          List<FlSpot> dataMonth = [];
                          dataMonth = finalData.sublist(math.max(0,finalData.length - 30), finalData.length).asMap().entries.map((e) {
                            // print("Getting E as " + e.value.data()['score'].toString());
                            return FlSpot(e.key.toDouble(), e.value.data()['score'].toDouble());
                          }).toList();

                          List<FlSpot> dataYear = [];
                          dataYear = finalData.sublist(math.max(0,finalData.length - 12), finalData.length).asMap().entries.map((e) {
                            // print("Getting E as " + e.value.data()['score'].toString());
                            return FlSpot(e.key.toDouble(), e.value.data()['score'].toDouble());
                          }).toList();
                          // print(data.sublist(0,7).reversed.toList());
                        // }
                        return Expanded(
                          child: TabBarView (
                            controller: _tabController,
                            children: <Widget>[
                              LineChart(
                                LineChartData(
                                  minX: 0,
                                  maxX: 7,
                                  minY: 0,
                                  maxY: 25,
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
                                      spots: dataWeek,
                                      // spots: data.sublist(math.max(0, data.length), data.length),
                                      shadow: const Shadow(
                                        color: Color(0xffaaaaaa),
                                        blurRadius: 1,
                                        ),
                                      isCurved: true,
                                      isStrokeCapRound: true,
                                      barWidth: 5,
                                      colors: [Color(getColor(_variable['color'])),],
                                      dotData: FlDotData(show: false,),
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
                                  maxY: 25,
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
                                      spots: dataMonth,
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
                                      spots:  spotsMood.sublist(0,30).asMap().entries.map((e) {
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
                                  maxY: 25,
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
                                      spots: dataYear,
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
                  child:
                  // TabBarView(
                    // controller: _tabController,
                    // children: [
                      GlowingOverscrollColorChanger(
                        color: Colors.amber,
                        child: ListView(
                          children: docs.length == 0 ? [Text("Add variables")]: List.generate(docs.length, (index) {
                          // var dataSnapshot = firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).collection('data').doc(DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day,).toString());
                          // int score, target;
                          // dataSnapshot.get().then((data){
                          //   score = data['score'];
                          //   target = data['target'];
                          //   // print(data['score']);
                          // });
                          // docs = snapshot.data.docs;
                          // _variable = docs[variableIndex];
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
                                // print(data.last['score']);
                                // _variable = docs[variableIndex];
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
                                                  // value: docs[index]['achieved']/docs[index]['target'],
                                                  // value: data.last['score']/data.last['target'],
                                                  value: DateFormat("yyyy-MM-dd").format(data.last['date'].toDate()) == DateFormat("yyyy-MM-dd").format(DateTime.now()) ? data.last['score']/data.last['target'] : 0/data.last['target'],
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
                                                  child: Text(DateFormat("yyyy-MM-dd").format(data.last['date'].toDate()) == DateFormat("yyyy-MM-dd").format(DateTime.now()) ? data.last['score'].toString() + "/" + data.last['target'].toString() : "0/" + data.last['target'].toString()),
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
                                                  // print(DateFormat.EEEE());
                                                  // firestore.runTransaction((transaction) async {
                                                  //   DocumentSnapshot freshSnap = await transaction.get(docs.reference);
                                                  //   await transaction.update(freshSnap.reference, {
                                                  //     'achieved': freshSnap['achieved'] + 1,
                                                  //   });
                                                  // });
                                                  // QuerySnapshot docRef = ;
                                                  for(var i in data) {
                                                    // print(DateFormat("yyyy-MM-dd").format(i['date'].toDate()));
                                                    // print(DateFormat("yyyy-MM-dd").format(DateTime.now()));
                                                    if (DateFormat("yyyy-MM-dd").format(i['date'].toDate()) == DateFormat("yyyy-MM-dd").format(DateTime.now())) {
                                                      // print(i['date']);
                                                      // print("Date found");
                                                      firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).collection('data').doc(DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day,).toString()).update({'score': data.last['score'] + 1});
                                                      break;
                                                    }
                                                    else {
                                                      // print("New document");
                                                      firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).collection('data').doc(DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day,).toString()).set({'date': DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day,), 'score': 1, 'target': data.last['target']});
                                                    }
                                                  }
                                                  // firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).collection('data').doc(DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day,).toString()).update({'score': data.last['score'] + 1});
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
                                                  // firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).update({'achieved': math.max(docs[index]['achieved'] - 1, 0)});
                                                  for(var i in data) {
                                                    // print(DateFormat("yyyy-MM-dd").format(i['date'].toDate()));
                                                    // print(DateFormat("yyyy-MM-dd").format(DateTime.now()));
                                                    if (DateFormat("yyyy-MM-dd").format(i['date'].toDate()) == DateFormat("yyyy-MM-dd").format(DateTime.now())) {
                                                      // print(i['date']);
                                                      // print("Date found");
                                                      firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).collection('data').doc(DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day,).toString()).update({'score': math.max(data.last['score'] - 1, 0)});
                                                      break;
                                                    }
                                                    else {
                                                      // print("New document");
                                                      firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).collection('data').doc(DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day,).toString()).set({'date': DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day,), 'score': 0, 'target': data.last['target']});
                                                    }
                                                  }
                                                  // firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).collection('data').doc(DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day,).toString()).update({'score': math.max(data.last['score'] - 1, 0)});
                                                },
                                              ),
                                            ],
                                          ),
                                        )
                                      ),
                                    ],
                                  ),
                                );
                              }
                            );
                          }),
                        ),
                      ),
                      // GlowingOverscrollColorChanger(
                      //   color: Colors.amber,
                      //   child: ListView(
                      //     children: List.generate(docs.length, (index) {
                      //       return 
                      //       Container(
                      //         height: 130,
                      //         margin: EdgeInsets.all(10),
                      //         decoration: BoxDecoration(
                      //           color: Colors.white,
                      //           borderRadius: BorderRadius.circular(30),
                      //           boxShadow:[ 
                      //             BoxShadow(
                      //                 color: Colors.grey.withOpacity(0.5),
                      //                 spreadRadius: 5,
                      //                 blurRadius: 7,
                      //                 offset: Offset(0, 5),
                      //             ),
                      //           ],
                      //         ),
                      //         child: Row(
                      //           children: [
                      //             Expanded(
                      //               flex: 1,
                      //               child: Radio<QueryDocumentSnapshot>(
                      //                 value: docs[index],
                      //                 groupValue: _variable,
                      //                 onChanged: (value) {
                      //                   setState(() {
                      //                     _variable = value!;
                      //                     currentVariable = docs[index]['name'];
                      //                     variableIndex = index;
                      //                   });
                      //                 },
                      //                 activeColor: Color(getColor(docs[index]['color'])),
                      //               ),
                      //             ),
                      //             Expanded(
                      //               flex: 7,
                      //               child: Column(
                      //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //                 children: [
                      //                   Row(
                      //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //                     children: [
                      //                       Text(docs[index]['name']),
                      //                       SizedBox(width: 120),
                      //                       Text(docs[index]['unit']),
                      //                     ],
                      //                   ),
                      //                   Padding(
                      //                     padding: const EdgeInsets.only(left: 15, right: 15),
                      //                     child: ClipRRect(
                      //                       borderRadius: BorderRadius.circular(50),
                      //                       child: LinearProgressIndicator(
                      //                         value: docs[index]['achieved']/(docs[index]['target']*30),
                      //                         // value: pastMonthData(docs),
                      //                         minHeight: 10,
                      //                         backgroundColor: Colors.grey.shade100,
                      //                         color: Color(getColor(docs[index]['color'])),
                      //                       ),
                      //                     ),
                      //                   ),
                      //                   Row(
                      //                     mainAxisAlignment: MainAxisAlignment.end,
                      //                     children: [
                      //                       Padding(
                      //                         padding: const EdgeInsets.only(right: 15),
                      //                         child: Text(docs[index]['achieved'].toString() + "/" + (docs[index]['target']*30).toString()),
                      //                       )
                      //                     ],
                      //                   )
                      //                 ],
                      //               ),
                      //             ),
                      //             Expanded(
                      //               flex: 2,
                      //               child: Padding(
                      //                 padding: const EdgeInsets.only(right: 8.0),
                      //                 child: Column(
                      //                   mainAxisAlignment: MainAxisAlignment.center,
                      //                   children: [
                      //                     FloatingActionButton(
                      //                       heroTag: null,
                      //                       backgroundColor: Color(getColor(docs[index]['color'])),
                      //                       foregroundColor: Colors.white,
                      //                       child: Icon(Icons.add),
                      //                       mini: true,
                      //                       onPressed: () {
                      //                         // firestore.runTransaction((transaction) async {
                      //                         //   DocumentSnapshot freshSnap = await transaction.get(docs.reference);
                      //                         //   await transaction.update(freshSnap.reference, {
                      //                         //     'achieved': freshSnap['achieved'] + 1,
                      //                         //   });
                      //                         // });
                      //                         // QuerySnapshot docRef = ;
                      //                         firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).update({'achieved': docs[index]['achieved'] + 1});
                      //                       },
                      //                     ),
                      //                     FloatingActionButton(
                      //                       heroTag: null,
                      //                       backgroundColor: Color(getColor(docs[index]['color'])),
                      //                       foregroundColor: Colors.white,
                      //                       child: Icon(Icons.remove),
                      //                       mini: true,
                      //                       onPressed: () {
                      //                         // firestore.runTransaction((transaction) async {
                      //                         //   DocumentSnapshot freshSnap = await transaction.get(docs.reference);
                      //                         //   await transaction.update(freshSnap.reference, {
                      //                         //     'achieved': freshSnap['achieved'] - 1,
                      //                         //   });
                      //                         // });
                      //                         // QuerySnapshot docRef = ;
                      //                         firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).update({'achieved': math.max(docs[index]['achieved'] - 1, 0)});
                      //                       },
                      //                     ),
                      //                   ],
                      //                 ),
                      //               )
                      //             ),
                      //           ],
                      //         ),
                      //       );
                      //     }),
                      //   ),
                      // ),
                      // GlowingOverscrollColorChanger(
                      //   color: Colors.amber,
                      //   child: ListView(
                      //     children: List.generate(docs.length, (index) {
                      //       return 
                      //       Container(
                      //         height: 130,
                      //         margin: EdgeInsets.all(10),
                      //         decoration: BoxDecoration(
                      //           color: Colors.white,
                      //           borderRadius: BorderRadius.circular(30),
                      //           boxShadow:[ 
                      //             BoxShadow(
                      //                 color: Colors.grey.withOpacity(0.5),
                      //                 spreadRadius: 5,
                      //                 blurRadius: 7,
                      //                 offset: Offset(0, 5),
                      //             ),
                      //           ],
                      //         ),
                      //         child: Row(
                      //           children: [
                      //             Expanded(
                      //               flex: 1,
                      //               child: Radio<QueryDocumentSnapshot>(
                      //                 value: docs[index],
                      //                 groupValue: _variable,
                      //                 onChanged: (value) {
                      //                   setState(() {
                      //                     _variable = value!;
                      //                     currentVariable = docs[index]['name'];
                      //                     variableIndex = index;
                      //                   });
                      //                 },
                      //                 activeColor: Color(getColor(docs[index]['color'])),
                      //               ),
                      //             ),
                      //             Expanded(
                      //               flex: 7,
                      //               child: Column(
                      //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //                 children: [
                      //                   Row(
                      //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //                     children: [
                      //                       Text(docs[index]['name']),
                      //                       SizedBox(width: 120),
                      //                       Text(docs[index]['unit']),
                      //                     ],
                      //                   ),
                      //                   Padding(
                      //                     padding: const EdgeInsets.only(left: 15, right: 15),
                      //                     child: ClipRRect(
                      //                       borderRadius: BorderRadius.circular(50),
                      //                       child: LinearProgressIndicator(
                      //                         value: docs[index]['achieved']/(docs[index]['target']*365),
                      //                         minHeight: 10,
                      //                         backgroundColor: Colors.grey.shade100,
                      //                         color: Color(getColor(docs[index]['color'])),
                      //                       ),
                      //                     ),
                      //                   ),
                      //                   Row(
                      //                     mainAxisAlignment: MainAxisAlignment.end,
                      //                     children: [
                      //                       Padding(
                      //                         padding: const EdgeInsets.only(right: 15),
                      //                         child: Text(docs[index]['achieved'].toString() + "/" + (docs[index]['target']*365).toString()),
                      //                       )
                      //                     ],
                      //                   )
                      //                 ],
                      //               ),
                      //             ),
                      //             Expanded(
                      //               flex: 2,
                      //               child: Padding(
                      //                 padding: const EdgeInsets.only(right: 8.0),
                      //                 child: Column(
                      //                   mainAxisAlignment: MainAxisAlignment.center,
                      //                   children: [
                      //                     FloatingActionButton(
                      //                       heroTag: null,
                      //                       backgroundColor: Color(getColor(docs[index]['color'])),
                      //                       foregroundColor: Colors.white,
                      //                       child: Icon(Icons.add),
                      //                       mini: true,
                      //                       onPressed: () {
                      //                         // firestore.runTransaction((transaction) async {
                      //                         //   DocumentSnapshot freshSnap = await transaction.get(docs.reference);
                      //                         //   await transaction.update(freshSnap.reference, {
                      //                         //     'achieved': freshSnap['achieved'] + 1,
                      //                         //   });
                      //                         // });
                      //                         // QuerySnapshot docRef = ;
                      //                         firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).collection('data').doc().update({'achieved': docs[index]['achieved'] + 1});
                      //                       },
                      //                     ),
                      //                     FloatingActionButton(
                      //                       heroTag: null,
                      //                       backgroundColor: Color(getColor(docs[index]['color'])),
                      //                       foregroundColor: Colors.white,
                      //                       child: Icon(Icons.remove),
                      //                       mini: true,
                      //                       onPressed: () {
                      //                         // firestore.runTransaction((transaction) async {
                      //                         //   DocumentSnapshot freshSnap = await transaction.get(docs.reference);
                      //                         //   await transaction.update(freshSnap.reference, {
                      //                         //     'achieved': freshSnap['achieved'] - 1,
                      //                         //   });
                      //                         // });
                      //                         // QuerySnapshot docRef = ;
                      //                         firestore.collection('users').doc(user?.uid).collection('variables').doc(docs[index]['name']).update({'achieved': math.max(docs[index]['achieved'] - 1, 0)});
                      //                       },
                      //                     ),
                      //                   ],
                      //                 ),
                      //               )
                      //             ),
                      //           ],
                      //         ),
                      //       );
                      //     }),
                      //   ),
                      // ),
                    // ]
                  // ),
                ),
              )
            ],
          );
        }
      ),
    );
  }

  pastMonthData(docs) {
    var now = DateTime.now();
    int score = 0;
    int target = 0;
    // print("Doc:" + docs.parent);
    for(int i = math.max(docs.length - 30, 0); i<docs.length; i++) {
      print("Score:" + score.toString() + " Target: " + target.toString());
      score += int.parse(docs[i]['score']);
      target += int.parse(docs[i]['target']);
    }
    return score/target;
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
            return DateFormat("EEE").format(DateTime.now().subtract(Duration(days: 6))).toString();
          case 1:
            return DateFormat("EEE").format(DateTime.now().subtract(Duration(days: 5))).toString();
          case 2:
            return DateFormat("EEE").format(DateTime.now().subtract(Duration(days: 4))).toString();
          case 3:
            return DateFormat("EEE").format(DateTime.now().subtract(Duration(days: 3))).toString();
          case 4:
            return DateFormat("EEE").format(DateTime.now().subtract(Duration(days: 2))).toString();
          case 5:
            return DateFormat("EEE").format(DateTime.now().subtract(Duration(days: 1))).toString();
          case 6:
            return DateFormat("EEE").format(DateTime.now().subtract(Duration(days: 0))).toString();
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
            return DateFormat("d/M").format(DateTime.now().subtract(Duration(days: 30))).toString();
          // case 1:
          //   return '2';
          // case 2:
          //   return '3';
          // case 3:
          //   return '4';
          // case 4:
          //   return '5';
          case 5:
            return DateFormat("d/M").format(DateTime.now().subtract(Duration(days: 25))).toString();
          // case 6:
          //   return '7';
          // case 7:
          //   return '8';
          // case 8:
          //   return '9';
          // case 9:
          //   return '10';
          case 10:
            return DateFormat("d/M").format(DateTime.now().subtract(Duration(days:20))).toString();
          // case 11:
          //   return '12';
          // case 12:
          //   return '13';
          // case 13:
          //   return '14';
          // case 14:
          //   return '15';
          case 15:
            return DateFormat("d/M").format(DateTime.now().subtract(Duration(days: 15))).toString();
          // case 16:
          //   return '17';
          // case 17:
          //   return '18';
          // case 18:
          //   return '19';
          // case 19:
          //   return '20';
          case 20:
            return DateFormat("d/M").format(DateTime.now().subtract(Duration(days: 10))).toString();
          // case 21:
          //   return '22';
          // case 22:
          //   return '23';
          // case 23:
          //   return '24';
          // case 24:
          //   return '25';
          case 25:
            return DateFormat("d/M").format(DateTime.now().subtract(Duration(days: 5))).toString();
          // case 26:
          //   return '27';
          // case 27:
          //   return '28';
          // case 28:
          //   return '29';
          // case 29:
          //   return '30';
          case 30:
            return DateFormat("d/M").format(DateTime.now().subtract(Duration(days: 0))).toString();
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
          case 1:
            return DateFormat("MMM").format(DateTime.now().subtract(Duration(days: 300))).toString();
          // case 1:
          //   return 'FEB';
          case 3:
            return DateFormat("MMM").format(DateTime.now().subtract(Duration(days: 240))).toString();
          // case 3:
          //   return 'APR';
          case 5:
            return DateFormat("MMM").format(DateTime.now().subtract(Duration(days: 180))).toString();
          // case 5:
          //   return 'JUN';
          case 7:
            return DateFormat("MMM").format(DateTime.now().subtract(Duration(days: 120))).toString();
          // case 7:
          //   return 'AUG';
          case 9:
            return DateFormat("MMM").format(DateTime.now().subtract(Duration(days: 60))).toString();
          // case 9:
          //   return 'OCT';
          case 11:
            return DateFormat("MMM").format(DateTime.now().subtract(Duration(days: 0))).toString();
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
  int target;
  Data(this.date, this.score, this.target);
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