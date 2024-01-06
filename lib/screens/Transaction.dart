import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tabpos/screens/More.dart';
import 'package:tabpos/screens/home_page.dart';
import 'package:intl/intl.dart';


class Transaction {
  final int transactionNumber;
  final double totalPrice;
  final List<Map<String, dynamic>> products;
  
  final String date;
  
  // You can add more properties here if needed

  Transaction({
    required this.transactionNumber,
    required this.products,
    required this.totalPrice, 
    required this.date,
  });
  
  
}

class TransactionsListView extends StatefulWidget {
  @override
  _TransactionsListViewState createState() => _TransactionsListViewState();
}

class _TransactionsListViewState extends State<TransactionsListView> {
  List<Transaction> transactions = [];
  int selectedIndex = 0;
  String sortOption = 'All'; // Default sorting option
  bool hasNotifications = false;
  DateTime? selectedDate;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    fetchTransactions();
    fetchLowProductsNotification();
  }

  Future<void> fetchTransactions() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .get();

      final List<QueryDocumentSnapshot> documents = snapshot.docs;

      final List<Transaction> fetchedTransactions = documents.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final String date = data['date'];
        final int transactionNumber = data['transactionNumber'];
        final double totalPrice = data['totalPrice'];
        final List<Map<String, dynamic>> products = List<Map<String, dynamic>>.from(data['products']);

        return Transaction(
          date: date,
          transactionNumber: transactionNumber,
          products: products,
          totalPrice: totalPrice,
        );
      }).toList();

      setState(() {
        transactions = fetchedTransactions;
      });
    } catch (error) {
      print('Failed to fetch transactions: $error');
    }
  }

  // Function to open the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
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




   List<Transaction> getFilteredTransactions() {
  // Filter transactions based on the selected sorting option
  switch (sortOption) {
    case 'Day':
      if (selectedDate != null) {
        // Filter transactions for the selected date
        return transactions
            .where((transaction) =>
                isSameDay(transaction.date, selectedDate!))
            .toList();
      } else {
        // Return an empty list if no date is selected
        return [];
      }
    default:
      return transactions; // Return all transactions by default
  }
}


  bool isSameDay(String timestamp, DateTime dateTime) {
  final DateTime transactionDate =
      DateTime.parse(timestamp);
  return transactionDate.year == dateTime.year &&
      transactionDate.month == dateTime.month &&
      transactionDate.day == dateTime.day;
}

 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transactions',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        centerTitle: true, // Center the title
        backgroundColor: Color.fromARGB(255, 65, 84, 146),
        automaticallyImplyLeading:
            false, // Remove the back arrow button// Set the background color
        actions: [
          if (sortOption == 'Day')
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(
                selectedDate != null
                    ? 'Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'
                    : 'Select Date',
                style: TextStyle(color: Colors.white),
              ),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                sortOption = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'All',
                child: Text('All'),
              ),
              PopupMenuItem<String>(
                value: 'Day',
                child: Text('Day'),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: getFilteredTransactions().length,
        itemBuilder: (context, index) {
          final transaction = getFilteredTransactions()[index];
          return ListTile(
            title: Text('T/No: ${transaction.transactionNumber}'),
            onTap: () {
              _showTransactionDetails(transaction);
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

  void _showTransactionDetails(Transaction transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Transaction Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('T/Number: ${transaction.transactionNumber}'),
              SizedBox(height: 10),
              Text('Products:'),
              for (var product in transaction.products)
                ListTile(
                  title: Text(product['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Qty: ${product['quantity']}'),
                      Text('Unit Price: ZMK ${product['unitPrice']}'),
                      Text('Total Amount (incl. VAT): ZMK ${product['totalAmount']}'),
                    ],
                  ),
                ),
                Text('Transaction total amount: ${transaction.totalPrice}'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
