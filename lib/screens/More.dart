import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tabpos/screens/CategoryPage.dart';
import 'package:tabpos/screens/ProductListPage.dart';
import 'package:tabpos/screens/SalesReportPage.dart';
import 'package:tabpos/screens/StockCheckPage.dart';
import 'package:tabpos/screens/Transaction.dart';
import 'package:tabpos/screens/home_page.dart';

class MoreOptionsListView extends StatefulWidget {
  @override
  _MoreOptionsListViewState createState() => _MoreOptionsListViewState();
}

class _MoreOptionsListViewState extends State<MoreOptionsListView> {
  List<String> options = [
    'Edit Products',
    'Check Product Stock',
    'Generate Sales Reports',
    'Product Categories',
  ];

  bool hasNotifications = false;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();


  int selectedIndex = 0;
  String sortOption = 'All'; // Default sorting option

  @override
  void initState() {
    super.initState();
     fetchLowProductsNotification();
  }

  Future<void> fetchLowProductsNotification() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('qty', isLessThanOrEqualTo: 5)
          .get();

      setState(() {
        hasNotifications = snapshot.docs.isNotEmpty;
      });

      if (hasNotifications) {
        // Display notification
        String productName = snapshot.docs.first.get('name');
        showNotification(productName);
      }

      // Rest of the code...
    } catch (error) {
      print('Failed to fetch products: $error');
    }
  }

  void showNotification(String productName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Low Quantity Products',
      '$productName have a quantity of 5 or less.',
      platformChannelSpecifics,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'More',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        centerTitle: true, // Center the title
        backgroundColor: Color.fromARGB(255, 65, 84, 146),
        automaticallyImplyLeading:
            false, // Remove the back arrow button// Set the background color
      ),
      body: ListView.builder(
        itemCount: options.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(options[index]),
            onTap: () {
              // Handle the tap on the respective options here
              switch (index) {
                case 0:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductListPage()),
                  );
                  break;
                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StockCheckPage()),
                  );
                  break;
                case 2:
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SalesReportPage()),
                  );
                  break;
                case 3:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategoryPage()),
                  );
                  break;
                default:
                  break;
              }
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            selectedIndex = index;
            if (index == 0) {
              // Navigate to TransactionsListView when the "Transactions" icon is clicked (index == 1).
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            }
            if (index == 1) {
              // Navigate to TransactionsListView when the "Transactions" icon is clicked (index == 1).
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TransactionsListView()),
              );
            }

            if (index == 2) {
              // Reset the notification indicator when the 'Notifications' tab is tapped
              setState(() {
                hasNotifications = false;
              });
            }
            if (index == 3) {
              // Navigate to TransactionsListView when the "Transactions" icon is clicked (index == 1).
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MoreOptionsListView()),
              );
            }
          });
        },
        currentIndex: selectedIndex,
        selectedItemColor:
            Color.fromARGB(255, 65, 84, 146), // Set the selected item color
        unselectedItemColor: Colors.black, // Set the unselected item color
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Checkout',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.swap_horiz,
            ),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.notifications),
                if (hasNotifications)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
