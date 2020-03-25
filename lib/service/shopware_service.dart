import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:product_import_app/notifier/access_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ShopwareService {
  static ShopwareService _instance;
  final Dio dio;

  ShopwareService._internal() : dio = Dio() {
    // todo add interceptor for refreshing token if invalid
    // todo set base options accept / authorization
  }

  factory ShopwareService() {
    if (_instance == null) {
      _instance = ShopwareService._internal();
    }

    return _instance;
  }

  Future uploadProduct(
    BuildContext context, {
    @required String name,
    @required String number,
    @required num price,
    String description,
    @required num taxRate,
    @required int stock,
    File image,
  }) async {
    final accessData = Provider.of<AccessDataChangeNotifier>(
      context,
      listen: false,
    );
    String mediaId;

    accessData.init(
      accessToken:
          'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjcwZWJhZTlhNzkzMTM2MjI1YTMxNTY2YmFhOGZiNGY0NzJmZWRjYjZkNjI1NzQ0ZjY1OGY1YjRiOGFjOTdlZmVkMDQ0OTMzMTI2MmQxN2UyIn0.eyJhdWQiOiJhZG1pbmlzdHJhdGlvbiIsImp0aSI6IjcwZWJhZTlhNzkzMTM2MjI1YTMxNTY2YmFhOGZiNGY0NzJmZWRjYjZkNjI1NzQ0ZjY1OGY1YjRiOGFjOTdlZmVkMDQ0OTMzMTI2MmQxN2UyIiwiaWF0IjoxNTg1MTU3NzI1LCJuYmYiOjE1ODUxNTc3MjUsImV4cCI6MTU4NTE1ODMyNSwic3ViIjoiZTQ0Mzk0NTU0ZDVmNDQyMWE1ZDE3OWZmZDYwYmZlMTQiLCJzY29wZXMiOlsid3JpdGUiLCJhZG1pbiIsIndyaXRlIiwiYWRtaW4iXX0.QEHY4VzvMBBamvOQU9w3IrR5p4IzuqiKpFF3UzKiHyu-qXki5666-EnDRelYgZzaBvYzVxOaKneXb0_POv1q14wfiMyJH3EaaF3pj_B7EpBtIZ9Dlue9a8B0DseL-wm-KW4UwE4dr07Ndrv_h8pHT6wSaicGV1peJecU3L51orRDmKiR3l69jw-IXeBm6usC-VA8N-eO7gKC2ICGUFgVz750oM4iAZJ1MM3UxsTPH9bz1RgHChX1St7LJS2T3Gci2LcT_1uJrl0zSS5wLLya7pghaEP0w65-14XGjJnieLjvDhXhmXQk3YrVwDWRzDWBVqipG7ipTXABhCc2djv1nw',
    ); // todo handle invalid token? or ignore cause merchant api use basic auth with username and password

    Map data = {
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
      'categories': [
        {
          'id': '4350dffd5ddc4920adb92e57c7ad0f7f' // todo fetch correct
        },
      ],
      'visibilities': [
        {
          'salesChannelId':
              '900c93394f094b3cb41604788eba7638', // todo fetch correct
          'visibility': 30,
        }
      ],
    };

    if (image != null) {
      mediaId = Uuid().v4().replaceAll('-', '');
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

    await dio.post(
      "${accessData.shopUrl}/api/v1/product",
      data: data,
      options: Options(
        contentType: 'application/json',
        headers: {
          'Accept': 'application/vnd.api+json',
          "Authorization": "Bearer ${accessData.accessToken}",
        },
      ),
    );

    if (mediaId != null) {
      final extension = image.path.split('.').last;
      final postData = image.openRead();
      final length = (await image.readAsBytes()).length;

      await dio.post(
        "${accessData.shopUrl}/api/v1/_action/media/$mediaId/upload",
        data: postData,
        queryParameters: {
          'extension': extension,
          'fileName': image.path.split('/').last.split('.').first,
        },
        options: Options(
          contentType: 'image/$extension',
          headers: {
            Headers.contentLengthHeader: length,
            Headers.acceptHeader: 'application/vnd.api+json',
            "Authorization": "Bearer ${accessData.accessToken}",
          },
        ),
      );
    }
  }
}
