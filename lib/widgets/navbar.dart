import 'package:flutter/material.dart';
import './colors.dart';

class NavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.bottomCenter,
      child: Center(
          child: Text('Playing Now',style: TextStyle(fontSize: 20,color: Colors.black, fontWeight: FontWeight.w400, letterSpacing: 3),),
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  final IconData? icon;

  const NavBarItem({Key? key, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: darkPrimaryColor.withOpacity(0.5),
          offset: Offset(5,10),
            spreadRadius: 3,
            blurRadius: 10
          ),
          BoxShadow(color: Colors.white,offset: Offset(-3,-4),spreadRadius: -2,blurRadius: 20
          )
        ],
          color: primaryColor, borderRadius: BorderRadius.circular(10)),
      child: Icon(
        icon,
        color: darkPrimaryColor,
      ),
    );
  }
}
