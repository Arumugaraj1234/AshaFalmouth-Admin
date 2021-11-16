import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:miplate/data_services.dart';
import 'package:miplate/model/NetworkResponse.dart';
import 'package:miplate/model/holiday_model.dart';
import 'package:miplate/model/response_model.dart';
import 'package:miplate/network_services.dart';
import 'package:miplate/screens/DashboardScreen.dart';
import 'package:miplate/screens/coupon_form_screen.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class HolidayFormScreen extends StatefulWidget {
  final int flag;
  final Holiday holiday;

  HolidayFormScreen({this.flag, this.holiday});

  @override
  _HolidayFormScreenState createState() => _HolidayFormScreenState();
}

class _HolidayFormScreenState extends State<HolidayFormScreen> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showSnackBar(String text) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  TextEditingController _reasonTC = new TextEditingController();
  TextEditingController _fromDateTC = new TextEditingController();
  TextEditingController _toDateTC = new TextEditingController();
  FocusNode _reasonFN = new FocusNode();
  FocusNode _fromDateFN = new FocusNode();
  FocusNode _toDateFN = new FocusNode();
  bool _isReasonValid = true;
  bool _isFromDateValid = true;
  bool _isToDateValid = true;
  Holiday _holiday;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();

    if (widget.flag == 2) {
      setState(() {
        _holiday = widget.holiday;
        _fromDateTC.text = _holiday.fromDate;
        _toDateTC.text = _holiday.toDate;
        _reasonTC.text = _holiday.reason;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _reasonTC.dispose();
    _fromDateTC.dispose();
    _toDateTC.dispose();
    _reasonFN.dispose();
    _fromDateFN.dispose();
    _toDateFN.dispose();
  }

  String changeDateFormat(DateTime serverDate) {
    final DateFormat formatter = DateFormat('dd-MMM-yyyy');
    final String formatted = formatter.format(serverDate);
    return formatted;
  }

  bool validateForm() {
    bool isFromDateValid = false;
    bool isToDateValid = false;
    bool isReasonValid = false;

    _errorMsg = '';
    if (_reasonTC.text == '') {
      _errorMsg = "Reason for holiday can't be empty";
      isReasonValid = false;
    } else {
      isReasonValid = true;
    }

    if (_toDateTC.text == '') {
      _errorMsg = "Please provide the to date to continue";
      isToDateValid = false;
    } else {
      isToDateValid = true;
    }

    if (_fromDateTC.text == '') {
      _errorMsg = "Please provide the from date to continue";
      isFromDateValid = false;
    } else {
      isFromDateValid = true;
    }

    bool isValid = false;
    setState(() {
      _isFromDateValid = isFromDateValid;
      _isToDateValid = isToDateValid;
      _isReasonValid = isReasonValid;
    });

    if (isFromDateValid && isToDateValid && isReasonValid) {
      isValid = true;
    }

    return isValid;
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
              child: Text(widget.flag == 1 ? 'ADD HOLIDAY' : 'EDIT HOLIDAY'),
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
                      child: GestureDetector(
                        onTap: () async {
                          final DateTime picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2015, 8),
                              lastDate: DateTime(2101));
                          if (picked != null)
                            setState(() {
                              _fromDateTC.text = changeDateFormat(picked);
                            });
                          print('Hi');
                        },
                        child: AbsorbPointer(
                          child: ProfileCustomTF(
                            title: 'From Date',
                            controller: _fromDateTC,
                            focusNode: _fromDateFN,
                            inputType: TextInputType.text,
                            inputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            isValidValue: _isFromDateValid,
                            onChanged: (value) {},
                            onSubmitted: (value) {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                            },
                            hint: '',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: () async {
                          final DateTime picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2015, 8),
                              lastDate: DateTime(2101));
                          if (picked != null)
                            setState(() {
                              _toDateTC.text = changeDateFormat(picked);
                            });
                          print('Hi');
                        },
                        child: AbsorbPointer(
                          child: ProfileCustomTF(
                            title: 'To Date',
                            controller: _toDateTC,
                            focusNode: _toDateFN,
                            inputType: TextInputType.text,
                            inputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            isValidValue: _isToDateValid,
                            onChanged: (value) {},
                            onSubmitted: (value) {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                            },
                            hint: '',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ProfileCustomTF(
                        title: 'Reason',
                        controller: _reasonTC,
                        focusNode: _reasonFN,
                        inputType: TextInputType.text,
                        inputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.words,
                        isValidValue: _isReasonValid,
                        onChanged: (String newValue) {},
                        onSubmitted: (String newValue) {},
                        hint: '',
                        isEnabled: true,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  bool isValid = validateForm();
                  if (isValid) {
                    Holiday holiday = Holiday(
                        id: _holiday != null ? _holiday.id : 0,
                        fromDate: _fromDateTC.text,
                        toDate: _toDateTC.text,
                        reason: _reasonTC.text);

                    ProgressDialog dialog = new ProgressDialog(context);
                    dialog.style(message: 'Please wait...');
                    await dialog.show();
                    ResponseModel response = await NetworkServices.shared
                        .addOrEditHoliday(holiday: holiday, context: context);
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
