import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StockCheckPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Stock Check'),
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
              final productName = product['name'];
              final productQty = product['qty'];

              return ListTile(
                title: Text(productName),
                subtitle: Text('Qty: $productQty'),
                onTap: () {
                  _showEditQuantityDialogue(context, productSnapshot);
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showEditQuantityDialogue(BuildContext context, DocumentSnapshot productSnapshot) async {
    final productData = productSnapshot.data() as Map<String, dynamic>;

    TextEditingController quantityController = TextEditingController();
    quantityController.text = productData['qty'].toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Quantity'),
          content: SingleChildScrollView(
            child: TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Quantity'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Update the quantity in the Firestore database
                productSnapshot.reference.update({
                  'qty': int.parse(quantityController.text),
                });

                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}

