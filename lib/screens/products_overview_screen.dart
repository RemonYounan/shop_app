import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/products.dart';
import './cart_screen.dart';
import '../widgets/products_grid.dart';
import '../widgets/drawer.dart';
import '../widgets/badge.dart';

enum FilterOptions {
  Favourites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = '/products';
  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _isFav = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    // Provider.of<Products>(context).getProducts(); // Won't Work
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      // _isLoading = true; // should use 'setState' ?!
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).getProducts().then((_) {
        // _isLoading = false;
        setState(() {
          _isLoading = false;
        });
      });
      _isInit = false;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              setState(() {
                if (value == FilterOptions.Favourites) {
                  _isFav = true;
                } else {
                  _isFav = false;
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
              PopupMenuItem(
                child: Text('Show Favourite'),
                value: FilterOptions.Favourites,
              ),
            ],
          ),
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
      drawer: MainDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await Provider.of<Products>(context, listen: false)
                    .getProducts();
                setState(() {});
              },
              child: ProductsGrid(_isFav)),
    );
  }
}
