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
  bool isNew = true;

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
      price: data['price'][0]['gross'],
      tax: data['tax']['taxRate'],
    );

    product._imageUrl =
        data['cover'] != null ? data['cover']['media']['url'] : null;
    product.isNew = false;

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
      'active': true,
      'stock': stock,
      'taxId': "c9f0c92c0f9147a989fbe7b000b4fdc9", // todo fetch correct
      'name': name,
      'description': description,
      'productNumber': number,
      'price': [
        {
          'currencyId':
              'b7d2554b0ce847cd82f3ac9bd1c0dfca', // todo fetch correct
          'net': price,
          'linked': true,
          'gross': price,
        }
      ],
    };

    // TODO: can be removed in new api?!
    if (isNew) {
      data['categories'] = [
        {
          'id': '4350dffd5ddc4920adb92e57c7ad0f7f' // todo fetch correct
        },
      ];
      data['visibilities'] = [
        {
          'salesChannelId':
              '900c93394f094b3cb41604788eba7638', // todo fetch correct
          'visibility': 30,
        }
      ];
    }

    if (hasMedia) {
      final productMediaId = Uuid().v4().replaceAll('-', '');
      data['media'] = [
        {
          'id': productMediaId,
          'media': {
            'id': mediaId,
          },
        }
      ];

      data['coverId'] = productMediaId;
    }

    return data;
  }
}
