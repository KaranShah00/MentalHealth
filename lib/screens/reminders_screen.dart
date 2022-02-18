import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({Key? key}) : super(key: key);

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> with SingleTickerProviderStateMixin {
  @override
  int range = 0;

  void _onItemTapped(int index) {
    setState(() {
      range = index;
    });
  }

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffec407a),
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
      ),
      body: Container(
        child: SafeArea(
          child: Text("Home Page"),
        ),
      ),
    );
  }
}

// class LineTilesWeek {
//   static getTitleData() => FlTitlesData(
//     show: true,
//     topTitles: SideTitles(
//       showTitles: false),
//     bottomTitles: SideTitles(
//       showTitles: true,
//       reservedSize: 20,
//       getTitles: (value) {
//         switch (value.toInt()) {
//           case 0:
//             return 'MON';
//           case 1:
//             return 'TUE';
//           case 2:
//             return 'WED';
//           case 3:
//             return 'THUR';
//           case 4:
//             return 'FRI';
//           case 5:
//             return 'SAT';
//           case 6:
//             return 'SUN';
//         }
//         return '';
//       },
//       margin: 8,
//     ),
//     leftTitles: SideTitles(
//       showTitles: true,
//       reservedSize: 20,
//       getTitles: (value) {
//         switch (value.toInt()) {
//           case 4:
//             return '25';
//           case 9:
//             return '50';
//           case 14:
//             return '75';
//           case 19:
//             return '100';
//         }
//         return '';
//       },
//     ),
//     rightTitles: SideTitles(
//       showTitles: false,
//     )
//   );
// }

// class LineTilesMonth {
//   static getTitleData() => FlTitlesData(
//     show: true,
//     topTitles: SideTitles(
//       showTitles: false),
//     bottomTitles: SideTitles(
//       showTitles: true,
//       reservedSize: 20,
//       getTitles: (value) {
//         switch (value.toInt()) {
//           case 0:
//             return 'JAN';
//           // case 1:
//           //   return 'FEB';
//           case 2:
//             return 'MAR';
//           // case 3:
//           //   return 'APR';
//           case 4:
//             return 'MAY';
//           // case 5:
//           //   return 'JUN';
//           case 6:
//             return 'JUL';
//           // case 7:
//           //   return 'AUG';
//           case 8:
//             return 'SEP';
//           // case 9:
//           //   return 'OCT';
//           case 10:
//             return 'NOV';
//           // case 11:
//           //   return 'DEC';
//         }
//         return '';
//       },
//       margin: 8,
//     ),
//     leftTitles: SideTitles(
//       showTitles: true,
//       reservedSize: 20,
//       getTitles: (value) {
//         switch (value.toInt()) {
//           case 4:
//             return '25';
//           case 9:
//             return '50';
//           case 14:
//             return '75';
//           case 19:
//             return '100';
//         }
//         return '';
//       },
//     ),
//     rightTitles: SideTitles(
//       showTitles: false,
//     )
//   );
// }