import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/drawer.dart';
import '../widgets/order_item.dart';
import '../providers/orders.dart' show Orders;

class OrderScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late Future _ordersfuture;

  Future _obtainedOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).getOrders();
  }

  @override
  void initState() {
    _ordersfuture = _obtainedOrdersFuture();
    super.initState();
  }

  Future<void> _refresh(BuildContext context) async {
    await Provider.of<Orders>(context, listen: false).getOrders();
  }

  @override
  Widget build(BuildContext context) {
    final allOrders = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: MainDrawer(),
      body: FutureBuilder(
        future: _ordersfuture,
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (dataSnapshot.error != null) {
              return Center(
                child: Text('Error Occured'),
              );
            } else {
              return allOrders.orders.length == 0
                  ? Center(
                      child: Text(
                        'You have no orders.',
                        style: TextStyle(fontSize: 30),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _refresh(context),
                      child: ListView.builder(
                        itemBuilder: (c, i) => OrderItem(allOrders.orders[i]),
                        itemCount: allOrders.orders.length,
                      ),
                    );
            }
          }
        },
      ),
    );
  }
}



// class OrderScreen extends StatelessWidget {
//   static const routeName = '/orders';

//   @override
//   Widget build(BuildContext context) {
//     final allOrders = Provider.of<Orders>(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Your Orders'),
//       ),
//       drawer: MainDrawer(),
//       body: ListView.builder(
//         itemBuilder: (c, i) => OrderItem(allOrders.orders[i]),
//         itemCount: allOrders.orders.length,
//       ),
//     );
//   }
// }
