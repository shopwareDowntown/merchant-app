import 'package:flutter/material.dart';
import 'package:downtown_merchant_app/model/simple_product.dart';
import 'package:downtown_merchant_app/pages/import_page.dart';

class ProductListTile extends StatelessWidget {
  final SimpleProduct product;

  ProductListTile(this.product);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: ListTile(
        leading: SizedBox(
          width: 70,
          height: 62,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(4),
              ),
              border: Border.all(
                  color: Theme.of(context)
                      .inputDecorationTheme
                      .border
                      .borderSide
                      .color),
            ),
            child: Center(child: product.imageWidget(context).first),
          ),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(4),
            ),
            border: Border.all(
                color: Theme.of(context)
                    .inputDecorationTheme
                    .border
                    .borderSide
                    .color),
          ),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ImportPage(id: product.id),
                ),
              );
            },
            icon: Icon(Icons.mode_edit),
          ),
        ),
        title: Text(product.name),
      ),
    );
  }
}
