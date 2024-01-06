import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabpos/screens/More.dart';
import 'package:tabpos/screens/PinEntryPage.dart';
import 'package:tabpos/screens/Transaction.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  List<List<Widget>> rows = [[]];
  List<Widget> selectedProducts = [];
  List<DocumentSnapshot> _categories = [];
  double totalVatAmount = 0.0;
  double sumtotalAmount = 0.0;
  double dis = 0.0;
  double chargedAmount = 0.0;
  bool hasNotifications = false;
  bool showAllProducts = true;
  List<Item> itemList = [];
  ValueNotifier<bool> isFavorite = ValueNotifier<bool>(false);

 List<double> discountOptions = [0.0, 0.05, 0.10, 0.15]; // Represent discounts as decimals (e.g., 5% -> 0.05)
double selectedDiscount = 0.0;
  double discountedTotalAmount = 0.0;
  double finalChargeAmount = 0.0;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    fetchProducts();
    initializeNotifications();
    fetchLowProductsNotification();
    fetchCategories();
  }

  Future<void> fetchProducts() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('products').get();

      final List<QueryDocumentSnapshot> documents = snapshot.docs;

      final List<Product> products = documents.map((doc) {
        return Product.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();

      setState(() {
        rows = [];
        for (int i = 0; i < products.length; i += 6) {
          final List<Product> rowProducts = products.sublist(
              i, i + 6 > products.length ? products.length : i + 6);
          final List<Widget> rowWidgets = rowProducts.map((product) {
            return buildActivityButton(
              product.name,
              product.category,
              product.qty,
              product.price,
              product.favorite,
            );
          }).toList();
          rows.add(rowWidgets);
        }
      });
    } catch (error) {
      print('Failed to fetch products: $error');
    }
  }

  Future<void> fetchFavoriteProducts() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('favorite', isEqualTo: true)
          .get();

      final List<QueryDocumentSnapshot> documents = snapshot.docs;

      final List<Product> products = documents.map((doc) {
        return Product.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();

      setState(() {
        rows = [];
        for (int i = 0; i < products.length; i += 6) {
          final List<Product> rowProducts = products.sublist(
            i,
            i + 6 > products.length ? products.length : i + 6,
          );
          final List<Widget> rowWidgets = rowProducts.map((product) {
            return buildActivityButton(
              product.name,
              product.category,
              product.qty,
              product.price,
              product.favorite,
            );
          }).toList();
          rows.add(rowWidgets);
        }
      });
    } catch (error) {
      print('Failed to fetch favorite products: $error');
    }
  }

  Future<void> fetchCategoriesProducts(String name) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('category', isEqualTo: name)
          .get();

      final List<QueryDocumentSnapshot> documents = snapshot.docs;

      final List<Product> products = documents.map((doc) {
        return Product.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();

      setState(() {
        rows = [];
        for (int i = 0; i < products.length; i += 6) {
          final List<Product> rowProducts = products.sublist(
            i,
            i + 6 > products.length ? products.length : i + 6,
          );
          final List<Widget> rowWidgets = rowProducts.map((product) {
            return buildActivityButton(
              product.name,
              product.category,
              product.qty,
              product.price,
              product.favorite,
            );
          }).toList();
          rows.add(rowWidgets);
        }
      });
    } catch (error) {
      print('Failed to fetch favorite products: $error');
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
      // Get product names from the snapshot
      List productNames =
          snapshot.docs.map((doc) => doc.get('name')).toList();

      // Display notification for all products
      showNotification(productNames);
    }

      // Rest of the code...
    } catch (error) {
      print('Failed to fetch products: $error');
    }
  }

  Future<void> updateFavoriteStatusInFirestore(Product product) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('name', isEqualTo: product.name)
          .get();
      final List<DocumentSnapshot> documents = snapshot.docs;
      for (final doc in documents) {
        await doc.reference.update({
          'favorite': true,
        });
      }
      print('Favorite status updated to true in Firestore');
    } catch (error) {
      print('Failed to update favorite status in Firestore: $error');
    }
  }

  Future<void> updateFavoriteStatusFalseInFirestore(Product product) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('name', isEqualTo: product.name)
          .get();
      final List<DocumentSnapshot> documents = snapshot.docs;
      for (final doc in documents) {
        await doc.reference.update({
          'favorite': false,
        });
      }
      print('Favorite status updated to false in Firestore');
    } catch (error) {
      print('Failed to update favorite status in Firestore: $error');
    }
  }

  Future<DocumentSnapshot?> fetchProductFromFirestore(String productName) async {
  try {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('name', isEqualTo: productName)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first;
    } else {
      print('Product not found');
      return null;
    }
  } catch (error) {
    print('Error fetching product: $error');
    return null;
  }
}


  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Set up the notification tap event handler
    WidgetsFlutterBinding.ensureInitialized().addObserver(
      _NotificationTapObserver(),
    );
  }

  void showNotification(List productNames) async {
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

  for (int i = 0; i < productNames.length; i++) {
    Timer(Duration(seconds: i * 5), () {
      // Delay the notification by i * 5 seconds (change the delay time as needed)
      flutterLocalNotificationsPlugin.show(
        i, // Use a unique id for each notification to prevent overwriting
        'Low Quantity Products',
        '${productNames[i]} has a quantity of 5 or less.',
        platformChannelSpecifics,
      );
    });
  }
}


  void fetchCategories() async {
    // Fetch the categories collection from Firestore
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('categories').get();

    setState(() {
      _categories = snapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(
                'TabPOS',
                style: GoogleFonts.tangerine(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 24.0,
                ),),
        centerTitle: true, // Center the title
        backgroundColor: Color.fromARGB(255, 65, 84, 146),
        automaticallyImplyLeading:
            false, // Remove the back arrow button// Set the background color
      ),
      backgroundColor: Colors.grey.shade100,
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              height: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 10),
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                showAllProducts = true;
                              });
                              // Reload all products
                              fetchProducts();
                            },
                            child: Text(
                              "All Products",
                              style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontSize: 14,
                ),
                              
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                showAllProducts = false;
                              });
                              // Fetch favorite products
                              fetchFavoriteProducts();
                            },
                            child: Text(
                              "Favourites",
                              style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontSize: 14,
                ),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          ..._categories.map((category) {
                            return TextButton(
                              onPressed: () {
                                setState(() {
                                  showAllProducts = false;
                                });
                                String cate = category['name'];
                                fetchCategoriesProducts(cate);
                              },
                              child: Text(
                                capitalizeFirstLetter(category['name']),
                                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontSize: 14,
                ),
                              ),
                            );
                          }).toList(),
                          const SizedBox(
                            width: 35,
                          ),
                        ],
                      ),
                    ),
                    for (var row in rows)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: row,
                      ),
                    const SizedBox(
                      height: 145,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Color.fromARGB(255, 255, 255, 255),
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 10),
                      children: [
                        const Icon(
                          Icons.more_horiz_outlined,
                        ),
                        const SizedBox(
                          width: 35,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'CURRENT SALE (${selectedProducts.length})',
                    style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(
                          255, 65, 84, 146),
                  fontSize: 18,
                ),
                  ),
                  Expanded(
  child: ListView.builder(
    scrollDirection: Axis.vertical,
    itemCount: selectedProducts.length,
    itemBuilder: (context, index) {
      var selectedProduct = selectedProducts[index];
      var itemselect = itemList[index];
      double totalAmount = itemList[index].totalA;
      double vat = itemList[index].vat;
      int quant = itemList[index].quantity;
      return Dismissible(
        key:
            UniqueKey(), // Use a unique key for each Dismissible
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          color: Colors.red,
          child: Icon(Icons.delete, color: Colors.white),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          color: Colors.red,
          child: Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (direction) {
          // Remove the item from the list when dismissed
          setState(() {
            sumtotalAmount -= totalAmount;
            totalVatAmount -= vat;
            selectedProducts.removeAt(index);
            itemList.removeAt(index);
          });
          // Show a snackbar to undo the dismissal (optional)
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Item removed."),
            action: SnackBarAction(
              label: "Undo",
              onPressed: () {
                setState(() {
                  // Re-insert the item back to the list
                  sumtotalAmount += totalAmount;
                  totalVatAmount += vat;
                  selectedProducts.insert(index, selectedProduct);
                  itemList.insert(index, itemselect);
                });
              },
            ),
          ));
        },
        child: selectedProduct,
      );
    },
  ),
),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          '    Discount  : ',
                          style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontSize: 14,
                ),
                        ),
                        DropdownButton<String>(
  value: (selectedDiscount * 100).toStringAsFixed(0) + '%', // Convert back to percentage string
  items: discountOptions.map((discount) {
    return DropdownMenuItem<String>(
      value: (discount * 100).toStringAsFixed(0) + '%', // Convert to percentage string
      child: Text((discount * 100).toStringAsFixed(0) + '%'), // Convert to percentage string
    );
  }).toList(),
  onChanged: (String? value) {
    setState(() {
      // Convert the selected value back to decimal before setting
      selectedDiscount = double.parse(value!.replaceFirst('%', '')) / 100;
      dis = selectedDiscount * sumtotalAmount;
      
      chargedAmount = sumtotalAmount - dis;
      print(chargedAmount);
    });
  },
),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 35,
                  ),

                  
                  Align(
                    
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '    Total VAT  : ${totalVatAmount.toStringAsFixed(1)}',
                      style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontSize: 14,
                ),
                    ),
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showChargeDialog(sumtotalAmount);
                    },
                    child: Text(
                      'CHARGE ( \ZMK ${sumtotalAmount.toStringAsFixed(1)} )',
                      style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 18,
                ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(
                          255, 65, 84, 146), // Set the background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            20), // Set the border radius here
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          ),
        ],
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
    MaterialPageRoute(builder: (context) => PinEntryPage()),
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
      floatingActionButton: Container(
        width: 300, // Makes the button as wide as its parent widget
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AddProductDialog(
                  onProductAdded: (product) {
                    setState(() {
                      if (rows.last.length < 6) {
                        rows.last.add(buildActivityButton(
                          product.name,
                          product.category,
                          product.qty,
                          product.price,
                          product.favorite,
                        ));
                      } else {
                        rows.add([
                          buildActivityButton(
                            product.name,
                            product.category,
                            product.qty,
                            product.price,
                            product.favorite,
                          )
                        ]);
                      }
                    });
                    addProductToFirestore(
                        product); // Add the product to Firestore
                  },
                );
              },
            );
          },
          child:  Text(
            'ADD PRODUCTS',
            style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 18,
                ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Color.fromARGB(255, 65, 84, 146), // Set the background color
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(20), // Set the border radius here
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  String capitalizeFirstLetter(String text) {
    if (text == null || text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  

  void addTransactionToFirestore( 
      List<Widget> selectedProducts, double totalPrice) { 
    final DateTime currentDate = DateTime.now(); 
    FirebaseFirestore.instance.collection('transactions').add({ 
      'totalPrice': totalPrice, 
      'transactionNumber': DateTime.now().millisecondsSinceEpoch, 
      'date': currentDate.toString(), 
      'products': selectedProducts.map((widget) { 
        final ListTile tileWidget = widget as ListTile; 
        final Text titleWidget = tileWidget.title as Text; 
        final Column subtitleWidget = tileWidget.subtitle as Column; 
        final List<Widget> subtitleChildren = subtitleWidget.children; 
 
        final String name = titleWidget.data ?? ''; 
        final int quantity = int.tryParse( 
                (subtitleChildren[0] as Text).data!.replaceAll('Qty: ', '')) ?? 
            0; 
        final double unitPrice = double.tryParse((subtitleChildren[1] as Text) 
                .data! 
                .replaceAll('Unit Price: \ZMK', '')) ?? 
            0.0; 
        final double totalAmount = double.tryParse((subtitleChildren[2] as Text) 
                .data! 
                .replaceAll('Total Amount (incl. VAT): \ZMK', '')) ?? 
            0.0; 
             
        FirebaseFirestore.instance
    .collection('products')
    .where('name', isEqualTo: name)
    .get()
    .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
            FirebaseFirestore.instance
                .collection('products')
                .doc(doc.id)
                .update({'qty': FieldValue.increment(-quantity)});
        });
    });
        return { 
          'name': name, 
          'quantity': quantity, 
          'unitPrice': unitPrice, 
          'totalAmount': totalAmount, 
        }; 
      }).toList(), 
    }).then((value) { 
      setState(() { 
        selectedProducts.clear(); 
        totalVatAmount = 0.0; 
        sumtotalAmount = 0.0; 
      }); 
      print('Transaction added to Firestore'); 
    }).catchError((error) => print('Failed to add transaction: $error')); 
  }

  GestureDetector buildActivityButton(
    String title,
    String categories,
    int qty,
    double price,
    bool isFavorite,
  ) {
    Product selectedProduct = Product();
    selectedProduct.name = title;
    selectedProduct.qty = qty;
    selectedProduct.price = price;
    double pro = selectedProduct.price;
    selectedProduct.favorite = isFavorite;
    //bool isFavorite = selectedProduct.favorite;
    String pp = pro.toString();
    return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              int quantity = 0;
              double screenWidth = MediaQuery.of(context).size.width;
    double dialogWidth = screenWidth / 3;
              return Dialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10.0),
  ),
  child: Container(
    width: dialogWidth,
    padding: EdgeInsets.all(16.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'How Many ${selectedProduct.name}',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 65, 84, 146), // Set title color
          ),
        ),
        SizedBox(height: 16.0),
        TextFormField(
  decoration: InputDecoration(
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 2, color: Color.fromARGB(255, 65, 84, 146)),
      borderRadius: BorderRadius.circular(50.0),
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0), // Adjust the inner padding
    isDense: true, // Make the field more compact
  ),
  keyboardType: TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) {
            setState(() {
              quantity = int.tryParse(value) ?? 0;
            });
          },
        ),
        SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Color.fromARGB(255, 65, 84, 146), // Set button text color
            ),
          ),
        ),
                  ElevatedButton(
  onPressed: () async {
    double totalPrice = pro * quantity;
    double vatAmount = totalPrice * 0.1; // Assuming VAT rate is 10% (0.1)
    double totalAmount = totalPrice + vatAmount;
    Item item1 = Item(
      name: selectedProduct.name,
      quantity: quantity,
      unitPrice: pro,
      vat: vatAmount,
      totalA: totalAmount,
    );
     // Fetch product from Firestore
    var firestoreProduct = await fetchProductFromFirestore(selectedProduct.name);
if (firestoreProduct != null) {
  int? qty = (firestoreProduct.data() as Map<String, dynamic>)['qty'];
  if (qty != null && qty < quantity) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Not enough stock'),
            content: Text('The quantity you have requested is more than the quantity in stock.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );}else {
    // Check if item is already in the list
    bool isItemAlreadyAdded = itemList.any((item) => item.name == item1.name);
    if (isItemAlreadyAdded) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Item Already Added',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 65, 84, 146), // Set title color
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'The item "${item1.name}" is already in the list.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromARGB(255, 65, 84, 146), // Set text color
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Color.fromARGB(255, 65, 84, 146), // Set button text color
                      ),

                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      itemList.add(item1);
      setState(() {
        selectedProducts.add(
          ListTile(
            title: Text('${selectedProduct.name}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Qty: $quantity'),
                Text('Unit Price: \ZMK$pro'),
                //Text('VAT (10%): \$$vatAmount'),
                Text('Total Amount (incl. VAT): \ZMK$totalAmount'),
              ],
            ),
          ),
        );
        totalVatAmount += vatAmount;
        sumtotalAmount += totalAmount;
      });
      //updateProductQuantityInDatabase(selectedProduct, selectedProduct.qty - quantity);
      Navigator.of(context).pop();
    }
    } 
    }
  },
  child: Text(
            'Add',
            style: TextStyle(
              color: Colors.white, // Set button text color
            ),
          ),
          style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(
                          255, 65, 84, 146), // Set the background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            20), // Set the border radius here
                      ),
                    ),
        ),])
      ],
    ),
  ),
);
            },
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Color.fromARGB(
                  255, 65, 84, 146), // Set the border color to black
              width: 3.0, // Set the border width
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Stack(
            alignment: Alignment.topLeft,
            children: [
              Container(
                // margin: EdgeInsets.all(10),
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      MdiIcons.bottleSodaClassic,
                      size: 40,
                      color: Color.fromARGB(255, 65, 84, 146),
                    ),
                    SizedBox(height: 5),
                    Text(
                      capitalizeFirstLetter(title),
                      style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(255, 65, 84, 146),
                  
                )
                    ),
                    SizedBox(height: 2),
                    Text(
                      'ZMK $pp',
                      style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(255, 65, 84, 146),
                      ),
                    ),
                  ],
                ),
              ),
              
 AnimatedContainer(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  margin: EdgeInsets.all(1),
  height: 10,
  width: 10,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: selectedProduct.favorite
        ? Colors.transparent
        : Colors.transparent,
  ),
  child: IconButton(
    icon: Icon(
      selectedProduct.favorite ? Icons.favorite : Icons.favorite_border,
      size: 20,
      color: selectedProduct.favorite ? Colors.red : Colors.white,
    ),
    onPressed: () async {
      setState(() {
        selectedProduct.favorite = !selectedProduct.favorite;
        // Change the icon color immediately
        selectedProduct.favorite
            ? Colors.red
            : Colors.white;
      });
      // Update the favorite status in Firestore
      try {
        if (selectedProduct.favorite) {
          await updateFavoriteStatusInFirestore(selectedProduct);
        } else {
          await updateFavoriteStatusFalseInFirestore(selectedProduct);
        }
        // Display toast message
        Fluttertoast.showToast(
          msg: selectedProduct.favorite
              ? 'Added to favorites'
              : 'Removed from favorites',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
        );
      } catch (e) {
        // Handle error if updating Firestore fails
        print('Error updating favorite status: $e');
      }
    },
  ),
)
            ],
          ),
        ));
  }

  Future<void> updateProductQuantityInDatabase(Product product,int newQuantity) async {
  try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('name', isEqualTo: product.name)
          .get();
      final List<DocumentSnapshot> documents = snapshot.docs;
      for (final doc in documents) {
        await doc.reference.update({
          'qty': newQuantity,
        });
      }
      print('product quantity updated in Firestore');
    } catch (error) {
      print('Failed to update product quantity in Firestore: $error');
    }
}

  void showChargeDialog(double totalAmount) {
    double amountPaid = 0.0;
    double screenWidth = MediaQuery.of(context).size.width;
    double dialogWidth = screenWidth / 3;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10.0),
  ),
  child: Container(
    width: dialogWidth,
    padding: EdgeInsets.all(16.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Enter Amount Paid',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 65, 84, 146), // Set title color
          ),
        ),
        SizedBox(height: 16.0),
        TextFormField(
  decoration: InputDecoration(
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 2, color: Color.fromARGB(255, 65, 84, 146)),
      borderRadius: BorderRadius.circular(50.0),
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0), // Adjust the inner padding
    isDense: true, // Make the field more compact
  ),
  keyboardType: TextInputType.numberWithOptions(decimal: true),
  onChanged: (value) {
    amountPaid = double.tryParse(value) ?? 0.0;
  },
  
),
        SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ChargeDialog(
                  amountPaid: amountPaid,
                  totalAmount: totalAmount,
                );
              },
            ).then((_) {
              addTransactionToFirestore(selectedProducts,
                  totalAmount); // Add the transaction to Firestore
              setState(() {
                selectedProducts.clear();
                itemList.clear();
                totalVatAmount = 0.0;
                sumtotalAmount = 0.0;
              });
            });
          },
          child: Text(
            'Enter',
            style: TextStyle(
              color: Colors.white, // Set button text color
            ),
          ),
          style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(
                          255, 65, 84, 146), // Set the background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            20), // Set the border radius here
                      ),
                    ),
        ),
      ],
    ),
  ),
);
      },
    );
  }


  void addProductToFirestore(Product product) {
    FirebaseFirestore.instance
        .collection('products')
        .add({
          'name': product.name,
          'category': product.category,
          'qty': product.qty,
          'favorite': product.favorite,
          'price': product.price,
        })
        .then((value) => print('Product added to Firestore'))
        .catchError((error) => print('Failed to add product: $error'));
  }
}

