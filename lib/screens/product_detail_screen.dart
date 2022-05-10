import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/badge.dart';
import '../screens/cart_screen.dart';
import '../providers/products.dart';
import '../providers/cart.dart';

class ProductDetailScreen extends StatelessWidget {
  // final String title;
  // final double price;

  // ProductDetailScreen(this.title, this.price);
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId =
        ModalRoute.of(context)?.settings.arguments as String; // is the id!
    final product = Provider.of<Products>(
      context,
      listen: false,
    ).findById(productId);
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        actions: [
          Consumer<Cart>(
            builder: (c, cart, ch) => Badge(
              child: ch as Widget,
              value: cart.itemCount.toString(),
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, CartScreen.routeName);
              },
              icon: Icon(
                Icons.shopping_cart,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              child: Hero(
                tag: product.id,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              // alignment: Alignment.center,
            ),
            Text(
              '\$${product.price}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              product.description,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              softWrap: true,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final cart = Provider.of<Cart>(context, listen: false);
          cart.addItem(product.id, product.price, product.title);
          Scaffold.of(context).hideCurrentSnackBar();
          Scaffold.of(context).showSnackBar(
            SnackBar(
              dismissDirection: DismissDirection.horizontal,
              behavior: SnackBarBehavior.floating,
              width: 350,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              content: Text('Item has been added to cart !'),
              duration: Duration(seconds: 2),
              action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    cart.deleteSingleItem(product.id);
                  }),
            ),
          );
        },
        child: Icon(Icons.shopping_cart),
      ),
    );
  }
}
