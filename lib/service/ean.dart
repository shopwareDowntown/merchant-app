import 'package:dio/dio.dart';

class EanService {
  Future<Map> fetchInformation(String eanCode) async {
    Response response = await Dio().post("https://gtin.hoelshare.com/$eanCode");

    if (response.statusCode != 200) {
      throw 'The response code is not valid';
    }

    return {
      'ean': response.data['ean'],
      'name': response.data['name'],
      'nameEn': response.data['name_en'],
      'fullName': response.data['fullname'],
      'description': response.data['descr'],
      'vendor': response.data['vendor'],
      'packaging': response.data['packaging'],
      'mainCategory': response.data['main_category'],
      'subCategory': response.data['sub_category']
    };
  }
}
