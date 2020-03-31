import 'package:downtown_merchant_app/model/simple_product.dart';
import 'package:flutter/material.dart';

class ProductProvider extends ChangeNotifier {
  List<SimpleProduct> _products = [];
  List<SimpleProduct> get products => _products
      .where((product) => product.productType == SimpleProduct.PRODUCT_TYPE)
      .toList();

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
