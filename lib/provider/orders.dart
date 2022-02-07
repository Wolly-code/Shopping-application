import 'package:flutter/foundation.dart';
import './cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this._orders, this.userId);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    Uri url = Uri.parse(
        'https://shop-96efc-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$userId.json?auth=$authToken');
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    try {
      final Map? extractedData =
          jsonDecode(response.body) as Map<String, dynamic>;
      extractedData!.forEach((orderID, ordData) {
        loadedOrders.add(
          OrderItem(
            id: orderID,
            amount: ordData['amount'],
            dateTime: DateTime.parse(ordData['dateTime']),
            products: (ordData['products'] as List<dynamic>)
                .map((item) => CartItem(
                      item['id'],
                      item['title'].toString(),
                      item['quantity'],
                      item['price'],
                    ))
                .toList(),
          ),
        );
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      print (error);
      print('Please add some new order to the database');
    }
  }

  Future<void> addOrder(List<CartItem> products, double total) async {
    Uri url = Uri.parse(
        'https://shop-96efc-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$userId.json?auth=$authToken');
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': DateTime.now().toIso8601String(),
          'products': products
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price
                  })
              .toList()
        }));
    _orders.insert(
        0,
        OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            products: products,
            dateTime: DateTime.now()));
    notifyListeners();
  }
}
