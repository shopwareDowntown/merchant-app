import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:product_import_app/model/authority.dart';
import 'package:product_import_app/model/simple_product.dart';
import 'package:product_import_app/notifier/access_data_provider.dart';
import 'package:product_import_app/notifier/authority_provider.dart';
import 'package:product_import_app/notifier/product_provider.dart';
import 'package:provider/provider.dart';

class ShopwareService {
  static ShopwareService _instance;
  final Dio dio;
  static const BASE_URL = 'https://sw6.ovh'; // TODO? Correct url
  static const API_VERSION = 1; // TODO? Correct url

  ShopwareService._internal()
      : dio =
            Dio(BaseOptions(baseUrl: "$BASE_URL/merchant-api/v$API_VERSION")) {
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
      "/products",
      options: Options(
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
          "sw-access-key": accessData.authority.accessKey,
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
      final image = product.image;
      data["media"] = [
        await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last.split('.').first,
        )
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

  Future<String> getCompanyName(BuildContext context) async {
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

    return companyName;
  }

  Options _authorizedOptions(AccessDataChangeNotifier accessData) {
    return Options(
      headers: {
        'Accept': 'application/json',
        "sw-access-key": accessData.authority.accessKey,
        "sw-context-token": accessData.contextToken,
      },
    );
  }

  Future<List<Authority>> getAuthorities(BuildContext context) async {
    final authorityProvider =
        Provider.of<AuthorityProvider>(context, listen: false);

    if (authorityProvider.hasAuthorities) {
      return authorityProvider.authorities;
    }

    final response = await dio.get("/authorities");
    final List authoritiesData = response.data;
    final List<Authority> authorities = authoritiesData
        .map((authorityData) => Authority.fromJson(authorityData))
        .toList();

    authorityProvider.setAuthorities(authorities);

    return authorities;
  }
}