class Item {
  String name;
  int quantity;
  double unitPrice;
  double vat;
  double totalA;

  Item(
      {required this.name,
      required this.quantity,
      required this.unitPrice,
      required this.vat,
      required this.totalA});

  //double get totalAmount => quantity * unitPrice;
}

class AddProductDialog extends StatefulWidget {
  final Function(Product) onProductAdded;

  const AddProductDialog({required this.onProductAdded});

  @override
  _AddProductDialogState createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _product = Product();
  String? _selectedCategory;
  List<String> _categoryOptions =
      []; // Holds the category options fetched from Firestore

  @override
  void initState() {
    super.initState();
    fetchCategories(); // Fetch categories from Firestore when the dialog is initialized
  }

  void fetchCategories() async {
    // Fetch the categories collection from Firestore
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('categories').get();

    // Extract the category names from the snapshot and update the category options list
    List<String> categories =
        snapshot.docs.map((doc) => doc['name'] as String).toList();
    setState(() {
      _categoryOptions = categories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: AlertDialog(
      title: Text('Add Product'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              onSaved: (value) => _product.name = value!,
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Category'),
              value: _selectedCategory,
              items: _categoryOptions.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a category';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              onSaved: (value) => _product.category = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Qty'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an qty';
                }
                return null;
              },
              onSaved: (value) => _product.qty = int.parse(value!),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Price'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid price';
                }
                return null;
              },
              onSaved: (value) => _product.price = double.parse(value!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              widget.onProductAdded(_product);
              Navigator.of(context).pop();
            }
          },
          child: Text('Add Product'),
        ),
      ],
    ));
  }
}

