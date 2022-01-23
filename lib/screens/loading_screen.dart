import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    debugPrint('Loading spinner called');
    return Container(
      color: Colors.white,
      child: Center(
        child: SpinKitCircle(
          color: Colors.blue,
          size: 50,
        ),
      ),
    );
  }
}
