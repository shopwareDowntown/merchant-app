import 'dart:io';

import 'package:downtown_merchant_app/model/media.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

class SimpleProduct {
  static const PRODUCT_TYPE = 'product';

  bool active;
  String id;
  String name;
  int stock;
  String description;
  String number;
  num price;
  num tax;
  String productType;
  List<File> images = [];
  List<RemoteMedia> imageUrls = [];
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
    this.productType = PRODUCT_TYPE,
    List<File> images,
    this.active,
  }) {
    this.images = images ?? [];
    this.id = this.id ?? Uuid().v4().replaceAll('-', '');
  }

  factory SimpleProduct.fromJson(Map<String, dynamic> data) {
    // TODO: Refactor --> Factory for other product types
    final product = SimpleProduct(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      stock: data['stock'],
      number: data['productNumber'],
      price: data['price'],
      tax: data['tax'],
      productType: data['productType'],
      active: data['active'] == true || data['active'] == 1,
    );

    if (data['media'] != null) {
      if (data['media'][0] is String) {
        product.imageUrls = List.generate(data['media'].length,
            (index) => RemoteMedia(url: data['media'][index]));
      } else {
        product.imageUrls = List.generate(data['media'].length,
            (index) => RemoteMedia.fromJson(data['media'][index]));
      }
    }

    product._isNew = false;

    return product;
  }

  Iterable<Widget> imageWidget(BuildContext context) {
    if (hasMedia) {
      return images.map<Widget>((image) => Image.file(image));
    }

    if (imageUrls.isNotEmpty) {
      return imageUrls.map((remoteImage) => Image.network(remoteImage.url));
    }

    return [Container()];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'active': active ? 1 : 0,
      'id': id,
      'stock': stock,
      'tax': tax,
      'name': name,
      'description': description,
      'price': price,
      'productNumber': number,
      'productType': productType,
    };

    return data;
  }
}
