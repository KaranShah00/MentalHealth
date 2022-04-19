import 'package:flutter/material.dart';
import './colors.dart';


class AlbumArt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: 260,
      // padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 35,vertical: 35),
      child: ClipRRect(
          // borderRadius: BorderRadius.circular(20),
          child: Image.asset('images/img.png',fit: BoxFit.fill,)),
      decoration: BoxDecoration(
        // color: primaryColor,
        // borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.5), //color of shadow
              spreadRadius: 0, //spread radius
              blurRadius: 7, // blur radius
              offset: Offset(5, 5),
            )
          // BoxShadow(color: Colors.white,offset: Offset(-3,-4),spreadRadius: -2,blurRadius: 20
          // )
        ],

      ),

    );
  }
}
