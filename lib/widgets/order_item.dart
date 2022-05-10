import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;
  OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> with TickerProviderStateMixin {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      height:
          _expanded ? min(widget.order.products.length * 20.0 + 200, 200) : 95,
      child: Card(
        elevation: 6,
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text(
                '\$${widget.order.amount!.toStringAsFixed(2)}',
              ),
              subtitle: Text(
                DateFormat('dd/MM/yyyy    hh:mm').format(widget.order.dateTime),
              ),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(
                    () {
                      _expanded = !_expanded;
                    },
                  );
                },
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeIn,
              height: _expanded
                  ? min(widget.order.products.length * 20.0 + 20, 140)
                  : 0,
              child: ListView(
                  padding: const EdgeInsets.only(left: 15),
                  children: widget.order.products
                      .map(
                        (e) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${e.quantity}x\$${e.price}',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                      .toList()),
            ),
            // Container(
            //   height: min(widget.order.products.length * 20.0 + 10, 100),
            //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            //   child:
            // ),
          ],
        ),
      ),
    );
  }
}