class Product {
  String name = '';
  String category = '';
  int qty = 0;
  bool favorite = false;
  double price = 0.0;

  Product(); // Unnamed constructor

  Product.fromFirestore(Map<String, dynamic> firestoreData) {
    name = firestoreData['name'];
    category = firestoreData['category'];
    qty = firestoreData['qty'];
    favorite = firestoreData['favorite'];
    price = firestoreData['price'];
  }
}

class ChargeDialog extends StatelessWidget {
  final double amountPaid;
  final double totalAmount;

  ChargeDialog({required this.amountPaid, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    double change = amountPaid - totalAmount;

    return AlertDialog(
      title: Text('Payment Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Amount Paid: \ZMK ${amountPaid.toStringAsFixed(2)}'),
          SizedBox(height: 10),
          Text('Change: \ZMK ${change.toStringAsFixed(2)}'),
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
  }
}

class ProductInfo {
  final String name;
  final Widget widget;

  ProductInfo(this.name, this.widget);
}

class _NotificationTapObserver extends WidgetsBindingObserver {
  @override
  Future<bool?> didReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // Handle notification tap event here
    if (payload != null) {
      // Parse the payload data if needed
      // Perform actions based on the payload
      // Example: navigate to a specific screen
      if (payload == 'screenA') {
        //Navigator.push(
        //  context,
        // MaterialPageRoute(builder: (context) => ScreenA()),
        //);
      } else if (payload == 'screenB') {
        //Navigator.push(
        //context,
        //  MaterialPageRoute(builder: (context) => ScreenB()),
        //  );
      }
    }

    return null;
  }
}
