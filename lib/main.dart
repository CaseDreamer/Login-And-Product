import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sorted_list/sorted_list.dart';
import 'dart:async';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';

class Product {
  final String name;
  final double price;

  Product({required this.name, required this.price});
}

class ProductManager extends ChangeNotifier {
  bool _sortByAlphabet = true; // Default sorting by alphabet

  List<Product> _products = [];

  List<Product> get products => _products;

  bool get isSortedByName => _sortByAlphabet;

  void addProduct(Product product) {
    _products.add(product);
    _sortBy();
    notifyListeners();
  }

  void removeProduct(Product product) {
    _products.remove(product);
    notifyListeners();
  }

  void sortProductsByName() {
    _sortByAlphabet = true;
    _sortBy();
    notifyListeners();
  }

  void sortProductsByPrice() {
    _sortByAlphabet = false;
    _sortBy();
    notifyListeners();
  }

  void _sortBy() {
    if (_sortByAlphabet) {
      _products.sort((a, b) => a.name.compareTo(b.name));
    } else {
      _products.sort((a, b) => a.price.compareTo(b.price));
    }
  }
}


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProductManager()),
        // Add other providers if needed
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Login(title: 'Form Login'),
    );
  }
}

class Login extends StatefulWidget {
  const Login({Key? key, required this.title});

  final String title;

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  double loginProgress = 0.0;
  final int loginTime = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: userController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Username"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Username';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Password"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true;
                          loginProgress = 0.0;
                        });

                        final timer = Timer.periodic(Duration(seconds: 1),
                            (timer) {
                          if (loginProgress < 1.0) {
                            setState(() {
                              loginProgress += 1 / loginTime;
                            });
                          } else {
                            timer.cancel();
                            isLoading = false;

                            if (userController.text == "user" &&
                                passwordController.text == "user") {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductListScreen(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Invalid Credentials'),
                                ),
                              );
                            }
                          }
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill input')),
                        );
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (isLoading)
                Column(
                  children: [
                    Text(
                        'Logging into your account. Please wait...'),
                    SizedBox(height: 10),
                    FAProgressBar(
                      currentValue: loginProgress * 100,
                      displayText: '%',
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
      ),
      body: Column(
        children: [
          _buildProductListTitle(context),
          Expanded(
            child: ProductList(),
          ),
          _buildSortDropdown(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductListTitle(BuildContext context) {
    var productManager = Provider.of<ProductManager>(context);
    String filterText = productManager.isSortedByName
        ? 'Filter: Sort by Alphabets'
        : 'Filter: Sort by Price';

    return Container(
      padding: EdgeInsets.all(8),
      child: Text(
        filterText,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSortDropdown(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      padding: EdgeInsets.all(8),
      child: _buildSortDropdownButton(context),
    );
  }

  Widget _buildSortDropdownButton(BuildContext context) {
    var productManager = Provider.of<ProductManager>(context);

    return DropdownButton<String>(
      value: productManager.isSortedByName ? 'alphabet' : 'price',
      items: [
        DropdownMenuItem(
          value: 'alphabet',
          child: Text('Sort by Alphabets'),
        ),
        DropdownMenuItem(
          value: 'price',
          child: Text('Sort by Price'),
        ),
      ],
      onChanged: (value) {
        if (value == 'alphabet') {
          productManager.sortProductsByName();
        } else if (value == 'price') {
          productManager.sortProductsByPrice();
        }
      },
    );
  }
}




class ProductList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var productManager = Provider.of<ProductManager>(context);
    var products = productManager.products;

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        var product = products[index];
        // Adding 1 to the index to display the number starting from 1
        int productNumber = index + 1;

        return Card(
          elevation: 3,
          margin: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text('$productNumber'),
            ),
            title: Text(product.name),
            subtitle: Text('Rp${product.price.toStringAsFixed(2)}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                productManager.removeProduct(product);
              },
            ),
          ),
        );
      },
    );
  }
}



class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Product Price'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                var name = _nameController.text;
                var price = double.tryParse(_priceController.text) ?? 0.0;

                if (name.isNotEmpty && price > 0) {
                  var product = Product(name: name, price: price);
                  Provider.of<ProductManager>(context, listen: false)
                      .addProduct(product);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter valid data'),
                    ),
                  );
                }
              },
              child: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
