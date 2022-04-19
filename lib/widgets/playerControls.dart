import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../model/myaudio.dart';
import 'colors.dart';

class PlayerControls extends StatelessWidget {
  final Reference? ref;

  PlayerControls(this.ref);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          // Controls(
          //   icon: Icons.repeat,
          //   type: 'load',
          //   ref: ref,
          // ),
          Controls(icon: Icons.skip_previous, type: 'prev'),
          PlayControl(),
          Controls(icon: Icons.skip_next, type: 'next'),
          Controls(
            icon: Icons.shuffle,
            type: 'shuffle',
          ),
        ],
      ),
    );
  }
}

class PlayControl extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MyAudio>(
      builder: (_, myAudioModel, child) => GestureDetector(
        onTap: () {
          myAudioModel.audioState == "Playing"
              ? myAudioModel.pauseAudio()
              : myAudioModel.playAudio();
        },
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.grey,
                  offset: Offset(5,5),
                  spreadRadius: 1,
                  blurRadius: 10
              ),
              // BoxShadow(
              //     color: Colors.white,
              //     offset: Offset(-3, -4),
              //     spreadRadius: -2,
              //     blurRadius: 20)
            ],
          ),
          child: Stack(
            children: <Widget>[
              // Center(
              //   child: Container(
              //     margin: EdgeInsets.all(6),
              //     decoration: BoxDecoration(
              //         color: darkPrimaryColor,
              //         shape: BoxShape.circle,
              //         boxShadow: [
              //           BoxShadow(color: Colors.grey,
              //               offset: Offset(5,5),
              //               spreadRadius: 1,
              //               blurRadius: 10
              //           ),
              //           // BoxShadow(
              //           //     color: Colors.white,
              //           //     offset: Offset(-3, -4),
              //           //     spreadRadius: -2,
              //           //     blurRadius: 20)
              //         ]),
              //   ),
              // ),
              Center(
                child: Container(
                  margin: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: primaryColor, shape: BoxShape.circle),
                  child: Center(
                      child: Icon(
                    myAudioModel.audioState == "Playing"
                        ? Icons.pause
                        : Icons.play_arrow,
                    size: 50,
                    color: Colors.white,
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Controls extends StatelessWidget {
  final IconData? icon;
  final String? type;
  final Reference? ref;

  const Controls({Key? key, this.icon, this.type, this.ref}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MyAudio>(
      builder: (_, myAudioModel, child) => GestureDetector(
        onTap: () async {
          if (type == 'next') {
            myAudioModel.nextAudio();
          } else if (type == 'prev') {
            myAudioModel.prevAudio();
          } else if (type == 'load') {
            ListResult result = await ref!.listAll();
            List<Map<String, String>> data = [];
            for (Reference r in result.items) {
              data.add({
                'url': await r.getDownloadURL(),
                'name': r.name,
                'image':
                    'https://thegrowingdeveloper.org/thumbs/1000x1000r/audios/quiet-time-photo.jpg',
              });
            }
            myAudioModel.addData(data);
          } else if (type == 'shuffle') {
            myAudioModel.shuffleList();
          }
        },
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.grey,
                  offset: Offset(5,5),
                  spreadRadius: 1,
                  blurRadius: 10
              ),
              // BoxShadow(
              //     color: Colors.white,
              //     offset: Offset(-3, -4),
              //     spreadRadius: -2,
              //     blurRadius: 20)
            ],
          ),
          child: Stack(
            children: <Widget>[
              // Center(
              //   child: Container(
              //     margin: EdgeInsets.all(6),
              //     decoration: BoxDecoration(
              //         color: Colors.grey,
              //         shape: BoxShape.circle,
              //         boxShadow: [
              //           BoxShadow(color: Colors.grey,
              //               offset: Offset(5,5),
              //               spreadRadius: 1,
              //               blurRadius: 10
              //           ),
              //           // BoxShadow(
              //           //     color: Colors.white,
              //           //     offset: Offset(-3, -4),
              //           //     spreadRadius: -2,
              //           //     blurRadius: 20)
              //         ]),
              //   ),
              // ),
              Center(
                child: Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: primaryColor, shape: BoxShape.circle),
                  child: Center(
                      child: Icon(
                    icon,
                    size: 30,
                    color: Colors.white,
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
