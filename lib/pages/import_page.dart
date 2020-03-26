import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:product_import_app/model/simple_product.dart';
import 'package:product_import_app/notifier/product_provider.dart';
import 'package:product_import_app/service/app_localizations.dart';
import 'package:product_import_app/service/ean.dart';
import 'package:product_import_app/service/shopware_service.dart';
import 'package:product_import_app/widgets/default_drawer.dart';
import 'package:provider/provider.dart';

class ImportPage extends StatefulWidget {
  @override
  _ImportPageState createState() => _ImportPageState();

  final String id;

  ImportPage({this.id});
}

class _ImportPageState extends State<ImportPage> {
  EanService eanService = EanService();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _productNumberController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController = TextEditingController();
  final _taxController = TextEditingController();
  final _focusNodeName = FocusNode();
  final _focusNodeProductNumber = FocusNode();
  final _focusNodePrice = FocusNode();
  final _focusNodeDescription = FocusNode();
  final _focusNodeStock = FocusNode();
  final _focusNodeTax = FocusNode();
  String _errorText;

  File _image;

  @override
  initState() {
    super.initState();
    if (widget.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final productProvider =
            Provider.of<ProductProvider>(context, listen: false);
        final SimpleProduct product = productProvider.getById(widget.id);

        _nameController.text = product.name ?? '';
        _productNumberController.text = product.number ?? '';
        _descriptionController.text = product.description ?? '';
        _stockController.text = product.stock?.toString() ?? '';
        _priceController.text = product.price?.toString() ?? '';
        _taxController.text = product.tax?.toString() ?? '';
        setState(() {
          _image = product.image;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate("importPageTitle")),
      ),
      drawer: DefaultDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: localization.translate('productName'),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _notEmptyValidation,
                  focusNode: _focusNodeName,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(
                        context, _focusNodeName, _focusNodeProductNumber);
                  },
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: _productNumberController,
                        decoration: InputDecoration(
                          labelText: localization.translate('productNumber'),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: _notEmptyValidation,
                        focusNode: _focusNodeProductNumber,
                        onFieldSubmitted: (term) {
                          _fieldFocusChange(context, _focusNodeProductNumber,
                              _focusNodeDescription);
                        },
                      ),
                    ),
                    RaisedButton(
                      onPressed: scan,
                      child: Text(localization.translate('scan')),
                    ),
                  ],
                ),
                _image != null
                    ? ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.height / 10),
                        child: Center(
                          child: Image.file(
                            _image,
                          ),
                        ),
                      )
                    : Container(),
                RaisedButton(
                  onPressed: getImage,
                  child: Text(localization.translate('uploadImage')),
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: localization.translate('productDescription'),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _notEmptyValidation,
                  focusNode: _focusNodeDescription,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(
                        context, _focusNodeDescription, _focusNodePrice);
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: localization.translate('productPrice'),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _notEmptyValidation,
                  focusNode: _focusNodePrice,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(
                        context, _focusNodePrice, _focusNodeStock);
                  },
                ),
                TextFormField(
                  controller: _stockController,
                  decoration: InputDecoration(
                    labelText: localization.translate('productStock'),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _notEmptyValidation,
                  focusNode: _focusNodeStock,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(context, _focusNodeStock, _focusNodeTax);
                  },
                ),
                TextFormField(
                  controller: _taxController,
                  decoration: InputDecoration(
                    labelText: localization.translate('productTax'),
                  ),
                  textInputAction: TextInputAction.done,
                  validator: _notEmptyValidation,
                  focusNode: _focusNodeTax,
                  onFieldSubmitted: (term) {
                    _focusNodeTax.unfocus();
                    save();
                  },
                ),
                _errorText != null ? Text(_errorText) : Container(),
                RaisedButton(
                  child: Text(localization.translate('save')),
                  onPressed: save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future getImage() async {
    final image = await ImagePicker.pickImage(
      source: ImageSource.camera,
      // todo max width/height/quality?
      maxWidth: 300,
      maxHeight: 300,
      imageQuality: 30,
    );

    setState(() {
      _image = image;
    });
  }

  void save() async {
    if (!_formKey.currentState.validate()) {
      // todo handle errors
      return;
    }

    setState(() {
      _errorText = null;
    });

    _formKey.currentState.save();
    try {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      final product = (productProvider.getById(widget.id) ?? SimpleProduct());
      product
        ..id = widget.id
        ..name = _nameController.text
        ..number = _productNumberController.text
        ..price = num.parse(_priceController.text)
        ..stock = int.parse(_stockController.text)
        ..description = _descriptionController.text
        ..image = _image;

      await ShopwareService().uploadProduct(
        context,
        product,
      );
      // success
    } on DioError catch (e) {
      setState(() {
        _errorText = e.response.data.toString();
      });
    }
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  String _notEmptyValidation(String value) {
    if (value.isEmpty) {
      return AppLocalizations.of(context).translate('requiredField');
    }

    return null;
  }

  Future scan() async {
    try {
      String eanCode = await BarcodeScanner.scan();
      Map eanInformation = await eanService.fetchInformation(eanCode);

      setState(() {
        this._errorText = '';

        this._productNumberController.text = eanInformation['ean'] ?? '';
        this._nameController.text = eanInformation['fullName'] ?? '';
        this._descriptionController.text = eanInformation['description'] ?? '';
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        // The user did not grant the camera permission!
        setState(() {
          this._errorText = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this._errorText = 'Unknown error: $e');
      }
    } catch (e) {
      setState(() => this._errorText = 'Unknown error: $e');
    }
  }
}
