import 'package:flutter/material.dart';

import '../../services/supabase_service.dart';

class Products with ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => [..._items];

  Future<bool> addProduct(Product product) async {
    final saved = await SupabaseService.insert('products', {
      'title': product.title,
      'description': product.description,
      'price': product.price,
      'image_url': product.imageUrl,
    });

    if (saved) {
      _items.add(product);
      notifyListeners();
    }

    return saved;
  }
}

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });
}
