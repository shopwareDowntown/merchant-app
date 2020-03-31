import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

class SimpleProduct {
  String id;
  String name;
  int stock;
  String description;
  String number;
  num price;
  num tax;
  List<File> images = [];
  List<String> imageUrls = [];
  bool _isNew = true;

  set isNew(bool value) {
    this._isNew = value;
  }

  bool get isNew => _isNew || id == null;

  bool get hasMedia => images.isNotEmpty;

  SimpleProduct({
    this.id,
    this.name,
    this.stock,
    this.description,
    this.price,
    this.number,
    this.tax,
    List<File> images,
  }) {
    this.images = images ?? [];
    this.id = this.id ?? Uuid().v4().replaceAll('-', '');
  }

  factory SimpleProduct.fromJson(Map<String, dynamic> data) {
    final product = SimpleProduct(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      stock: data['stock'],
      number: data['productNumber'],
      price: data['price'],
      tax: data['tax'],
    );

    if (data['media'] != null) {
      product.imageUrls = List<String>.from(data['media']);
    }

    product._isNew = false;

    return product;
  }

  Iterable<Widget> imageWidget(BuildContext context) {
    if (hasMedia) {
      return images.map<Widget>((image) => Image.file(image));
    }

    if (imageUrls.isNotEmpty) {
      return imageUrls.map((imageUrl) => Image.network(imageUrl));
    }

    return [
      Container(
        child: Text('TODO'),
      )
    ];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'id': id,
      'stock': stock,
      'tax': tax,
      'name': name,
      'description': description,
      'price': price,
      'productNumber': number,
      'productType': 'product',
    };

    return data;
  }
}
