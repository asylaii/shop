import 'package:flutter/material.dart';
import 'package:shop/providers/auth.dart';
import 'package:shop/providers/orders.dart';
import 'package:shop/screens/auth_screen.dart';
import 'package:shop/screens/cart_screen.dart';
import 'package:shop/screens/edit_product_screen.dart';
import 'package:shop/screens/orders_screen.dart';
import 'package:shop/screens/product_details_screen.dart';
import 'package:shop/screens/products_overview_screen.dart';
import 'package:shop/screens/user_products_screen.dart';
import '/providers/products.dart';
import 'package:provider/provider.dart';
import '/providers/cart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
            create: (ctx) => Products('', []),
            update: (_, auth, previousProduct) => Products(
                  auth.token,
                  previousProduct == null ? [] : previousProduct.items,
                )),
        ChangeNotifierProvider(
          create: (context) => Cart(),
        ),
         ChangeNotifierProxyProvider<Auth, Orders>(
            create: (ctx) => Orders('', []),
            update: (ctx, auth, previousProduct) => Orders(
                  auth.token,
                  previousProduct == null ? [] : previousProduct.orders,
                )),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Shop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            secondaryHeaderColor: Colors.deepPurple,
          ),
          home: auth.isAuth ? ProductsOverviewScreen() : AuthScreen(),
          routes: {
                        ProductsOverviewScreen.routeName: (ctx) => ProductsOverviewScreen(),

            ProductDetailsScreen.routeName: (ctx) => ProductDetailsScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            '/myorders': (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (context) => UserProductsScreen(),
            EditProductScreen.routeName: (context) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
