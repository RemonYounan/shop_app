import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../screens/products_overview_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  Widget buildListTiel(
      BuildContext context, String title, IconData icon, Function() handler) {
    return ListTile(
      leading: Icon(
        icon,
        size: 30,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.button,
      ),
      onTap: handler,
      // () {
      //   Navigator.pushReplacementNamed(
      //       context, ProductsOverviewScreen.routeName);
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              'Choose',
              style: TextStyle(color: Colors.white, fontSize: 26),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                buildListTiel(
                  context,
                  'Shop',
                  Icons.shop,
                  () {
                    Navigator.pushReplacementNamed(
                        context, ProductsOverviewScreen.routeName);
                  },
                ),
                Divider(),
                buildListTiel(
                  context,
                  'Cart',
                  Icons.shopping_cart,
                  () {
                    Navigator.popAndPushNamed(context, CartScreen.routeName);
                  },
                ),
                Divider(),
                buildListTiel(
                  context,
                  'Orders',
                  Icons.payments_outlined,
                  () {
                    Navigator.pushReplacementNamed(
                        context, OrderScreen.routeName);
                  },
                ),
                Divider(),
                buildListTiel(
                  context,
                  'Edit Products',
                  Icons.edit,
                  () {
                    Navigator.pushReplacementNamed(
                        context, UserProductsScreen.routeName);
                  },
                ),
                Divider(),
                buildListTiel(
                  context,
                  'Log Out',
                  Icons.logout,
                  () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/');
                    Provider.of<Auth>(context, listen: false).logout();
                  },
                ),
              ],
            ),
          ),
          Text('Developed With Flutter !')
        ],
      ),
    );
  }
}
