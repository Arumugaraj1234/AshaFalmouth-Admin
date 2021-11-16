import 'package:flutter/material.dart';
import 'package:miplate/data_services.dart';
import 'package:miplate/model/response_model.dart';
import 'package:miplate/model/voucher_model.dart';
import 'package:miplate/network_services.dart';
import 'package:miplate/screens/DashboardScreen.dart';
import 'package:miplate/screens/voucher_form_screen.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class VouchersScreen extends StatefulWidget {
  @override
  _VouchersScreenState createState() => _VouchersScreenState();
}

class _VouchersScreenState extends State<VouchersScreen> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showSnackBar(String text) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  @override
  void initState() {
    super.initState();
    _getAllVouchers();
  }

  _getAllVouchers() async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    ResponseModel response =
        await NetworkServices.shared.getAllVouchers(context: context);
    await dialog.hide();
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
              child: Text('Vouchers'),
            ),
          ),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.add_circle,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return VoucherFormScreen(
                        flag: 1,
                        voucher: null,
                      );
                    }),
                  );
                })
          ],
        ),
        body: Container(
            child: ListView(
          children: List.generate(dataServices.allVouchers.length, (index) {
            Voucher voucher = dataServices.allVouchers[index];
            return VoucherWidget(
              voucher: voucher,
              onEditPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return VoucherFormScreen(
                      flag: 2,
                      voucher: voucher,
                    );
                  }),
                );
              },
            );
          }),
        )),
      );
    });
  }
}

class VoucherWidget extends StatelessWidget {
  final Voucher voucher;
  final Function onEditPressed;

  VoucherWidget({this.voucher, this.onEditPressed});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text('CODE: '),
                            Text(
                              voucher.code,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Text('AMOUNT: '),
                            Text(
                              '${String.fromCharCodes(new Runes('\u00A3'))}${voucher.percentage.toStringAsFixed(2)} ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: IconButton(
                  icon: Icon(
                    Icons.edit,
                    size: 20,
                    color: kPrimaryColor,
                  ),
                  onPressed: onEditPressed,
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
