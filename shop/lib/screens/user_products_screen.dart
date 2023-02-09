import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/screens/edit_product_screen.dart';
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/user_product_item.dart';
import '/providers/products.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async{
    await Provider.of<Products>(context, listen: false).fetchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh:()=> _refreshProducts(context),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: productsData.items.length,
            itemBuilder: (context, i) => UserProductItem(
              productsData.items[i].title,
              productsData.items[i].imageUrl,
              productsData.items[i].id,
            ),
          ),
        ),
      ),
    );
  }
}
