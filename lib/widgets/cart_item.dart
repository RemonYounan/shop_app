import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productid;
  final String title;
  final double price;
  final int quantity;

  CartItem(this.id, this.productid, this.title, this.price, this.quantity);
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        margin: const EdgeInsets.all(15),
        child: Icon(
          Icons.delete,
          size: 30,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 15),
      ),
      onDismissed: (dir) {
        Provider.of<Cart>(context, listen: false).deleteItem(productid);
      },
      direction: DismissDirection.endToStart,
      confirmDismiss: (dir) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Are You Sure ?'),
            content: Text('Do you want to remove the item form cart ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('no'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text('yes'),
              ),
            ],
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: ListTile(
              leading: CircleAvatar(
                child: FittedBox(
                  child: Text('\$${price.toStringAsFixed(2)}'),
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: Text(title),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total: \$${(price * quantity).toStringAsFixed(2)}'),
                  Text(
                    'x$quantity',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              trailing: IconButton(
                onPressed: () {
                  Provider.of<Cart>(context, listen: false)
                      .addItem(productid, price, title);
                },
                icon: Icon(Icons.add),
              )),
        ),
      ),
    );
  }
}
