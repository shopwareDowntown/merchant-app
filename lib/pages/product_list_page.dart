import 'package:flutter/material.dart';
import 'package:downtown_merchant_app/notifier/product_provider.dart';
import 'package:downtown_merchant_app/service/app_localizations.dart';
import 'package:downtown_merchant_app/service/shopware_service.dart';
import 'package:downtown_merchant_app/widgets/default_drawer.dart';
import 'package:downtown_merchant_app/widgets/product_list_tile.dart';
import 'package:provider/provider.dart';

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ShopwareService().fetchProducts(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate("productListPageTitle"),
        ),
      ),
      drawer: DefaultDrawer(),
      body: ListView.separated(
        physics: BouncingScrollPhysics(),
        itemCount: productProvider.products.length,
        itemBuilder: (context, index) =>
            ProductListTile(productProvider.products[index]),
        separatorBuilder: (context, index) => Divider(),
      ),
    );
  }
}
