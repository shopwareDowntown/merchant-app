import 'package:dio/dio.dart';
import 'package:downtown_merchant_app/model/simple_product.dart';
import 'package:downtown_merchant_app/notifier/access_data_provider.dart';
import 'package:downtown_merchant_app/notifier/product_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class ShopwareService {
  static ShopwareService _instance;
  final Dio dio;
  static const BASE_URL = 'https://api.downtowns.io';
  static const API_VERSION = 1;

  ShopwareService._internal()
      : dio = Dio(BaseOptions(baseUrl: "$BASE_URL/merchant-api/v$API_VERSION"));

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
      "/products",
      options: Options(
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
          "sw-context-token": accessData.contextToken,
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

    final data = product.toMap();

    if (product.hasMedia) {
      data["media"] = [
        for (int i = 0; i < product.images.length; i++)
          await MultipartFile.fromFile(
            product.images[i].path,
            filename: product.images[i].path.split('/').last,
          ),
      ];
    }

    await dio.post(
      "/products${!product.isNew ? '/${product.id}' : ''}",
      data: FormData.fromMap({...data}),
      options: _authorizedOptions(accessData),
    );

    Provider.of<ProductProvider>(context, listen: false).addProduct(product);

    return true;
  }

  Future<void> loadCompanyInfo(BuildContext context) async {
    final accessData = Provider.of<AccessDataChangeNotifier>(
      context,
      listen: false,
    );

    final response = await dio.get(
      '/profile',
      options: _authorizedOptions(accessData),
    );
    final companyName = response.data['publicCompanyName'];
    accessData.companyName = companyName;

    if (response.data['cover'] != null) {
      accessData.companyCover = response.data['cover']['url'];
    }
  }

  Options _authorizedOptions(AccessDataChangeNotifier accessData) {
    return Options(
      headers: {
        'Accept': 'application/json',
        "sw-context-token": accessData.contextToken,
      },
    );
  }
}
