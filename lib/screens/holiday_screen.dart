import 'package:flutter/material.dart';
import 'package:miplate/data_services.dart';
import 'package:miplate/model/holiday_model.dart';
import 'package:miplate/model/response_model.dart';
import 'package:miplate/network_services.dart';
import 'package:miplate/screens/DashboardScreen.dart';
import 'package:miplate/screens/holiday_form_screen.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class HolidayScreen extends StatefulWidget {
  @override
  _HolidayScreenState createState() => _HolidayScreenState();
}

class _HolidayScreenState extends State<HolidayScreen> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showSnackBar(String text) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  @override
  void initState() {
    super.initState();
    _getAllHolidays();
  }

  _getAllHolidays() async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    ResponseModel response =
        await NetworkServices.shared.getAllHolidays(context: context);
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
              child: Text('Holidays'),
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
                      return HolidayFormScreen(
                        flag: 1,
                        holiday: null,
                      );
                    }),
                  );
                })
          ],
        ),
        body: Container(
            child: ListView(
          children: List.generate(dataServices.allHolidays.length, (index) {
            Holiday holiday = dataServices.allHolidays[index];
            return HolidayWidget(
              holiday: holiday,
              onEditPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return HolidayFormScreen(
                      flag: 2,
                      holiday: holiday,
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

class HolidayWidget extends StatelessWidget {
  final Holiday holiday;
  final Function onEditPressed;

  HolidayWidget({this.holiday, this.onEditPressed});

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
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text('From: '),
                                Text(
                                  holiday.fromDate,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Text('To: '),
                                Text(
                                  holiday.toDate,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text('Reason: '),
                                Text(
                                  holiday.reason,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          // Expanded(
                          //   child: Row(
                          //     children: [
                          //       Text('FOR: '),
                          //       Text(
                          //         coupon.forMedium(),
                          //         style: TextStyle(fontWeight: FontWeight.bold),
                          //       )
                          //     ],
                          //   ),
                          // )
                        ],
                      )
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
