import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-products';
  EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageControler = TextEditingController();
  final _imageFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct =
      Product(id: '-1', title: '', description: '', price: 0, imageUrl: '');

  var _initValues = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': '',
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageFocusNode.addListener(_updateImage);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments as String;
      if (productId != 'add') // It can be null so i check :)
      {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'price': _editedProduct.price.toString(),
          'description': _editedProduct.description,
          // 'imageUrl': _editedProduct.imageUrl, // can't use both initValue and Controler.
          'imageUrl': '',
        };
        _imageControler.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageFocusNode.removeListener(_updateImage);
    _imageControler.dispose();
    _imageFocusNode.dispose();
    super.dispose();
  }

  void _updateImage() {
    if (!_imageFocusNode.hasFocus) {
      if (_imageControler.text.isEmpty ||
          (!_imageControler.text.startsWith('http') &&
              !_imageControler.text.startsWith('https')) ||
          (!_imageControler.text.endsWith('.png') &&
              !_imageControler.text.endsWith('.jpg') &&
              !_imageControler.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  void _saveData() async {
    final _isvalid = _form.currentState!.validate();
    if (!_isvalid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != '-1') {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);

      Navigator.of(context).pop();
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog<Null>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('An error occured'),
            content: Text('Somthing went Wrong !'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('ok'),
              )
            ],
          ),
        );
      }
      Navigator.of(context).pop();

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
        actions: [
          IconButton(
            onPressed: () {
              _saveData();
              // Scaffold.of(context).hideCurrentSnackBar();
              // Scaffold.of(context).showSnackBar(
              //   SnackBar(
              //     content: Text('Item has been added to cart !'),
              //     duration: Duration(seconds: 2),
              //   ),
              // );
            },
            icon: Icon(
              Icons.save,
              size: 30,
            ),
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _initValues['title'],
                        decoration: InputDecoration(
                            labelText: 'Title',
                            errorStyle: TextStyle(fontSize: 14),
                            icon: Icon(Icons.format_color_text_rounded)),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter Title';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            title: value as String,
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl,
                            isFavourite: _editedProduct.isFavourite,
                          );
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['price'],
                        decoration: InputDecoration(
                            labelText: 'Price',
                            errorStyle: TextStyle(fontSize: 14),
                            icon: Icon(Icons.money)),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter Price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please Enter Valid Price';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Please Enter a number greater than zero';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            price: value!.isEmpty ? 0 : double.parse(value),
                            imageUrl: _editedProduct.imageUrl,
                            isFavourite: _editedProduct.isFavourite,
                          );
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['description'],
                        decoration: InputDecoration(
                            labelText: 'Description',
                            errorStyle: TextStyle(fontSize: 14),
                            icon: Icon(Icons.text_fields)),
                        // textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter Description';
                          }
                          if (value.length < 10) {
                            return 'Should be greater than 10 characters';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: value as String,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl,
                            isFavourite: _editedProduct.isFavourite,
                          );
                        },
                      ),
                      TextFormField(
                        // initialValue: _initValues['imageUrl'],
                        decoration: InputDecoration(
                          labelText: 'Image URL',
                          errorStyle: TextStyle(fontSize: 14),
                          icon: _imageControler.text.isEmpty ||
                                  (!_imageControler.text.startsWith('http') &&
                                      !_imageControler.text
                                          .startsWith('https')) ||
                                  (!_imageControler.text.endsWith('.png') &&
                                      !_imageControler.text.endsWith('.jpg') &&
                                      !_imageControler.text.endsWith('.jpeg'))
                              ? Icon(
                                  Icons.image,
                                  size: 40,
                                )
                              : Container(
                                  height: 40,
                                  width: 40,
                                  child: Image.network(_imageControler.text,
                                      fit: BoxFit.cover),
                                ),
                        ),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter Valid URl';
                          }
                          if (!value.startsWith('http') &&
                              !value.startsWith('https')) {
                            return 'Please Enter Valid URl';
                          }
                          if (!value.endsWith('.png') &&
                              !value.endsWith('.jpg') &&
                              !value.endsWith('.jpeg')) {
                            return 'Please Enter Valid URl';
                          }
                          return null;
                        },
                        controller: _imageControler,
                        focusNode: _imageFocusNode,
                        onSaved: (value) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            imageUrl: value as String,
                            isFavourite: _editedProduct.isFavourite,
                          );
                        },
                      ),
                      TextButton(
                        child: Text('Submit'),
                        onPressed: () {
                          _saveData();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
