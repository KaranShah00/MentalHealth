import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:expandable/expandable.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mental_health/screens/recommendation_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  // var text = 'Not ready';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: const Color(0xff8000ff),
        title: const Text('Mental Wellness'),
        actions: [
          TextButton(
              child: const Icon(
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
                  Color.fromARGB(255, 255, 111, 0),
                  Color.fromARGB(255, 220, 23, 23)
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Color.fromARGB(255, 255, 106, 0),
      //   onPressed: () => launch("tel://9820466726"),
      //   child: Icon(
      //     Icons.call
      //   )
      // ),
      body: Container(
        child: Column(
          children: [
            Container(
              width: 450,
              height: 100,
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
                  colors: [Color.fromARGB(255, 255, 111, 0),Color.fromARGB(255, 220, 23, 23)]
                ),
              ),
              padding: EdgeInsets.all(10),
              child: Center(
                child: Text(
                  "Going through something? We can help:",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 20,
                    color: Colors.white
                  ),
                ),
              )
            ),
            Expanded(
              child: ListView(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
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
                    child: ExpandablePanel(
                      header: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Depression',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            color: Colors.black
                          ),
                        ),
                      ),
                      collapsed: Container(),
                      expanded: Container(
                        // height: 200,
                        margin: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    'Going through or experiencing depression can serve as immensely challenging. Depression can have very serious impacts on your physical body, mental and emotional wellbeing and so much more. But don\'t worry; we\'re here to help you. Here are some things you can do to take your mind away from itself:\n',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.black
                                    ),
                                      textAlign: TextAlign.justify,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '1. Set Plans: Setting plans may sound basic and redundant, but planning is an excellent way of giving yourself something to look forward to.',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '2. Interact With Other People: Isolation is one of the greatest and most unhealthy enablers of depression. Being around others can boost your mood and really bring some sunshine into your life. Have a conversation, exchange words, and don\'t be afraid of other people. In both the short term and the long term, you will thank yourself.',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '3. Seek Professional Help: Seeking professional help can make a significantly positive difference in your life. Working with someone who knows and understands depression on a very deep level is often a major turning point. A person like a counselor or therapist also has the ability to provide fresh insight and details which you may not previously have thought of.',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(50, 45),
                                      primary: Color.fromARGB(255, 255, 106, 0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(23)
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) {
                                          return RecommendationScreen('sad');
                                        }),
                                      );
                                    },
                                    child: Text(
                                      'Go To Recommendations',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300
                                      ),
                                    )
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
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
                    child: ExpandablePanel(
                      header: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Anxiety',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            color: Colors.black
                          ),
                        ),
                      ),
                      collapsed: Container(),
                      expanded: Container(
                        // height: 200,
                        margin: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    'Living with anxiety is never easy. Learning to control anxiety is a long-term process. If you\'re suffering from anxiety right now, or you suffer from anxiety often enough that you need immediate relief, try the following anxiety reduction strategies:\n',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.black
                                    ),
                                      textAlign: TextAlign.justify,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '1. Control Your Breathing: Severe anxiety symptoms are often linked to poor breathing habits. Controlling your breathing is a solution. Even if you feel you can\'t take a deep breath, you actually need to slow down and reduce your breathing, not speed it up or try to take deeper breaths.',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '2. Talk To Someone Friendly: Talk to someone you like and trust, especially on the phone. Don\'t be shy about your anxiety - tell them you feel anxious and explain what you\'re feeling. Talking to nice, empathetic people keeps your mind off of your symptoms, and the supportive nature of friends and family gives you an added boost of confidence.',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '3. Try Some Aerobic Activity: During periods of anxiety, your body is filled with adrenaline. Putting that adrenaline toward aerobic activity can be a great way to improve your anxiety. Aerobic activity, like light jogging or even fast walking, can be extremely effective at reducing the severity of your anxiety symptoms, as well as the anxiety itself.',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(50, 45),
                                      primary: Color.fromARGB(255, 255, 106, 0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(23)
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) {
                                          return RecommendationScreen('fear');
                                        }),
                                      );
                                    },
                                    child: Text(
                                      'Go To Recommendations',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300
                                      ),
                                    )
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
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
                    child: ExpandablePanel(
                      header: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Stress',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            color: Colors.black
                          ),
                        ),
                      ),
                      collapsed: Container(),
                      expanded: Container(
                        // height: 200,
                        margin: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    'You might not be able to change what is stressing you out, but you can control how you react and respond to stress. If you notice that you’re showing signs of stress, here are some things you can do to help yourself:\n',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.black
                                    ),
                                      textAlign: TextAlign.justify,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '1. Leave the room: Getting up and removing yourself from the stressful situation can be a huge help. A brief change of scenery can help put some distance between you and your overwhelming feelings.',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '2. Organize: Pick something small: your desk, your closet, or your to-do list are all great choices. Spend 20 minutes focused on tidying up—it will help you feel in control of something and give you a sense of accomplishment.',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '3. Write It Out: When your feelings start to bubble up and get overwhelming, putting them on paper can help you untangle them. Try a stream of consciousness exercise: 10 minutes of writing down all your thoughts without hesitating. Or make a list of things stressing you out—seeing them reduced to bullet points can help you think more clearly.',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(50, 45),
                                      primary: Color.fromARGB(255, 255, 106, 0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(23)
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) {
                                          return RecommendationScreen('fear');
                                        }),
                                      );
                                    },
                                    child: Text(
                                      'Go To Recommendations',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300
                                      ),
                                    )
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 255, 111, 0),
                          Color.fromARGB(255, 220, 23, 23)
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
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
                    child: ExpandablePanel(
                      header: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Suicide Prevention Hotline',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            color: Colors.white
                          ),
                        ),
                      ),
                      collapsed: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 8,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("You are not alone.",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300
                                ),),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: FloatingActionButton(
                                foregroundColor: Color.fromARGB(255, 255, 106, 0),
                                backgroundColor: Colors.white,
                                onPressed: () => launch("tel://9820466726"),
                                child: Icon(
                                  Icons.call
                                )
                              ),
                            ),
                          ],
                        ),
                      ),
                      expanded: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 8,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "You are not alone. You matter. Help is always available. Talk to a friend or a relative. Tell them how you are feeling. It is never too late. Or, reach out to us. Call the suicide prevention center now.",
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: FloatingActionButton(
                                foregroundColor: Color.fromARGB(255, 255, 106, 0),
                                backgroundColor: Colors.white,
                                onPressed: () => launch("tel://9820466726"),
                                child: Icon(
                                  Icons.call
                                )
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
      // floatingActionButton: Row(
      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //   children: [
      //     FloatingActionButton(
      //       child: const Icon(Icons.add_a_photo),
      //       onPressed: getImageFromCamera,
      //     ),
      //     FloatingActionButton(
      //       child: const Icon(Icons.photo),
      //       onPressed: getImageFromGallery,
      //     ),
      //   ],
      // ),
    );
  }
}
