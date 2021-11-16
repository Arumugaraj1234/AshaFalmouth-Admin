import 'package:flutter/material.dart';
import 'package:miplate/data_services.dart';
import 'package:miplate/model/response_model.dart';
import 'package:miplate/model/voucher_model.dart';
import 'package:miplate/network_services.dart';
import 'package:miplate/screens/DashboardScreen.dart';
import 'package:miplate/screens/coupon_form_screen.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

const kTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontFamily: 'Roboto Regular',
    fontWeight: FontWeight.w500);

class VoucherFormScreen extends StatefulWidget {
  final int flag;
  final Voucher voucher;

  VoucherFormScreen({this.flag, this.voucher});
  @override
  _VoucherFormScreenState createState() => _VoucherFormScreenState();
}

class _VoucherFormScreenState extends State<VoucherFormScreen> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showSnackBar(String text) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  Voucher _voucher;
  TextEditingController _codeTC = new TextEditingController();
  TextEditingController _percentageTC = new TextEditingController();
  bool _isCodeValid = true;
  FocusNode _codeFN = new FocusNode();
  FocusNode _percentageFN = new FocusNode();
  bool _isPercentageValid = true;
  String _errorMsg = '';

  bool _validateForm() {
    //bool isCodeValid = false;
    bool isPercentageValid = false;
    bool isValid = false;
    _errorMsg = '';

    // if (_codeTC.text == '') {
    //   isCodeValid = false;
    //   _errorMsg = 'Please provide valid coupon code';
    // } else {
    //   isCodeValid = true;
    // }

    if (_percentageTC.text == '' ||
        _percentageTC.text == '0' ||
        _percentageTC.text.contains('.') ||
        _percentageTC.text.contains(',') ||
        _percentageTC.text.contains(' ') ||
        _percentageTC.text.contains('-')) {
      isPercentageValid = false;
      _errorMsg = 'Please provide a valid percentage';
    } else {
      isPercentageValid = true;
    }
    setState(() {
      //_isCodeValid = isCodeValid;
      _isPercentageValid = isPercentageValid;
    });

    if (isPercentageValid) {
      isValid = true;
    }
    return isValid;
  }

  @override
  void dispose() {
    super.dispose();
    _codeTC.dispose();
    _percentageTC.dispose();
    _codeFN.dispose();
    _percentageFN.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.flag == 2) {
      setState(() {
        _voucher = widget.voucher;
        _percentageTC.text = _voucher.percentage.toString();
        _codeTC.text = _voucher.code;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataServices>(builder: (context, dataServices, child) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Padding(
            padding: const EdgeInsets.only(right: 60.0),
            child: Center(
              child: Text(widget.flag == 1 ? 'ADD VOUCHER' : 'EDIT VOUCHER'),
            ),
          ),
        ),
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    /*SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ProfileCustomTF(
                        title: 'Voucher Code',
                        controller: _codeTC,
                        focusNode: _codeFN,
                        inputType: TextInputType.text,
                        inputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.characters,
                        isValidValue: _isCodeValid,
                        onChanged: (String newValue) {},
                        onSubmitted: (String newValue) {},
                        hint: '',
                        isEnabled: true,
                      ),
                    ),*/
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ProfileCustomTF(
                        title: 'Amount',
                        controller: _percentageTC,
                        focusNode: _percentageFN,
                        inputType: TextInputType.number,
                        inputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.characters,
                        isValidValue: _isPercentageValid,
                        onChanged: (String newValue) {},
                        onSubmitted: (String newValue) {},
                        hint: '',
                        isEnabled: true,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  bool isValid = _validateForm();
                  if (isValid) {
                    Voucher voucher = Voucher(
                        id: _voucher != null ? _voucher.id : 0,
                        code: '',
                        percentage: int.parse(_percentageTC.text));

                    ProgressDialog dialog = new ProgressDialog(context);
                    dialog.style(message: 'Please wait...');
                    await dialog.show();
                    ResponseModel response = await NetworkServices.shared
                        .addOrEditVoucher(voucher: voucher, context: context);
                    await dialog.hide();
                    if (response.code == 1) {
                      Navigator.pop(context);
                    } else {
                      _showSnackBar(response.message);
                    }
                  } else {
                    _showSnackBar(_errorMsg);
                  }
                },
                child: Container(
                  height: 40,
                  color: kPrimaryColor,
                  child: Center(
                    child: Text(
                      widget.flag == 1 ? 'SAVE' : 'UPDATE',
                      style: kTextStyle.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
