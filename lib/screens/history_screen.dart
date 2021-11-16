import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_picker_view/flutter_picker_view.dart';
import 'package:intl/intl.dart';
import 'package:miplate/data_services.dart';
import 'package:miplate/model/base/Constants.dart';
import 'package:miplate/model/dish_detail_model.dart';
import 'package:miplate/model/order_details_model.dart';
import 'package:miplate/order_history_widget.dart';
import 'package:miplate/screens/DashboardScreen.dart';
import 'package:miplate/screens/bill_view_screen.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';

import 'order_info_screen.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  TextEditingController _fromDateTC = new TextEditingController();
  TextEditingController _endDateTC = new TextEditingController();
  TextEditingController _orderTypeTC = new TextEditingController();
  TextEditingController _paymentTypeTC = new TextEditingController();

  FocusNode _fromDateFN = new FocusNode();
  FocusNode _endDateFN = new FocusNode();
  FocusNode _orderTypeFN = new FocusNode();
  FocusNode _paymentTypeFN = new FocusNode();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  int _totalOrders = 0;
  double _totalSale = 0.0;
  int _orderType = 0;
  int _paymentType = 0;

  String changeDateFormat(DateTime serverDate) {
    final DateFormat formatter = DateFormat('dd-MMM-yyyy');
    final String formatted = formatter.format(serverDate);
    return formatted;
  }

  String changeDateFormata(String serverDate) {
    String reqDate = serverDate
        .replaceAll(RegExp('-'), '')
        .replaceAll(RegExp(':'), '')
        .replaceAll(RegExp('T'), '');
    String date = reqDate.split('.')[0];
    String dateWithT = date.substring(0, 8) + 'T' + date.substring(8);
    DateTime dateTime = DateTime.parse(dateWithT);
    String req =
        formatDate(dateTime, [MM, dd, ', ', yyyy, ', ', hh, ':', nn, am]);
    return req;
  }

  String changeDateFormatOne(String serverDate) {
    String reqDate = serverDate
        .replaceAll(RegExp('-'), '')
        .replaceAll(RegExp(':'), '')
        .replaceAll(RegExp('T'), '');
    String date = reqDate.split('.')[0];
    String dateWithT = date.substring(0, 8) + 'T' + date.substring(8);
    DateTime dateTime = DateTime.parse(dateWithT);
    String req = formatDate(dateTime, [yyyy, mm, dd, 'T', HH, nn, ss]);
    return req;
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _orderTypeTC.text = 'All';
      _paymentTypeTC.text = 'All';
      DateTime currentDate = DateTime.now();
      String cDateString = changeDateFormat(currentDate);
      _fromDateTC.text = cDateString;
      _endDateTC.text = cDateString;
    });
    _getOrdersHistory('', '');
  }

  @override
  void dispose() {
    super.dispose();
    _fromDateTC.dispose();
    _endDateTC.dispose();
    _orderTypeTC.dispose();
    _paymentTypeTC.dispose();
    _fromDateFN.dispose();
    _endDateFN.dispose();
    _orderTypeFN.dispose();
    _paymentTypeFN.dispose();
  }

  Map<String, dynamic> _$GetOrdersToJson() => <String, dynamic>{
        "start_date": _fromDateTC.text,
        "end_date": _endDateTC.text,
        "payment_type": _paymentType,
        "order_type": _orderType
      };

  _getOrdersHistory(String fromDate, String endDate) async {
    print('Hii fdjfds ');
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    String url = Constants.BASE_URL + '/GetOrders';
    var response =
        await http.post(url, body: json.encode(_$GetOrdersToJson()), headers: {
      HttpHeaders.contentTypeHeader: "application/json",
    });
    await dialog.hide();

    if (response != null && response.body.isNotEmpty) {
      String responseData = response.body;
      var jsonData = jsonDecode(responseData);
      print('Arumugaraj: $jsonData');
      int responseCode = jsonData['Code'];

      if (responseCode == 1) {
        int totalOrders = jsonData['TotalOrder'];
        double totalSales = jsonData['TotalSale'];

        setState(() {
          _totalOrders = totalOrders;
          _totalSale = totalSales;
        });

        List<OrderDetailsModel> orders = [];
        var orderDetails = jsonData['Data'];
        for (var order in orderDetails) {
          int orderId = order['order']['order_id'];

          int hotelId = order['order']['hotel_id'];
          int supplierId = order['order']['supplier_id'];

          int tableId = order['order']['table_id'];
          int orderType = order['order']['order_type'];

          String deliveryAddress = order['order']['delivery_address'];
          double deliveryLat = order['order']['delivery_lat'];
          double deliveryLon = order['order']['delivery_lon'];
          double baseAmount = order['order']['amount'];
          double discount = order['order']['discount'];
          double tax = order['order']['tax'];
          double totalAmount = order['order']['total'];
          int paymentType = order['order']['payment_type'];
          int paymentStatus = order['order']['payment_status'];
          int orderStatus = order['order']['order_status'];
          String orderStatusDesc = order['order_status'];
          String fromLocation = order['hotel_name'];
          String kotPath = order['kot_path'] ?? '';
          String billPath = order['bill_path'] ?? '';

          Color orderStatusColorCode;
          bool isCancelBtnToShow = true;
          switch (orderStatus) {
            case 1:
              //orderStatusDesc = 'Requested';
              orderStatusColorCode = Colors.blue;
              isCancelBtnToShow = true;
              break;
            case 2:
              //orderStatusDesc = 'Created';
              orderStatusColorCode = Colors.blue;
              isCancelBtnToShow = true;
              break;
            case 3:
              //orderStatusDesc = 'In kitchen';
              orderStatusColorCode = Colors.yellow;
              isCancelBtnToShow = true;
              break;
            case 4:
              //orderStatusDesc = 'On the way';
              orderStatusColorCode = Colors.orange;
              isCancelBtnToShow = true;
              break;
            case 5:
              //orderStatusDesc = 'Delivered';
              orderStatusColorCode = Colors.teal;
              isCancelBtnToShow = false;
              break;
            case 6:
              //orderStatusDesc = 'Completed';
              orderStatusColorCode = Colors.green;
              isCancelBtnToShow = false;
              break;
            case 7:
              //orderStatusDesc = 'Cancelled';
              orderStatusColorCode = Colors.red;
              isCancelBtnToShow = false;
              break;
            default:
              //orderStatusDesc = '';
              orderStatusColorCode = Colors.blue;
              isCancelBtnToShow = false;
              break;
          }

          var serverDate = order['order']['order_date'];
          print('Aaru$serverDate');
          String orderDate = changeDateFormata(serverDate);
          var orderedItems = order['items'];
          String orderTypeDesc = '';
          var dT = order['order']['delivery_time'];

          String deliveryTime = changeDateFormatOne(dT);

          switch (orderType) {
            case 1:
              orderTypeDesc = 'Table';
              break;
            case 2:
              orderTypeDesc = 'Collection';
              break;
            case 3:
              orderTypeDesc = 'Delivery';
              break;
            case 4:
              orderTypeDesc = 'Curbside';
              break;
            default:
              orderTypeDesc = '';
              break;
          }

          List<DishDetailModel> dishes = [];
          String dishesName = '';

          for (var item in orderedItems) {
            int dishId = item['dish_id'];
            String dishName = item['dish_name'];
            String dishIconLink = item['dish_icon'];
            double price = item['rate'];
            String description = item['description'];
            int dishTypeFlag = item['dish_type'];
            double qty = item['qty'];
            int quantity = qty.toInt();
            VegOrNonVeg dishType;
            if (dishTypeFlag == 1) {
              dishType = VegOrNonVeg.nonVeg;
            } else {
              dishType = VegOrNonVeg.veg;
            }
            String hint = dishName + dishName.toLowerCase();
            DishDetailModel dishModel = DishDetailModel(
                id: dishId,
                imageLink: dishIconLink,
                name: dishName,
                region: description,
                vegOrNonVegType: dishType,
                category: 'Category',
                price: price,
                count: quantity,
                dishSize: 'Half',
                isSelected: false,
                hintDetails: hint,
                isFavorite: false);

            dishes.add(dishModel);
            if (dishesName == '') {
              dishesName = dishName + ' x ' + quantity.toString();
            } else {
              dishesName =
                  dishesName + ', ' + dishName + ' x ' + quantity.toString();
            }
          }

          OrderDetailsModel oM = OrderDetailsModel(
              orderId: orderId,
              hotelId: hotelId,
              supplierId: supplierId,
              tableId: tableId,
              orderType: orderType,
              deliveryAddress: deliveryAddress,
              deliveryLatitude: deliveryLat,
              deliveryLongitude: deliveryLon,
              amount: baseAmount,
              discount: discount,
              tax: tax,
              totalAmount: totalAmount,
              paymentType: paymentType,
              paymentStatus: paymentStatus,
              orderStatus: orderStatus,
              orderDate: orderDate,
              dishes: dishes,
              dishesName: dishesName,
              orderTypeDesc: orderTypeDesc,
              orderStatusColorCode: orderStatusColorCode,
              orderStatusDesc: orderStatusDesc,
              isCancelButtonToShow: isCancelBtnToShow,
              fromLocation: fromLocation,
              initialDeliveryTime: deliveryTime,
              modifiedDeliveryTime: deliveryTime,
              kotPath: kotPath,
              billPath: billPath);

          orders.add(oM);
        }
        Provider.of<DataServices>(context, listen: false)
            .setHistoryOrders(orders);
      } else {
        _showSnackBar('No Orders found');
      }

      // ShowProgressDialogScreen.showLoading("Loading", false, context);
    } else {
      _showSnackBar('Something went wrong. Please try again later');
      print('xxx dsgkgjk fgjfgkj');
      // ShowProgressDialogScreen.showLoading("Please wait...", false, context);
    }
  }

  List<String> _paymentTypeOptions = <String>[
    'All',
    'Cash',
    'Credit Card/Debit Card',
    'Stripe'
  ];
  List<String> _orderTypeOptions = <String>[
    'All',
    'Collection',
    'Delivery',
    'Cancelled'
  ];

  void _onSelectPaymentTypeOption(String option) {
    if (option == 'Card Payment') {
      Provider.of<DataServices>(context, listen: false)
          .setHistoryOrdersFilter(type: 1, option: 2);
    } else if (option == 'Cash Payment') {
      Provider.of<DataServices>(context, listen: false)
          .setHistoryOrdersFilter(type: 1, option: 1);
    } else {
      Provider.of<DataServices>(context, listen: false)
          .setHistoryOrdersFilter(type: 1, option: 0);
    }
  }

  _onSelectOrderTypeOption(String option) {
    if (option == 'Collection') {
      Provider.of<DataServices>(context, listen: false)
          .setHistoryOrdersFilter(type: 2, option: 2);
    } else if (option == 'Delivery') {
      Provider.of<DataServices>(context, listen: false)
          .setHistoryOrdersFilter(type: 2, option: 3);
    } else {
      Provider.of<DataServices>(context, listen: false)
          .setHistoryOrdersFilter(type: 2, option: 0);
    }
  }

  void _showPicker({List<String> items, String title, int flag}) {
    PickerController pickerController =
        PickerController(count: 1, selectedItems: [0]);

    PickerViewPopup.showMode(PickerShowMode.BottomSheet,
        controller: pickerController,
        context: context,
        title: Text(
          title,
          style: kTextStyle,
        ),
        cancel: Text(
          'cancel',
          style: kTextStyle.copyWith(color: Colors.blue),
        ),
        onCancel: () {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('AlertDialogPicker.cancel')));
        },
        confirm: Text(
          'confirm',
          style: kTextStyle,
        ),
        onConfirm: (controller) async {
          List<int> selectedItems = [];
          selectedItems.add(controller.selectedRowAt(section: 0));
          //String selValue = items[controller.selectedRowAt(section: 0)];
          if (flag == 1) {
            //Order Type
            String selectedOrderType =
                _orderTypeOptions[controller.selectedRowAt(section: 0)];
            setState(() {
              _orderTypeTC.text = selectedOrderType;
            });
            if (selectedOrderType == 'All') {
              _orderType = 0;
            } else if (selectedOrderType == 'Collection') {
              _orderType = 2;
            } else if (selectedOrderType == 'Delivery') {
              _orderType = 3;
            } else if (selectedOrderType == 'Cancelled') {
              _orderType = 4;
            } else {
              _orderType = 0;
            }
          } else {
            //Payment Type
            String selectedPaymentType =
                _paymentTypeOptions[controller.selectedRowAt(section: 0)];
            setState(() {
              _paymentTypeTC.text = selectedPaymentType;
            });
            if (selectedPaymentType == 'Cash') {
              _paymentType = 1;
            } else if (selectedPaymentType == 'Credit Card/Debit Card') {
              _paymentType = 2;
            } else if (selectedPaymentType == 'Stripe') {
              _paymentType = 3;
            } else {
              _paymentType = 0;
            }
          }
        },
        onSelectRowChanged: (section, row) {
          String selValue = items[row];
          if (flag == 1) {
            //Order Type
            String selectedOrderType = _orderTypeOptions[row];
            setState(() {
              _orderTypeTC.text = selectedOrderType;
            });
            if (selectedOrderType == 'All') {
              _orderType = 0;
            } else if (selectedOrderType == 'Collection') {
              _orderType = 2;
            } else if (selectedOrderType == 'Delivery') {
              _orderType = 3;
            } else if (selectedOrderType == 'Cancelled') {
              _orderType = 4;
            } else {
              _orderType = 0;
            }
          } else {
            //Payment Type
            String selectedPaymentType = _paymentTypeOptions[row];
            setState(() {
              _paymentTypeTC.text = selectedPaymentType;
            });
            if (selectedPaymentType == 'Cash') {
              _paymentType = 1;
            } else if (selectedPaymentType == 'Credit Card/Debit Card') {
              _paymentType = 2;
            } else if (selectedPaymentType == 'Stripe') {
              _paymentType = 3;
            } else {
              _paymentType = 0;
            }
          }
        },
        builder: (context, popup) {
          return Container(
            height: 200,
            child: popup,
          );
        },
        itemExtent: 40,
        numberofRowsAtSection: (section) {
          return items.length;
        },
        itemBuilder: (section, row) {
          return Text(
            items[row],
            style: kTextStyle,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataServices>(builder: (context, dataServices, child) {
      return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Padding(
            padding: const EdgeInsets.only(right: 60.0),
            child: Center(
              child: Text('History'),
            ),
          ),
          /*actions: [
              PopupMenuButton(
                itemBuilder: (BuildContext context) {
                  return _paymentTypeOptions.map((String option) {
                    return PopupMenuItem(
                      child: Text(
                        option,
                        style: kTextStyle,
                      ),
                      value: option,
                    );
                  }).toList();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/images/filter.png"))),
                  ),
                ),
                onSelected: _onSelectPaymentTypeOption,
              ),
              PopupMenuButton(
                itemBuilder: (BuildContext context) {
                  return _orderTypeOptions.map((String option) {
                    return PopupMenuItem(
                      child: Text(
                        option,
                        style: kTextStyle,
                      ),
                      value: option,
                    );
                  }).toList();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/images/filter.png"))),
                  ),
                ),
                onSelected: _onSelectOrderTypeOption,
              )
            ],*/
        ),
        body: Container(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                height: 160.0,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
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
                                  isValidValue: true,
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
                            width: 20.0,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final DateTime picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2015, 8),
                                    lastDate: DateTime(2101));
                                if (picked != null)
                                  setState(() {
                                    _endDateTC.text = changeDateFormat(picked);
                                  });
                                print('Hi');
                              },
                              child: AbsorbPointer(
                                child: ProfileCustomTF(
                                  title: 'To Date',
                                  controller: _endDateTC,
                                  focusNode: _endDateFN,
                                  inputType: TextInputType.text,
                                  inputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.words,
                                  isValidValue: true,
                                  onChanged: (value) {},
                                  onSubmitted: (value) {
                                    FocusScope.of(context)
                                        .requestFocus(new FocusNode());
                                  },
                                  hint: '',
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _showPicker(
                                    items: _orderTypeOptions,
                                    title: 'Order Type',
                                    flag: 1);
                              },
                              child: AbsorbPointer(
                                child: ProfileCustomTF(
                                  title: 'Order Type',
                                  controller: _orderTypeTC,
                                  focusNode: _orderTypeFN,
                                  inputType: TextInputType.text,
                                  inputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.words,
                                  isValidValue: true,
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
                            width: 20.0,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                _showPicker(
                                    items: _paymentTypeOptions,
                                    title: 'Payment Type',
                                    flag: 2);
                              },
                              child: AbsorbPointer(
                                child: ProfileCustomTF(
                                  title: 'Payment Type',
                                  controller: _paymentTypeTC,
                                  focusNode: _paymentTypeFN,
                                  inputType: TextInputType.text,
                                  inputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.words,
                                  isValidValue: true,
                                  onChanged: (value) {},
                                  onSubmitted: (value) {
                                    FocusScope.of(context)
                                        .requestFocus(new FocusNode());
                                  },
                                  hint: '',
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      width: 150.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: MaterialButton(
                        onPressed: () {
                          _getOrdersHistory(_fromDateTC.text, _endDateTC.text);
                        },
                        child: Text(
                          'Apply',
                          style: kTextStyle.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                        child: Row(
                      children: [
                        Text(
                          'Total Sale: ',
                          style: kTextStyle.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.normal),
                        ),
                        Text(
                          '${String.fromCharCodes(new Runes('\u00A3'))}${_totalSale.toStringAsFixed(2)}',
                          style: kTextStyle.copyWith(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        )
                      ],
                    )),
                    Expanded(
                        child: Row(
                      children: [
                        Text(
                          'Total Orders: ',
                          style: kTextStyle.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.normal),
                        ),
                        Text(
                          '${_totalOrders}',
                          style: kTextStyle.copyWith(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        )
                      ],
                    ))
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Container(
                    child: ListView(
                      children: List.generate(
                          dataServices.historyFilteredOrders.length, (index) {
                        OrderDetailsModel order =
                            dataServices.historyFilteredOrders[index];
                        return OrderHistoryWidget(
                          orderDetails: order,
                          onCancelBtnPressed: () {},
                          onTrackBtnPressed: () {},
                          onOrderAgainPressed: () {},
                          onRateFoodBtnPressed: () {},
                          isButtonToShow: false,
                          onItemSelected: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return BillViewScreen(
                                order: order,
                                flag: 1,
                              );
                            }));

                            // Navigator.push(context,
                            //     MaterialPageRoute(builder: (context) {
                            //   return OrderInfoScreen(orderDetails: order);
                            // }));
                          },
                        );
                      }),
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
              color: Colors.black,
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
                  borderSide: BorderSide(color: Colors.teal),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                contentPadding: EdgeInsets.only(bottom: 10.0),
                hintText: hint,
                hintStyle: kTextStyle.copyWith(
                    color: Colors.grey.shade300, fontSize: 16.0)),
            style: kTextStyle.copyWith(color: Colors.teal, fontSize: 16.0),
            onChanged: onChanged,
          ),
        )
      ],
    );
  }
}

const kTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontFamily: 'Roboto Regular',
    fontWeight: FontWeight.w500);
