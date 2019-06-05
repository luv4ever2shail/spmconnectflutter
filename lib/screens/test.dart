// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';

// class CurrentLocationWidget extends StatefulWidget {
//   @override
//   _LocationState createState() => _LocationState();
// }

// class _LocationState extends State<CurrentLocationWidget> {
//   Position _position;

//   @override
//   void initState() {
//     super.initState();
//     _initPlatformState();
//   }

//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> _initPlatformState() async {
//     Position position;
//     // Platform messages may fail, so we use a try/catch PlatformException.
//     try {
//       final Geolocator geolocator = Geolocator()
//         ..forceAndroidLocationManager = true;
//       position = await geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.bestForNavigation);
//     } on PlatformException {
//       position = null;
//     }
//     if (!mounted) {
//       return;
//     }

//     setState(() {
//       _position = position;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<GeolocationStatus>(
//           future: Geolocator().checkGeolocationPermissionStatus(),
//           builder: (BuildContext context,
//               AsyncSnapshot<GeolocationStatus> snapshot) {
//             if (!snapshot.hasData) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (snapshot.data == GeolocationStatus.denied) {
//               return const Text(
//                   'Allow access to the location services for this App using the device settings.');
//             }
//             return Text(_position.toString());
//           }),
//     );
//   }
// }

// import 'package:flutter/material.dart';

// class Testpage extends StatefulWidget {
//   @override
//   _TestpageState createState() => new _TestpageState();
// }

// class _TestpageState extends State<Testpage>
//     with SingleTickerProviderStateMixin {
//   double age = 0.0;
//   var selectedYear;
//   Animation animation;
//   AnimationController animationController;

//   @override
//   void initState() {
//     animationController = new AnimationController(
//         vsync: this, duration: new Duration(milliseconds: 1500));
//     animation = animationController;
//     super.initState();
//   }

//   @override
//   void dispose() {
//     animationController.dispose();
//     super.dispose();
//   }

//   void _showPicker() {
//     showDatePicker(
//             context: context,
//             firstDate: new DateTime(1900),
//             initialDate: new DateTime(2018),
//             lastDate: DateTime.now())
//         .then((DateTime dt) {
//       selectedYear = dt.year;
//       calculateAge();
//     });
//   }

//   void calculateAge() {
//     setState(() {
//       age = (2018 - selectedYear).toDouble();
//       animation = new Tween<double>(begin: animation.value, end: age).animate(
//           new CurvedAnimation(
//               curve: Curves.fastOutSlowIn, parent: animationController));

//       animationController.forward(from: 0.0);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return new Scaffold(
//       appBar: new AppBar(
//         title: new Text("Age Calculator"),
//       ),
//       body: new Center(
//         child: new Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             new OutlineButton(
//               child: new Text(selectedYear != null
//                   ? selectedYear.toString()
//                   : "Select your year of birth"),
//               borderSide: new BorderSide(color: Colors.black, width: 3.0),
//               color: Colors.white,
//               onPressed: _showPicker,
//             ),
//             new Padding(
//               padding: const EdgeInsets.all(20.0),
//             ),
//             new AnimatedBuilder(
//               animation: animation,
//               builder: (context, child) => new Text(
//                     "Your Age is ${animation.value.toStringAsFixed(0)}",
//                     style: new TextStyle(
//                         fontSize: 30.0,
//                         fontWeight: FontWeight.bold,
//                         fontStyle: FontStyle.italic),
//                   ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class Home extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => new _MyHomePageState();
// }

// class _MyHomePageState extends State<Home> {
//   DateTime selected;

//   _showDateTimePicker() async {
//     selected = await showDatePicker(
//       context: context,
//       initialDate: new DateTime.now(),
//       firstDate: new DateTime(1960),
//       lastDate: new DateTime(2050),
//     );

//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     var dateFormat_1 = new Column(
//       children: <Widget>[
//         new SizedBox(
//           height: 30.0,
//         ),

//         selected != null
//             ? new Text(
//                 new DateFormat('yyyy-MMMM-dd').format(selected),
//                 style: new TextStyle(
//                   color: Colors.black,
//                   fontSize: 20.0,
//                 ),
//               )
//             : new SizedBox(
//                 width: 0.0,
//                 height: 0.0,
//               ),

