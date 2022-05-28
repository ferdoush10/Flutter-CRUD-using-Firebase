import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference _products =
      FirebaseFirestore.instance.collection('products');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Data Update function
  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _nameController.text = documentSnapshot['name'];
      _priceController.text = documentSnapshot['price'].toString();
    }
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "name"),
                ),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: "price"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const Text('Update'),
                  onPressed: () async {
                    final String name = _nameController.text;
                    final String price = _priceController.text.toString();
                    // ignore: unnecessary_null_comparison
                    if (name != null) {
                      await _products
                          .doc(documentSnapshot!.id)
                          .update({"name": name, "price": price});
                      _nameController.text = "";
                      _priceController.text = "";
                    }
                  },
                ),
              ],
            ),
          );
        });
  }

  //Data Create function
  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _nameController.text = documentSnapshot['name'];
      _priceController.text = documentSnapshot['price'].toString();
    }
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "name"),
                ),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: "price"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const Text('Create'),
                  onPressed: () async {
                    final String name = _nameController.text;
                    final String price = _priceController.text.toString();
                    // ignore: unnecessary_null_comparison
                    if (name != null) {
                      await _products.add({"name": name, "price": price});
                      _nameController.text = "";
                      _priceController.text = "";
                    }
                  },
                ),
              ],
            ),
          );
        });
  }

  // Data Delete function
  Future<void> _delete(String productId) async {
    await _products.doc(productId).delete();
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("You have Successfully deleted a product"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flutter CRUD',
          style: TextStyle(color: Colors.green),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightGreen.withOpacity(.2),
        elevation: 0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _create();
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: _products.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> ss) {
          if (ss.hasData) {
            // print(ss.data!.docs.first.toString());
            return ListView.builder(
                itemCount: ss.data!.docs.length, //number of rows
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                      ss.data!.docs[index];
                  return Card(
                    margin: const EdgeInsets.only(left: 20, top: 10, right: 20),
                    child: ListTile(
                      tileColor: Colors.lightGreen.withOpacity(.2),
                      leading: const Icon(Icons.boy_outlined,
                          color: Colors.green, size: 40),
                      textColor: Colors.green,
                      title: Text(
                        documentSnapshot['name'],
                        style: const TextStyle(fontSize: 20),
                      ),
                      subtitle: Text(
                        documentSnapshot['price'].toString(),
                        style: const TextStyle(fontSize: 20),
                      ),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  _update(documentSnapshot);
                                },
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.lightGreen.withOpacity(.8),
                                )),
                            IconButton(
                                onPressed: () {
                                  _delete(documentSnapshot.id);
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.lightGreen.withOpacity(.8),
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                });
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
