import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:product_import_app/service/app_localizations.dart';

class ImportPage extends StatefulWidget {
  @override
  _ImportPageState createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
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

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: new AppBar(
        title: new Text('Import Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: new Column(
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
                  _fieldFocusChange(context, _focusNodePrice, _focusNodeStock);
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
              RaisedButton(
                child: Text(localization.translate('save')),
                onPressed: save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void save() async {
    if (!_formKey.currentState.validate()) {
      // todo handle errors
      return;
    }

    // todo: make api call
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
      String barcode = await BarcodeScanner.scan();
      setState(() => this._productNumberController.text = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        // The user did not grant the camera permission!
      } else {
        // unknown error
      }
    } catch (e) {
      // Unknown error: $e
    }
  }
}
