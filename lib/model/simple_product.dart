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
  File _image;
  String _imageUrl;
  String _mediaId;
  bool _isNew = true;

  set isNew(bool value) {
    this._isNew = value;
  }

  bool get isNew => _isNew || id == null;

  set image(File image) {
    _image = image;
    _mediaId = image != null ? Uuid().v4().replaceAll('-', '') : null;
  }

  File get image => _image;
  String get mediaId => _mediaId;
  bool get hasMedia => mediaId != null;

  SimpleProduct({
    this.id,
    this.name,
    this.stock,
    this.description,
    this.price,
    this.number,
    this.tax,
    File image,
  }) {
    this.image = image;
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

    product._imageUrl = data['media'];
    product._isNew = false;

    return product;
  }

  Widget imageWidget(BuildContext context) {
    if (hasMedia) {
      return Image.file(_image);
    }

    if (_imageUrl != null) {
      return Image.network(_imageUrl);
    }

    return Container(
      child: Text('TODO'),
    );
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
