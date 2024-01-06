import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  TextEditingController _categoryController = TextEditingController();
  List<String> categories = []; // List to hold the category names

  @override
  void initState() {
    super.initState();
    // Fetch the categories from Firestore on page load
    _fetchCategories();
  }

  // Function to fetch the categories from Firestore
  // Function to fetch the categories from Firestore
  Future<void> _fetchCategories() async {
    try {
      // Get a reference to the Firestore collection "categories"
      CollectionReference categoryCollection =
          FirebaseFirestore.instance.collection('categories');

      // Get all the documents in the collection
      QuerySnapshot querySnapshot = await categoryCollection.get();

      // Extract the category names from the documents and update the state
      setState(() {
        categories = querySnapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      // Handle any errors that might occur during the fetch.
      print('Error fetching categories: $e');
    }
  }


  // Function to add a new category to Firestore
  Future<void> _addCategory(String categoryName) async {
    try {
      // Get a reference to the Firestore collection "categories"
      CollectionReference categoryCollection =
          FirebaseFirestore.instance.collection('categories');

      // Add the new category with only the "name" field to the collection
      await categoryCollection.add({
        'name': categoryName,
      });

      // Show a success message or perform any other actions upon successful addition.
      // For example, you can display a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category added successfully')),
      );

      // Fetch the updated categories after adding a new one
      _fetchCategories();
    } catch (e) {
      // Handle any errors that might occur during the addition.
      print('Error adding category: $e');
    }
  }

  // Function to display the dialog for adding a new category
  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Category'),
          content: TextFormField(
            controller: _categoryController,
            decoration: InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog without adding a category
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add the category to Firestore and close the dialog
                String categoryName = _categoryController.text.trim();
                if (categoryName.isNotEmpty) {
                  _addCategory(categoryName);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<List<String>> _fetchProductsForCategory(String category) async {
    try {
      // Get a reference to the Firestore collection "products"
      CollectionReference productCollection =
          FirebaseFirestore.instance.collection('products');

      // Query the products with the selected category
      QuerySnapshot querySnapshot = await productCollection
          .where('category', isEqualTo: category)
          .get();

      // Extract the product names from the documents and return as a list
      return querySnapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      // Handle any errors that might occur during the fetch.
      print('Error fetching products for category: $e');
      return [];
    }
  }

  // Function to display the dialog with products for the selected category
  void _showProductsForCategoryDialog(String category) async {
  List<String> products = await _fetchProductsForCategory(category);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Products for $category'),
        content: Container(
          width: double.maxFinite,
          child: products.isNotEmpty
              ? ListView(
                  shrinkWrap: true,
                  children: products
                      .map((productName) => ListTile(
                            title: Text(productName),
                          ))
                      .toList(),
                )
              : Center(
                  child: Text('No products found for this category'),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
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
        title: Text('Product Categories'),
        centerTitle: true, // Center the title
        backgroundColor: Color.fromARGB(255, 65, 84, 146),
      ),
      body: categories.isNotEmpty
          ? ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(categories[index]),
                  onTap: () {
                    // Show the dialog with products for the selected category
                    String category = categories[index].toString();
                    _showProductsForCategoryDialog(category);
                  },
                );
              },
            )
          : Center(
              child: Text('No categories found'),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        tooltip: 'Add Category',
        child: Icon(Icons.add),
      ),
    );
  }

}
