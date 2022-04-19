import 'package:flutter/material.dart' hide NavigationBar;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../widgets/playerControls.dart';
import '../widgets/colors.dart';
import '../widgets/albumart.dart';
import '../widgets/navbar.dart';
import '../model/myaudio.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../widgets/notification_utils.dart';

class MusicScreen extends StatefulWidget {
  //List<Map<String, String>> data;
  String header;
  MusicScreen(this.header, {Key? key}) : super(key: key);

  @override
  _MusicScreenState createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user;
  var _isLoading = true;
  List<Reminder> reminders = [];
  List<Map<String, String>> firestoreData = [];
  double sliderValue = 2;
  FirebaseStorage? storage;
  Reference? ref;
  var p;

  @override
  void initState() {
    //debugPrint("Length: ${widget.data.length}");
    if (_isLoading) {
      user = auth.currentUser;
      super.initState();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    AwesomeNotifications().createdSink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    p = Provider.of<MyAudio>(context);
    List<Map<String, String>> data = p.getData();
    //debugPrint("Length: ${data.length}");
    int index = p.getIndex();
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        p.clearList();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          // backgroundColor: const Color(0xff81dc17),
          title: Text(widget.header),
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
                  Color.fromARGB(255, 68, 175, 231),
                  Color.fromARGB(255, 13, 42, 79)
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp
              ),
            ),
          ),
        ),
        body: data.isEmpty ? Center(child: CircularProgressIndicator(),) : Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            NavigationBar(),
            Container(
              margin: EdgeInsets.only(left: 40),
              height: height / 2.5,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return AlbumArt();
                },
                itemCount: 1,
                scrollDirection: Axis.horizontal,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: FittedBox(
                child: Text(data[index]['name']!,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade900),
                ),
              ),
            ),
            // Text(
            //   'The Free Nationals',
            //   style: TextStyle(
            //       fontSize: 20,
            //       fontWeight: FontWeight.w400,
            //       color: darkPrimaryColor),
            // ),
            Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                      trackHeight: 5,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5)
                  ),
                  child: Consumer<MyAudio>(
                    builder:(_,myAudioModel,child)=> Slider(
                      value: myAudioModel.position==null? 0 : myAudioModel.position.inMilliseconds.toDouble() ,
                      activeColor: primaryColor,
                      inactiveColor: primaryColor.withOpacity(0.3),
                      onChanged: (value) {
    
                        myAudioModel.seekAudio(Duration(milliseconds: value.toInt()));
    
                      },
                      min: 0,
                      max:myAudioModel.totalDuration==null? 20 : myAudioModel.totalDuration.inMilliseconds.toDouble() ,
                    ),
                  ),
                ),
              ],
    
            ),
    
            PlayerControls(ref),
    
          ],
        ),
      ),
    );
  }
}