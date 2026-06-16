import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tesing/products.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFoucsNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();

  var _editProduct =
      Product(id: "", title: "", price: 10, description: '', imageUrl: '');
  @override
  void dispose() {
    _priceFoucsNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _saveForm() {
    final isValid = _form.currentState?.validate();
    if (isValid != null) {
      if (isValid) {
        _form.currentState?.save();
        //print(_editProduct.title);
        Provider.of<Products>(context, listen: false)
            .addProduct(_editProduct)
            .then((value) {
          //Navigator.of(context).pop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.save))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          //autovalidateMode: AutovalidateMode.always,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_priceFoucsNode);
                },
                onSaved: (val) {
                  if (val != null) {
                    _editProduct = Product(
                        id: "",
                        title: val,
                        description: _editProduct.description,
                        price: _editProduct.price,
                        imageUrl: _editProduct.imageUrl);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please fill this field';
                  }
                  return null;
                },
                keyboardType: TextInputType.text,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Price',
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFoucsNode,
              ),
              TextFormField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.multiline),
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(top: 8, right: 10),
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey)),
                    child: _imageUrlController.text.isEmpty
                        ? Text('enter Url')
                        : Text(_imageUrlController.text),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 200,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Image',
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.url,
                      controller: _imageUrlController,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
