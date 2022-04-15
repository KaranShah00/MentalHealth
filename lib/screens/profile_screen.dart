import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mental_health/screens/journal_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user;
  late String name = "";
  bool trackDataValue = false;
  bool _isLoading = true;
  var data;

  // static const List<Color> lineColor = [
  //   Color(0xffffffff),
  // ];

  @override
  void initState() {
    user = auth.currentUser;
    super.initState();
    // print(user);
    data = firestore.collection('users').doc(user?.uid);
    data.get().then((value) {
      setState(() {
        name = value.data()!['username'];
        trackDataValue = value.data()!['track'];
        _isLoading = false;
      });
    });
  }

  void toggleSwitch(bool value) async{
    await data.update({'track': !trackDataValue});
    setState(() {
      trackDataValue = !trackDataValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? const Center(child: CircularProgressIndicator(),) : Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff44afe7), Color(0xff0d2a4f)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Color(0xff1d517c),
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
              gradient: new LinearGradient(
                  colors: [
                    const Color(0xff44afe7),
                    const Color(0xff0d2a4f),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      child: Container(
                        alignment: Alignment(0.0, 1),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                              "https://cdn.iconscout.com/icon/free/png-256/avatar-370-456322.png"),
                          radius: 60.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    name,
                    style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Personal Information",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400),
                      ),
                      IconButton(
                          onPressed: null,
                          icon: Icon(
                            Icons.edit,
                            color: Colors.white,
                          )),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "My Journal",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400),
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return JournalScreen(trackDataValue);
                              }),
                            );
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Colors.white,
                          )),
                    ],
                  ),
                  SizedBox(
                    height: 70,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Settings",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Track My Data",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400),
                      ),
                      Switch(
                        value: trackDataValue,
                        onChanged: toggleSwitch,
                        activeColor: Colors.white,
                        inactiveThumbColor: Colors.grey,
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "App Themes",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400),
                      ),
                      // DropdownButton<String>(
                      //   // value: value,
                      //   dropdownColor: Colors.black,
                      //   icon: Icon(
                      //     Icons.arrow_drop_down_circle_rounded,
                      //     color: Colors.white,
                      //   ),
                      //   underline: Container(),
                      //   items: items.map(buildMenuItem).toList(),
                      //   onChanged: (value) => setState(() => this.value = value),
                      // ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.arrow_drop_down_circle_rounded,
                          color: Colors.white,
                        ),
                        onSelected: (String result) {
                          switch (result) {
                            case 'Dark':
                              break;
                            case 'Light':
                              break;
                            case 'Colorful':
                              break;
                            default:
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'Dark',
                            child: Text('Dark'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'Light',
                            child: Text('Light'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'Colorful',
                            child: Text('Colorful'),
                          ),
                        ],
                      ),
                      // IconButton(
                      //   onPressed: null,
                      //   icon: Icon(
                      //     Icons.arrow_drop_down_circle_rounded,
                      //     color: Colors.white,
                      //   )
                      // ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Delete Account",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400),
                      ),
                      IconButton(
                          onPressed: null,
                          icon: Icon(
                            Icons.delete,
                            color: Colors.white,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
