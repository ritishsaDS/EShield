import 'dart:convert';
import 'package:dotted_line/dotted_line.dart';
import 'package:ez/screens/view/models/getOrder_modal.dart';
import 'package:ez/screens/view/newUI/viewOrders.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ez/constant/global.dart';
import 'package:ez/constant/sizeconfig.dart';
import 'package:ez/screens/view/models/getBookingModel.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class BookingScreen extends StatefulWidget {
  bool back;
  BookingScreen({this.back});
  @override
  _BookingState createState() => _BookingState();
}

class _BookingState extends State<BookingScreen> {
  bool explorScreen = false;
  bool mapScreen = true;
  GetBookingModel model;
  GetOrdersModal getOrdersModal;

  @override
  void initState() {
    getOrderApi();
    getBookingAPICall();
    super.initState();
  }

  getOrderApi() async {
    try {
      Map<String, String> headers = {
        'content-type': 'application/x-www-form-urlencoded',
      };
      var map = new Map<String, dynamic>();
      map['user_id'] = userID;

      final response = await client.post(baseUrl() + "get_user_orders",
          headers: headers, body: map);

      Map userMap = jsonDecode(response.body);
      setState(() {
        getOrdersModal = GetOrdersModal.fromJson(userMap);
      });
    } on Exception {
      Toast.show("No Internet connection", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

      throw Exception('No Internet connection');
    }
  }

  getBookingAPICall() async {
    try {
      Map<String, String> headers = {
        'content-type': 'application/x-www-form-urlencoded',
      };
      var map = new Map<String, dynamic>();
      map['user_id'] = userID;

      final response = await client.post(baseUrl() + "get_booking_by_user",
          headers: headers, body: map);

      var dic = json.decode(response.body);
      Map userMap = jsonDecode(response.body);
      setState(() {
        model = GetBookingModel.fromJson(userMap);
      });
      print("GetBooking>>>>>>");
      print(dic);
    } on Exception {
      Toast.show("No Internet connection", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

      throw Exception('No Internet connection');
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Container(
        child: Scaffold(
          backgroundColor: appColorWhite,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'My Orders',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            leading: widget.back == true
                ? IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      if (widget.back == true) {
                        Navigator.pop(context);
                      }
                    },
                  )
                : Container(),
          ),
          body: Column(
            children: [
              Container(height: 15),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: DefaultTabController(
                    length: 2,
                    initialIndex: 0,
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 250,
                          height: 40,
                          decoration: new BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[300]),
                          child: Center(
                            child: TabBar(
                              labelColor: appColorWhite,
                              unselectedLabelColor: appColorBlack,
                              labelStyle: TextStyle(
                                  fontSize: 13.0,
                                  color: appColorWhite,
                                  fontWeight: FontWeight.bold),
                              unselectedLabelStyle: TextStyle(
                                  fontSize: 13.0,
                                  color: appColorBlack,
                                  fontWeight: FontWeight.bold),
                              indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color(0xFF619aa5)),
                              tabs: <Widget>[
                                Tab(
                                  text: 'Orders',
                                ),
                                Tab(
                                  text: 'Booking',
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: <Widget>[orderWidget(), bookingWidget()],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget orderWidget() {
    return getOrdersModal == null
        ? Center(
            child: CupertinoActivityIndicator(),
          )
        : getOrdersModal.responseCode != "0"
            ? ListView.builder(
                padding: EdgeInsets.only(bottom: 10, top: 10),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                //physics: const NeverScrollableScrollPhysics(),
                itemCount: getOrdersModal.orders.length,
                //scrollDirection: Axis.horizontal,
                itemBuilder: (
                  context,
                  int index,
                ) {
                  return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewOrders(
                                  orders: getOrdersModal.orders[index])),
                        );
                      },
                      child: Container(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 25, right: 25, top: 20),
                              child: Container(
                                height: 100,
                                width: double.infinity,
                                child: Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15, right: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              DateFormat('dd').format(
                                                  DateTime.parse(getOrdersModal
                                                      .orders[index].date)),
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 22),
                                            ),
                                            Text(
                                              DateFormat('MMM').format(
                                                  DateTime.parse(getOrdersModal
                                                      .orders[index].date)),
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 17),
                                            ),
                                          ],
                                        ),
                                        Container(width: 10),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20,
                                              bottom: 20,
                                              left: 10,
                                              right: 10),
                                          child: DottedLine(
                                            direction: Axis.vertical,
                                            lineLength: double.infinity,
                                            lineThickness: 1.0,
                                            dashLength: 4.0,
                                            dashColor: Colors.grey[600],
                                            dashRadius: 0.0,
                                            dashGapLength: 4.0,
                                            dashGapColor: Colors.transparent,
                                            dashGapRadius: 0.0,
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "OrderId: " +
                                                    getOrdersModal
                                                        .orders[index].orderId,
                                                maxLines: 1,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Container(height: 4),
                                              Text(
                                                "TxnId: " +
                                                    getOrdersModal
                                                        .orders[index].txnId,
                                                maxLines: 1,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ));
                },
              )
            : Center(
                child: Text(
                  "Don't have any Orders",
                  style: TextStyle(
                    color: appColorBlack,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
  }

  Widget bookingWidget() {
    return model == null
        ? Center(
            child: CupertinoActivityIndicator(),
          )
        : model.booking.length > 0
            ? ListView.builder(
                padding: EdgeInsets.only(bottom: 10, top: 10),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                //physics: const NeverScrollableScrollPhysics(),
                itemCount: model.booking.length,
                //scrollDirection: Axis.horizontal,
                itemBuilder: (
                  context,
                  int index,
                ) {
                  return InkWell(
                      onTap: () {},
                      child: Container(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 25, right: 25, top: 20),
                              child: Container(
                                height: 100,
                                width: double.infinity,
                                child: Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15, right: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              DateFormat('dd').format(
                                                  DateTime.parse(model
                                                      .booking[index].date)),
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 22),
                                            ),
                                            Text(
                                              DateFormat('MMM').format(
                                                  DateTime.parse(model
                                                      .booking[index].date)),
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 17),
                                            ),
                                          ],
                                        ),
                                        Container(width: 10),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20,
                                              bottom: 20,
                                              left: 10,
                                              right: 10),
                                          child: DottedLine(
                                            direction: Axis.vertical,
                                            lineLength: double.infinity,
                                            lineThickness: 1.0,
                                            dashLength: 4.0,
                                            dashColor: Colors.grey[600],
                                            dashRadius: 0.0,
                                            dashGapLength: 4.0,
                                            dashGapColor: Colors.transparent,
                                            dashGapRadius: 0.0,
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                model.booking[index].service
                                                    .resName,
                                                maxLines: 1,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Container(height: 4),
                                              Text(
                                                model.booking[index].date +
                                                    " --- " +
                                                    model.booking[index].slot,
                                                maxLines: 1,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12),
                                              ),
                                              Container(height: 4),
                                              Text(
                                                "Area - 1BHK",
                                                maxLines: 1,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ));
                },
              )
            : Center(
                child: Text(
                  "Don't have any Booking",
                  style: TextStyle(
                    color: appColorBlack,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
  }
}
