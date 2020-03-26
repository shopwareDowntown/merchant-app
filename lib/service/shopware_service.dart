import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:product_import_app/model/simple_product.dart';
import 'package:product_import_app/notifier/access_data_provider.dart';
import 'package:product_import_app/notifier/product_provider.dart';
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

  Future<List<SimpleProduct>> fetchProducts(BuildContext context) async {
    final accessData = Provider.of<AccessDataChangeNotifier>(
      context,
      listen: false,
    );

    final response = await dio.get(
      "${accessData.shopUrl}/api/v1/product?associations[cover][]",
      options: Options(
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer ${accessData.accessToken}",
        },
      ),
    );

    List data = response.data['data'];

    Provider.of<ProductProvider>(context, listen: false).setProducts(
      data.map((productMap) => SimpleProduct.fromJson(productMap)).toList(),
    );

    return [];
  }

  Future uploadProduct(
    BuildContext context,
    SimpleProduct product,
  ) async {
    final accessData = Provider.of<AccessDataChangeNotifier>(
      context,
      listen: false,
    );
    await dio.request(
      "${accessData.shopUrl}/api/v1/product${!product.isNew ? '/${product.id}' : ''}",
      data: product.toMap(),
      options: Options(
        method: product.isNew ? 'POST' : 'PATCH',
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
          "Authorization": "Bearer ${accessData.accessToken}",
        },
      ),
    );

    if (product.hasMedia) {
      final image = product.image;
      final extension = image.path.split('.').last;
      final postData = image.openRead();
      final length = (await image.readAsBytes()).length;

      await dio.post(
        "${accessData.shopUrl}/api/v1/_action/media/${product.mediaId}/upload",
        data: postData,
        queryParameters: {
          'extension': extension,
          'fileName': image.path.split('/').last.split('.').first,
        },
        options: Options(
          contentType: 'image/$extension',
          headers: {
            Headers.contentLengthHeader: length,
            Headers.acceptHeader: 'application/json',
            "Authorization": "Bearer ${accessData.accessToken}",
          },
        ),
      );
    }

    Provider.of<ProductProvider>(context, listen: false).addProduct(product);
  }
}
