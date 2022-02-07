import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem(this.id, this.title, this.quantity, this.price);
}

class Cart with ChangeNotifier {
  Map<String, CartItem>? _items = {};

  Map<String, CartItem> get items {
    return {..._items!};
  }

  int get itemCount {
    return _items == null ? 0 : _items!.length;
  }

  void removeSingleItem(String productId) {
    if (!_items!.containsKey(productId)) {
      return;
    }
    if (_items![productId]!.quantity > 1) {
      _items!.update(
          productId,
          (existingCartItem) => CartItem(
              existingCartItem.id,
              existingCartItem.title,
              existingCartItem.quantity - 1,
              existingCartItem.price));
    } else {
      _items!.remove(productId);
    }
    notifyListeners();
  }

  double get totalAmount {
    var total = 0.0;
    _items!.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void removeItem(String productId) {
    _items!.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  void addItem(String productId, String title, double price) {
    if (_items!.containsKey(productId)) {
      _items!.update(
          productId,
          (existing) => CartItem(existing.id, existing.title,
              existing.quantity + 1, existing.price));
    } else {
      _items!.putIfAbsent(productId,
          () => CartItem(DateTime.now().toString(), title, 1, price));
    }
    notifyListeners();
  }
}
