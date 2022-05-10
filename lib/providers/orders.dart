import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String? id;
  final double? amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  String? _token;
  String? _userId;

  void update(String? token, String? userId, List<OrderItem> prevItems) {
    _orders = prevItems;
    _token = token;
    _userId = userId;
  }

  Future<void> getOrders() async {
    // print(_token);
    // print(_userId);
    final url = Uri.https('shop-20767-default-rtdb.firebaseio.com',
        '/orders/$_userId.json', {'auth': _token});
    try {
      final response = await http.get(url);
      final data = json.decode(response.body) as Map<String, dynamic>?;
      // print(data);
      final List<OrderItem> loadedOrders = [];
      data?.forEach((id, orderData) {
        loadedOrders.add(OrderItem(
          id: id,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map(
                (e) => CartItem(
                  id: e['id'],
                  title: e['title'],
                  quantity: e['quantity'],
                  price: e['price'],
                ),
              )
              .toList(),
        ));
      });
      // print('done?!'); // it's ok
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      print('getOrder $error');
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    // print(_token);
    if (total != 0) {
      final url = Uri.https('shop-20767-default-rtdb.firebaseio.com',
          '/orders/$_userId.json', {'auth': _token});
      try {
        final timeStamp = DateTime.now();
        final response = await http.post(url,
            body: json.encode({
              'amount': total,
              'dateTime': timeStamp.toIso8601String(),
              'products': cartProducts
                  .map((e) => {
                        'id': e.id,
                        'title': e.title,
                        'price': e.price,
                        'quantity': e.quantity,
                      })
                  .toList(),
            }));
        _orders.insert(
          0,
          OrderItem(
            id: json.decode(response.body)['name'],
            dateTime: timeStamp,
            amount: total,
            products: cartProducts,
          ),
        );
      } catch (error) {
        print('addOrder $error');
      }
    }
    notifyListeners();
  }
}
