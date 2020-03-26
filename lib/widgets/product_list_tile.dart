import 'package:flutter/material.dart';
import 'package:product_import_app/model/simple_product.dart';
import 'package:product_import_app/pages/import_page.dart';

class ProductListTile extends StatelessWidget {
  final SimpleProduct product;

  ProductListTile(this.product);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: product.imageWidget(context),
      title: Text(product.name),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ImportPage(id: product.id),
          ),
        );
      },
    );
  }
}
