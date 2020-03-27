import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:product_import_app/icon/shopware_icons.dart';
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
  bool autoValidate = false;
  PageController pageController = PageController();

  List<File> _images = [];
  List<String> _imageUrls = [];

  String id;

  @override
  initState() {
    super.initState();
    this.id = widget.id;

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
          _images = product.images ?? [];
          _imageUrls = product.imageUrls ?? [];
          autoValidate = true;
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _taxController.dispose();
    _productNumberController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _nameController.dispose();
    pageController.dispose();
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
          padding: const EdgeInsets.all(42.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _productNumberController,
                  autovalidate: autoValidate,
                  decoration: InputDecoration(
                    labelText: localization.translate('productNumber'),
                    suffixIcon: GestureDetector(
                      onTap: scan,
                      child: ClipRRect(
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(6),
                        ),
                        child: Container(
                          margin: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Color(0xFFD1D9E0),
                              ),
                            ),
                            color: Color(0xFFF9FAFB),
                          ),
                          child: Icon(
                            ShopwareIcons.barcode,
                            color: Color(0xFF758CA3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _notEmptyValidation,
                  focusNode: _focusNodeProductNumber,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(
                      context,
                      _focusNodeProductNumber,
                      _focusNodeName,
                    );
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _nameController,
                  autovalidate: autoValidate,
                  decoration: InputDecoration(
                    labelText: localization.translate('productName'),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _notEmptyValidation,
                  focusNode: _focusNodeName,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(
                      context,
                      _focusNodeName,
                      _focusNodeDescription,
                    );
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _descriptionController,
                  autovalidate: autoValidate,
                  decoration: InputDecoration(
                    labelText: localization.translate('productDescription'),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  validator: _notEmptyValidation,
                  focusNode: _focusNodeDescription,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(
                        context, _focusNodeDescription, _focusNodePrice);
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        autovalidate: autoValidate,
                        decoration: InputDecoration(
                          labelText: localization.translate('productPrice'),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: _numberValidator,
                        keyboardType: TextInputType.number,
                        focusNode: _focusNodePrice,
                        onFieldSubmitted: (term) {
                          _fieldFocusChange(
                              context, _focusNodePrice, _focusNodeStock);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 40,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        autovalidate: autoValidate,
                        decoration: InputDecoration(
                          labelText: localization.translate('productStock'),
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: _numberValidator,
                        focusNode: _focusNodeStock,
                        onFieldSubmitted: (term) {
                          _fieldFocusChange(
                              context, _focusNodeStock, _focusNodeTax);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                // TODO: select box
                TextFormField(
                  controller: _taxController,
                  autovalidate: autoValidate,
                  decoration: InputDecoration(
                    labelText: localization.translate('productTax'),
                  ),
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  validator: _numberValidator,
                  focusNode: _focusNodeTax,
                  onFieldSubmitted: (term) {
                    _focusNodeTax.unfocus();
                    save();
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                if (_imageUrls.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 291 * 100,
                      child: PageView.builder(
                        scrollDirection: Axis.horizontal,
                        controller: pageController,
                        itemCount: _imageUrls.length,
                        itemBuilder: (context, index) => Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context)
                                    .inputDecorationTheme
                                    .border
                                    .borderSide
                                    .color),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          width: double.infinity,
                          child: AspectRatio(
                            aspectRatio: 291 / 144,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        _imageUrls[index],
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        _imageUrls.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_images.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 291 * 100,
                      child: PageView.builder(
                        scrollDirection: Axis.horizontal,
                        controller: pageController,
                        itemCount: _images.length,
                        itemBuilder: (context, index) => Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context)
                                    .inputDecorationTheme
                                    .border
                                    .borderSide
                                    .color),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          width: double.infinity,
                          child: AspectRatio(
                            aspectRatio: 291 / 144,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.file(
                                        _images[index],
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        _images.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: OutlineButton(
                    onPressed: getImage,
                    color: Theme.of(context).accentColor.withOpacity(0.1),
                    borderSide:
                        BorderSide(color: Theme.of(context).accentColor),
                    child: Text(
                      localization.translate('uploadImage'),
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    child: Text(localization.translate('save')),
                    onPressed: save,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> removeImagesDialog({bool replace = false}) async {
    if (_imageUrls.isEmpty) {
      return true;
    }

    final response = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(replace ? "Replace images" : "Remove images"),
        contentTextStyle: TextStyle(color: Colors.black),
        content: Text(replace
            ? 'Continue and replace all existing images?'
            : 'Continue and remove all existing images?'),
        actions: <Widget>[
          FlatButton(
            textColor: Theme.of(context).accentColor,
            child: Text('Confirm'),
            autofocus: true,
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          FlatButton(
            textColor: Theme.of(context).accentColor,
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      ),
    );

    if (response != true) {
      return false;
    }

    setState(() {
      _imageUrls = [];
    });

    return true;
  }

  Future getImage() async {
    final response = await removeImagesDialog(replace: true);

    if (!response) {
      return;
    }

    final image = await ImagePicker.pickImage(
      source: ImageSource.camera,
      // todo max width/height/quality?
      imageQuality: 30,
    );

    if (image != null) {
      setState(() {
        _images.add(image);
      });
    }
  }

  void save() async {
    setState(() {
      autoValidate = true;
    });

    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final product = (productProvider.getById(id) ?? SimpleProduct());
    product
      ..id = id
      ..name = _nameController.text
      ..number = _productNumberController.text
      ..price = num.parse(_priceController.text)
      ..stock = int.parse(_stockController.text)
      ..tax = int.parse(_taxController.text)
      ..description = _descriptionController.text
      ..images = _images;

    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: FutureBuilder(
          initialData: false,
          future: ShopwareService().uploadProduct(
            context,
            product,
          ),
          builder: (dialogContext, snapShot) {
            Widget Function(BuildContext) dialogCallback = _loadingDialogWidget;

            if (snapShot.hasData && snapShot.data) {
              dialogCallback = _finishedModalWidget;
            }
            if (snapShot.hasError) {
              dialogCallback =
                  (context) => _errorModalWidget(context, snapShot.error);
            }

            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: dialogCallback(dialogContext),
              ),
            );
          },
        ),
      ),
    );

    if (!result) {
      return;
    }

    _productNumberController.text = '';
    _nameController.text = '';
    _descriptionController.text = '';
    _priceController.text = '';
    _stockController.text = '';
    _taxController.text = '';
    setState(() {
      id = null;
      _images = [];
      _imageUrls = [];
      autoValidate = false;
    });
  }

  Widget _finishedModalWidget(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.done,
          color: Theme.of(context).accentColor,
          size: 52,
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          AppLocalizations.of(context).translate('successfulImport'),
          textAlign: TextAlign.center,
          style: Theme.of(context).dialogTheme.contentTextStyle,
        ),
        SizedBox(
          height: 20,
        ),
        SizedBox(
          width: double.infinity,
          child: RaisedButton(
            child: Text(
                AppLocalizations.of(context).translate('createAdditional')),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ),
      ],
    );
  }

  Widget _errorModalWidget(BuildContext context, DioError error) {
    final response = error.response.data;
    print(response);

    List errors = [response.toString()];
//    List errors =
//        response['errors'].map((error) => error['detail'].toString()).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 52,
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          errors.join('\n'),
          textAlign: TextAlign.center,
          style: Theme.of(context).dialogTheme.contentTextStyle,
        ),
        SizedBox(
          height: 20,
        ),
        SizedBox(
          width: double.infinity,
          child: RaisedButton(
            child: Text(
              AppLocalizations.of(context).translate('close'),
            ),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ),
      ],
    );
  }

  Widget _loadingDialogWidget(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 52,
          width: 52,
          child: CircularProgressIndicator(),
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          AppLocalizations.of(context).translate('productWillBeImported'),
          textAlign: TextAlign.center,
          style: Theme.of(context).dialogTheme.contentTextStyle,
        ),
      ],
    );
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

  String _numberValidator(String value) {
    if (value.isEmpty) {
      return AppLocalizations.of(context).translate('requiredField');
    }

    if (!RegExp(
      r'(^(-?)(0|([1-9][0-9]*))(\.[0-9]*)?$)',
    ).hasMatch(value)) {
      return AppLocalizations.of(context).translate('numberOnlyField');
    }

    return null;
  }

  Future scan() async {
    try {
      String eanCode = await BarcodeScanner.scan();
      Map eanInformation = await eanService.fetchInformation(eanCode);

      this._productNumberController.text = eanInformation['ean'] ?? '';
      this._nameController.text = eanInformation['fullName'] ?? '';
      this._descriptionController.text = eanInformation['description'] ?? '';
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        // The user did not grant the camera permission!
        print('The user did not grant the camera permission!');
      } else {
        print('Unknown error: $e');
      }
    } catch (e) {
      print('Unknown error: $e');
    }
  }
}
