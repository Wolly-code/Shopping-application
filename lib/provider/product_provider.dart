import '../provider/product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  //var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }
  //
  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }
  final String authToken;
  final String userId;

  Products(this.authToken, this._items, this.userId);

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy=\"creatorId\"&equalTo=\"$userId\"' : '';
    Uri url = Uri.parse(
        'https://shop-96efc-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      final List<Product> loadedProducts = [];
      try {
        print(json.decode(response.body));
        final Map? extractedData =
            json.decode(response.body) as Map<String, dynamic>;
        //print(extractedData);
        Uri url = Uri.parse(
            'https://shop-96efc-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorites/$userId.json?auth=$authToken');

        final favoriteResponse = await http.get(url);
        final favoriteData = json.decode(favoriteResponse.body);
        extractedData!.forEach((prodID, prodData) {
          loadedProducts.insert(
              0,
              Product(
                  title: prodData['title'],
                  description: prodData['description'],
                  imageUrl: prodData['imageUrl'],
                  id: prodID,
                  price: prodData['price'],
                  isFavorite: favoriteData == null
                      ? false
                      : favoriteData[prodID] ?? false));
        });
        _items = loadedProducts;
        notifyListeners();
      } catch (error) {
        print('Please add some new products to the database');
      }
    } catch (error) {
      rethrow;
    }
  }

  Product findByID(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> addProduct(Product product) async {
    String prodTitle = DateTime.now().toString();
    Uri url = Uri.parse(
        'https://shop-96efc-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken');
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          })); //Header for sending API Tokens and stuff
      //Response will  help to execute the function after the response has been made.
      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
    } catch (error) {
      rethrow;
    }

    //_items.insert(0, newProduct); TO ADD TO THE START OF THE LIST
    notifyListeners();
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      Uri url = Uri.parse(
          'https://shop-96efc-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken');
      http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('The index is not available');
    }
  }

  Future<void> deleteProduct(String id) async {
    Uri url = Uri.parse(
        'https://shop-96efc-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.insert(existingProductIndex, existingProduct);
    notifyListeners();
    _items.removeAt(existingProductIndex);
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
