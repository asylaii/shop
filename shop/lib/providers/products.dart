import 'package:flutter/material.dart';
import 'product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Products with ChangeNotifier {
  List<Product> _items = [];

  var _showFavoritesOnly = false;

  final String? authToken;
  Products(this.authToken, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.https(
        'shopflutter2-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/products.json',{
          'auth': authToken
        });
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData['title'] ?? '-',
            description: prodData['description'] ?? '-',
            price: prodData['price'] ?? 0,
            imageUrl: prodData['imageUrl'] ?? '-',
            isFavorite: prodData['isFavorite'] ?? false,
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.https(
        'shopflutter2-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/products.json',{
          'auth': authToken
        });
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'isFavorite': product.isFavorite,
        }),
      );
      final newProduct = Product(
        id: DateTime.now().toString(),
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );

      _items.add(newProduct);

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https(
          'shopflutter2-default-rtdb.asia-southeast1.firebasedatabase.app',
          '/products/$id.json',{
          'auth': authToken
        });
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('');
    }
  }

  void deleteProduct(String id) {
    final url = Uri.https(
        'shopflutter2-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/products/$id.json',{
          'auth': authToken
        });
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeWhere((element) => element.id == existingProduct.id);
    http.delete(url).catchError((_) {
      _items.insert(existingProductIndex, existingProduct);
    });
    notifyListeners();
  }
}
