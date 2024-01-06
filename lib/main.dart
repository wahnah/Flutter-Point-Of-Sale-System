import 'package:flutter/material.dart';
import 'package:tabpos/firebase_options.dart';
import 'package:tabpos/screens/More.dart';
import 'package:tabpos/screens/NotificationManager.dart';
import 'screens/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tabpos/screens/Transaction.dart';


void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationManager.initialize();
 await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform
 );
  runApp(MyApp());
  }

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final routes = <String, WidgetBuilder>{
 //   '/check': (BuildContext context) => new Check(),
    
   '/Transaction': (BuildContext context) => new TransactionsListView(),
   '/More': (BuildContext context) => new MoreOptionsListView(),
 //   '/signup': (BuildContext context) => new Signup(),
   // '/inventory':(BuildContext context) => new Inventory(),
 //   '/invoice':(BuildContext context) => new Invoice(),
  //  '/Cotation':(BuildContext context) => new Cotation(),
  //  '/CheckOut':(BuildContext context) => new CheckOut(),
  //  '/cartpage': (BuildContext context) => new Cart(),
  //  '/mgtpage': (BuildContext context) => new MgtPage(),
  //  '/pospage': (BuildContext context) => new PosPage(),
   // '/purchasehistory':  (BuildContext context) => new PurchaseHistory(),
   // '/PDFViewerPage':  (BuildContext context) => new PDFViewerPage(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tabpos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        fontFamily: 'Nunito',
      ),
      home: HomePage(),
      routes: routes,
    );
  }
}
