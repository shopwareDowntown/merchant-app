import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:product_import_app/notifier/access_data_provider.dart';
import 'package:provider/provider.dart';

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
  }) async {
    final accessData = Provider.of<AccessDataChangeNotifier>(
      context,
      listen: false,
    );

    // todo handle invalid token? or ignore cause merchant api use basic auth with username and password

    return await dio.post(
      "${accessData.shopUrl}/api/v1/product",
      data: {
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
      },
      options: Options(
        contentType: 'application/json',
        headers: {
          'Accept': 'application/vnd.api+json',
          "Authorization": "Bearer ${accessData.accessToken}",
        },
      ),
    );
  }
}
