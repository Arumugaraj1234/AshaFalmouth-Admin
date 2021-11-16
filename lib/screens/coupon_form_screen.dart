import 'package:flutter/material.dart';
import 'package:miplate/data_services.dart';
import 'package:miplate/model/coupon_model.dart';
import 'package:miplate/model/response_model.dart';
import 'package:miplate/network_services.dart';
import 'package:miplate/screens/DashboardScreen.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

// const kTextStyle = TextStyle(
//     color: Colors.black,
//     fontSize: 16,
//     fontFamily: 'Roboto Regular',
//     fontWeight: FontWeight.w500);

class CouponFormScreen extends StatefulWidget {
  final int flag;
  final Coupon coupon;

  CouponFormScreen({this.flag, this.coupon});

  @override
  _CouponFormScreenState createState() => _CouponFormScreenState();
}

class _CouponFormScreenState extends State<CouponFormScreen> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showSnackBar(String text) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  Coupon _coupon;
  TextEditingController _codeTC = new TextEditingController();
  TextEditingController _percentageTC = new TextEditingController();
  bool _isCodeValid = true;
  FocusNode _codeFN = new FocusNode();
  FocusNode _percentageFN = new FocusNode();
  bool _isPercentageValid = true;
  int _couponFor = 1;
  int _activeStatus = 1;
  String _errorMsg = '';

  bool _validateForm() {
    bool isCodeValid = false;
    bool isPercentageValid = false;
    bool isValid = false;
    _errorMsg = '';

    if (_codeTC.text == '') {
      isCodeValid = false;
      _errorMsg = 'Please provide valid coupon code';
    } else {
      isCodeValid = true;
    }

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
      _isCodeValid = isCodeValid;
      _isPercentageValid = isPercentageValid;
    });

    if (isPercentageValid && isCodeValid) {
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
        _coupon = widget.coupon;
        _percentageTC.text = _coupon.percentage.toString();
        _codeTC.text = _coupon.code;
        _couponFor = _coupon.couponFor;
        _activeStatus = _coupon.status;
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
              child: Text(widget.flag == 1 ? 'ADD COUPON' : 'EDIT COUPON'),
            ),
          ),
        ),
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ProfileCustomTF(
                        title: 'Coupon Code',
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
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ProfileCustomTF(
                        title: 'Percentage',
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
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Coupon For',
                          style: kTextStyle.copyWith(
                              color: kPrimaryColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.normal)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Radio(
                                  value: 1,
                                  groupValue: _couponFor,
                                  onChanged: (value) {
                                    setState(() {
                                      _couponFor = value;
                                    });
                                  },
                                  fillColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.orange),
                                ),
                                Text('All')
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Radio(
                                  value: 2,
                                  groupValue: _couponFor,
                                  onChanged: (value) {
                                    setState(() {
                                      _couponFor = value;
                                    });
                                  },
                                  fillColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.orange),
                                ),
                                Text('Website')
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Radio(
                                  value: 3,
                                  groupValue: _couponFor,
                                  onChanged: (value) {
                                    setState(() {
                                      _couponFor = value;
                                    });
                                  },
                                  fillColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.orange),
                                ),
                                Text('IOS/Android')
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Active Status',
                          style: kTextStyle.copyWith(
                              color: kPrimaryColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.normal)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Radio(
                                  value: 1,
                                  groupValue: _activeStatus,
                                  onChanged: (value) {
                                    setState(() {
                                      _activeStatus = value;
                                    });
                                  },
                                  fillColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.orange),
                                ),
                                Text('Active')
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Radio(
                                  value: 0,
                                  groupValue: _activeStatus,
                                  onChanged: (value) {
                                    setState(() {
                                      _activeStatus = value;
                                    });
                                  },
                                  fillColor: MaterialStateColor.resolveWith(
                                      (states) => Colors.orange),
                                ),
                                Text('Inactive')
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  bool isValid = _validateForm();
                  if (isValid) {
                    Coupon coupon = Coupon(
                        id: _coupon != null ? _coupon.id : 0,
                        code: _codeTC.text,
                        percentage: int.parse(_percentageTC.text),
                        status: _activeStatus,
                        couponFor: _couponFor);

                    ProgressDialog dialog = new ProgressDialog(context);
                    dialog.style(message: 'Please wait...');
                    await dialog.show();
                    ResponseModel response = await NetworkServices.shared
                        .addOrEditCoupon(coupon: coupon, context: context);
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

class ProfileCustomTF extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final TextCapitalization textCapitalization;
  final bool isValidValue;
  final Function onChanged;
  final Function onSubmitted;
  final String hint;
  final bool isEnabled;

  ProfileCustomTF(
      {this.title,
      this.controller,
      this.focusNode,
      this.inputType,
      this.inputAction,
      this.textCapitalization,
      this.isValidValue,
      this.onChanged,
      this.onSubmitted,
      this.hint,
      this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: kTextStyle.copyWith(
              color: kPrimaryColor,
              fontSize: 16.0,
              fontWeight: FontWeight.normal),
        ),
        Container(
          height: 25.0,
          child: TextField(
            enabled: isEnabled,
            focusNode: focusNode,
            controller: controller,
            textInputAction: inputAction,
            textCapitalization: textCapitalization,
            onSubmitted: onSubmitted,
            keyboardType: inputType,
            cursorColor: Colors.black,
            decoration: InputDecoration(
                suffixIcon: isValidValue
                    ? null
                    : Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepOrangeAccent),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                contentPadding: EdgeInsets.only(bottom: 10.0),
                hintText: hint,
                hintStyle: kTextStyle.copyWith(
                    color: Colors.grey.shade300, fontSize: 18.0)),
            style: kTextStyle.copyWith(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.normal),
            onChanged: onChanged,
          ),
        )
      ],
    );
  }
}