//                Padding(
//               padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
//               child: TextField(
//                 textInputAction: TextInputAction.newline,
//                 onChanged: (value) {
//                   debugPrint('Something changed in Work Performed Text Field');
//                 },
//                 decoration: InputDecoration(
//                     labelText: DateFormat('yyyy-MMMM-dd').format(selected),
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(5.0))),
//               ),
//             ),
//       ],
//     );

//     var dateFormat_2 = new Column(
//       children: <Widget>[
//         new SizedBox(
//           height: 30.0,
//         ),
//         selected != null
//             ? new Text(
//                 new DateFormat('yyyy-MM-dd').format(selected),
//                 style: new TextStyle(
//                   color: Colors.deepPurple,
//                   fontSize: 20.0,
//                 ),
//               )
//             : new SizedBox(
//                 width: 0.0,
//                 height: 0.0,
//               ),
//       ],
//     );

//     var dateStringParsing = new Column(
//       children: <Widget>[
//         new SizedBox(
//           height: 30.0,
//         ),
//         selected != null
//             ? new Text(
//                 new DateFormat('yyyy-MM-dd h:m:ss').format(DateTime.now()),
//                 style: new TextStyle(
//                   color: Colors.green,
//                   fontSize: 20.0,
//                 ),
//               )
//             : new SizedBox(
//                 width: 0.0,
//                 height: 0.0,
//               ),
//       ],
//     );

//     var dateUtcLocal = new Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         new SizedBox(
//           height: 30.0,
//         ),
//         selected != null
//             ? new Text(
//                 "UTC: " +
//                     new DateFormat('yyyy-MM-dd h:m:s').format(selected.toUtc()),
//                 style: new TextStyle(
//                   color: Colors.blue,
//                   fontSize: 20.0,
//                 ),
//               )
//             : new SizedBox(
//                 width: 0.0,
//                 height: 0.0,
//               ),
//         new SizedBox(
//           height: 30.0,
//         ),
//         selected != null
//             ? new Text(
//                 "Local: " +
//                     new DateFormat('yyyy-MM-dd h:m:s')
//                         .format(selected.toLocal()),
//                 style: new TextStyle(
//                   color: Colors.black26,
//                   fontSize: 20.0,
//                 ),
//               )
//             : new SizedBox(
//                 width: 0.0,
//                 height: 0.0,
//               ),
//       ],
//     );

//     var compareDates = new Column(
//       children: <Widget>[
//         new Text(
//           selected != null
//               ? selected.isBefore(new DateTime.now()) ? ": True" : ": False"
//               : "",
//           style: new TextStyle(color: Colors.red, fontSize: 20.0),
//         ),
//       ],
//     );

//     var dateComapereFormat = new Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         selected != null
//             ? new Text(
//                 new DateFormat('yyyy-MM-dd').format(selected),
//                 style: new TextStyle(color: Colors.green, fontSize: 17.0),
//               )
//             : new SizedBox(
//                 width: 0.0,
//                 height: 0.0,
//               ),
//         new SizedBox(
//           width: 10.0,
//         ),
//         selected != null
//             ? new Text(
//                 "Before",
//                 style: new TextStyle(color: Colors.green, fontSize: 17.0),
//               )
//             : new SizedBox(
//                 width: 0.0,
//                 height: 0.0,
//               ),
//         new SizedBox(
//           width: 10.0,
//         ),
//         selected != null
//             ? new Text(
//           new DateFormat('yyyy-MM-dd').format(new DateTime.now()),
//           style: new TextStyle(color: Colors.green, fontSize: 17.0),
//         ): new SizedBox(
//           width: 0.0,
//           height: 0.0,
//         ),
//         new SizedBox(
//           width: 10.0,
//         ),
//         compareDates,
//       ],
//     );
//     return new Scaffold(
//         appBar: new AppBar(
//           title: new Text(
//             "Date and Time",
//             style: new TextStyle(color: Colors.white),
//           ),
//           actions: <Widget>[
//             new IconButton(
//               icon: new Icon(
//                 Icons.date_range,
//                 color: Colors.white,
//               ),
//               onPressed: () => _showDateTimePicker(),
//             )
//           ],
//         ),
//         body: new Padding(
//           padding: EdgeInsets.all(20.0),
//           child: new Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               dateFormat_1,
//               dateFormat_2,
//               dateStringParsing,
//               dateUtcLocal,
//               new SizedBox(
//                 height: 20.0,
//               ),
//               dateComapereFormat
//             ],
//           ),
//         ));
//   }
// }
