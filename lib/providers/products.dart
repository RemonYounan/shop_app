// ignore_for_file: sdk_version_ui_as_code
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  String? _token;
  String? _userId;

  void update(String? token, String? userId, List<Product> prevItems) {
    _items = prevItems;
    _token = token;
    _userId = userId;
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favItems {
    return _items.where((product) => product.isFavourite).toList();
  }

  Product findById(String? id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> getProducts([bool filter = false]) async {
    var url;
    if (filter) {
      url = Uri.https(
          'shop-20767-default-rtdb.firebaseio.com', '/products.json', {
        'auth': _token,
        'orderBy': '"creatorId"',
        'equalTo': '"$_userId"',
      });
    } else if (!filter) {
      url = Uri.https(
          'shop-20767-default-rtdb.firebaseio.com', '/products.json', {
        'auth': _token,
      });
    }
    try {
      final response = await http.get(url);
      final productsData = jsonDecode(response.body) as Map<String, dynamic>;
      url = Uri.https('shop-20767-default-rtdb.firebaseio.com',
          '/userFavourites/$_userId.json', {'auth': _token});
      final favouritesResponse = await http.get(url);
      final favs = json.decode(favouritesResponse.body);
      final List<Product> loadedProds = [];
      productsData.forEach((id, data) {
        loadedProds.add(
          Product(
            id: id,
            title: data['title'] as String,
            description: data['description'] as String,
            imageUrl: data['imageUrl'] as String,
            price: data['price'] as double,
            // ignore: unnecessary_null_comparison
            isFavourite: favs == null ? false : favs['$id'] ?? false,
          ),
        );
      });
      _items = loadedProds;
      notifyListeners();
    } catch (error) {
      // throw error;
      print('getproduct $error');
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.https('shop-20767-default-rtdb.firebaseio.com',
        '/products.json', {'auth': _token});
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'price': product.price,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'creatorId': _userId
          }));
      _items.add(
        Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
        ),
      );
      notifyListeners();
    } catch (error) {
      print('addProduct $error');
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https('shop-20767-default-rtdb.firebaseio.com',
          '/products/$id.json', {'auth': _token});
      http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'price': newProduct.price,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
          }));
      // print(id);
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.https('shop-20767-default-rtdb.firebaseio.com',
        '/products/$id.json', {'auth': _token});
    final index = _items.indexWhere((element) => element.id == id);
    var existingProd = _items[index];
    _items.removeAt(index);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(index, existingProd);
      notifyListeners();
      throw HttpException('Couldn\'t delete Product.');
    }
    existingProd.dispose();
  }
}
