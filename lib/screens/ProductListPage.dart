import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {

   Future<void> _showEditProductDialogue(DocumentSnapshot productSnapshot) async {
    final productData = productSnapshot.data() as Map<String, dynamic>;

    TextEditingController nameController = TextEditingController();
    //TextEditingController qtyController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController categoryController = TextEditingController();

    nameController.text = productData['name'];
    //qtyController.text = productData['qty'].toString();
    priceController.text = productData['price'].toString();
    categoryController.text = productData['category'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                //TextField(
                  //controller: qtyController,
                  //keyboardType: TextInputType.number,
                  //decoration: InputDecoration(labelText: 'Quantity'),
               // ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Price'),
                ),
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Update the product in the Firestore database
                productSnapshot.reference.update({
                  'name': nameController.text,
                  //'qty': int.parse(qtyController.text),
                  'price': double.parse(priceController.text),
                  'category': categoryController.text,
                });

                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () {
                // Delete the product from the Firestore database
                productSnapshot.reference.delete();

                Navigator.of(context).pop();
              },
              child: Text('Delete'),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
        centerTitle: true, // Center the title
        backgroundColor: Color.fromARGB(255, 65, 84, 146),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final products = snapshot.data!.docs;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final productSnapshot = products[index];
             final product = productSnapshot.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(product['name']),
                subtitle: Text('Price: \ZMK${product['price']}'),
                onTap: () {
                  _showEditProductDialogue(productSnapshot);
                },
              );
            },
          );
        },
      ),
    );
  }
}
