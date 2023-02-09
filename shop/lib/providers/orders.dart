import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shop/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem with ChangeNotifier {
  final String? id;
  final double? amount;
  final List<CartItem?>? products;
  final DateTime? dateTime;

  OrderItem(this.id, this.amount, this.products, this.dateTime);
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  final String? authToken;
  Orders(this.authToken, this._orders);
  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.https(
        'shopflutter2-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/orders.json',
        {'auth': authToken});
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    print(extractedData);
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          orderId,
          orderData['amount'],
          (orderData['product'] as List<dynamic>?)
              ?.map((e) => CartItem(
                    id: e['id'],
                    title: e['title'],
                    quantity: e['quantity'],
                    price: e['price'],
                  ))
              .toList(),
          DateTime.now(),
        ),
      );
    });
    _orders = loadedOrders;
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.https(
      'shopflutter2-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/orders.json',
      {
        'auth': authToken,
      },
    );
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': DateTime.now().toString(),
          'product': cartProducts
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'quantity': e.quantity,
                    'price': e.price,
                  })
              .toList(),
        }));
    _orders.insert(
      0,
      OrderItem(
        json.decode(response.body)['name'],
        total,
        cartProducts,
        DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
