import 'package:flutter/material.dart';
import 'package:product_import_app/model/simple_product.dart';

class ProductProvider extends ChangeNotifier {
  List<SimpleProduct> _products = [];
  List<SimpleProduct> get products => _products;

  void setProducts(List<SimpleProduct> products) {
    this._products = products;

    notifyListeners();
  }

  void addProduct(SimpleProduct product) {
    if (!product.isNew) {
      return;
    }
    product.isNew = false;
    _products.add(product);

    notifyListeners();
  }

  SimpleProduct getById(String id) {
    return _products.firstWhere(
      (product) => product.id == id,
      orElse: () => null,
    );
  }
}
