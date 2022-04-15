import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class MyAudio extends ChangeNotifier{

  Duration totalDuration = Duration();
  Duration position = Duration();
  String audioState = "";

  MyAudio(){
    initAudio();
  }

  List<Map<String, String>> audioData = [{
    'image': 'https://thegrowingdeveloper.org/thumbs/1000x1000r/audios/quiet-time-photo.jpg',
    'url': 'https://thegrowingdeveloper.org/files/audios/quiet-time.mp3?b4869097e4',
    'name': 'Quiet time'
  },
    {
      'image': 'https://thegrowingdeveloper.org/thumbs/1000x1000r/audios/quiet-time-photo.jpg',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      'name': 'SoundHelix-Song-1'
    },
    {
      'image': 'https://thegrowingdeveloper.org/thumbs/1000x1000r/audios/quiet-time-photo.jpg',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
      'name': 'SoundHelix-Song-4'
    },
  ];

  List<Map<String, String>> getData() {
    return [...audioData];
  }

  int getIndex() {
    return index;
  }

  int index = 0;

  AudioPlayer audioPlayer = AudioPlayer();

  initAudio(){
    audioPlayer.onDurationChanged.listen((updatedDuration) {
        totalDuration = updatedDuration;
        notifyListeners();
    });

    audioPlayer.onAudioPositionChanged.listen((updatedPosition) {
        position = updatedPosition;
        notifyListeners();
    });

    audioPlayer.onPlayerCompletion.listen((event) {
      nextAudio();
      notifyListeners();
    });

    audioPlayer.onPlayerStateChanged.listen((playerState) {
      if(playerState == PlayerState.STOPPED)
        audioState = "Stopped";
      if(playerState==PlayerState.PLAYING)
        audioState = "Playing";
      if(playerState == PlayerState.PAUSED)
        audioState = "Paused";
      notifyListeners();
    });
  }

  playAudio(){
    audioPlayer.play(audioData[index]['url']!, stayAwake: true);
  }

  addData(List<Map<String, String>> data) {
    audioData.addAll(data);
  }

  shuffleList() {
    index = 0;
    audioPlayer.stop();
    audioData.shuffle();
    playAudio();
  }

  pauseAudio(){
    audioPlayer.pause();
  }

  stopAudio(){
    audioPlayer.stop();
  }

  seekAudio(Duration durationToSeek){
    audioPlayer.seek(durationToSeek);
  }

  nextAudio() {
    audioPlayer.stop();
    index = (index + 1) % audioData.length;
    audioPlayer.play(audioData[index]['url']!);
  }

  prevAudio() {
    audioPlayer.stop();
    index = (index - 1) % audioData.length;
    audioPlayer.play(audioData[index]['url']!);
  }
}