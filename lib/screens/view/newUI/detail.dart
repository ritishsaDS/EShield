import 'dart:convert';
import 'dart:math';
import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:dio/dio.dart';
import 'package:ez/screens/view/models/getServiceDetails_modal.dart';
import 'package:ez/screens/view/models/likeService_modal.dart';
import 'package:ez/screens/view/models/unLikeService_modal.dart';
import 'package:ez/screens/view/newUI/checkoutService.dart';
import 'package:ez/screens/view/newUI/viewImages.dart';
import 'package:ez/screens/view/newUI/wishList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ez/constant/global.dart';
import 'package:ez/constant/sizeconfig.dart';
import 'package:ez/screens/view/newUI/ratingService.dart';
import 'package:intl/intl.dart';
import 'package:place_picker/entities/location_result.dart';
import 'package:place_picker/widgets/place_picker.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class DetailScreen extends StatefulWidget {
  String resId;

  DetailScreen({
    this.resId,
  });
  @override
  _OrderSuccessWidgetState createState() => _OrderSuccessWidgetState();
}

class _OrderSuccessWidgetState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  Position currentLocation;
  ScrollController _scrollController;
  bool fixedScroll;
  String selectedType = '';
  String selectedTypePrice = '';
  String selectedTypeSize = '';
  TextEditingController addressController = TextEditingController();

  bool tab1 = true;
  bool tab2 = false;
  bool tab3 = false;

  String _dateValue = '';
  String _timeValue = '';
  String _pickedLocation = '';
  bool one = false;
  bool two = false;
  bool three = false;
  bool four = false;
  bool isLoading = false;
  final dio = new Dio();

  Future _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: DateTime.now().subtract(Duration(days: 1)),
        lastDate: new DateTime(2022),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.light().copyWith(
                primaryColor: Colors.black, //Head background
                accentColor: Colors.black,
                colorScheme:
                    ColorScheme.light(primary: const Color(0xFF619aa5)),
                buttonTheme:
                    ButtonThemeData(textTheme: ButtonTextTheme.accent)),
            child: child,
          );
        });
    if (picked != null)
      setState(() {
        String yourDate = picked.toString();
        _dateValue = convertDateTimeDisplay(yourDate);
        print(_dateValue);
      });
  }

  String convertDateTimeDisplay(String date) {
    final DateFormat displayFormater = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    final DateFormat serverFormater = DateFormat('yyyy-MM-dd');
    final DateTime displayDate = displayFormater.parse(date);
    final String formatted = serverFormater.format(displayDate);
    return formatted;
  }

  //Razorpay//>>>>>>>>>>>>>>>>

  String orderid = '';

  @override
  void initState() {
    _getProductDetails();
    _scrollController = ScrollController();

    super.initState();
  }

  GetServiceDetailsModal restaurants;

  refresh() {
    _getProductDetails();
  }

  _getProductDetails() async {
    var uri = Uri.parse('${baseUrl()}/get_res_details');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields['res_id'] = widget.resId;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);

    if (mounted) {
      setState(() {
        restaurants = GetServiceDetailsModal.fromJson(userData);

        // totalPrice = restaurants.product.productPrice;
      });
    }

    print(responseData);
  }

  Future getUserCurrentLocation() async {
    await Geolocator().getCurrentPosition().then((position) {
      if (mounted)
        setState(() {
          currentLocation = position;
        });
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          restaurants == null
              ? Center(child: CupertinoActivityIndicator())
              : _projectInfo(),
          // isLoading == true
          //     ? Center(child: CupertinoActivityIndicator())
          //     : Container()
        ],
      ),
    );
  }

  Widget _projectInfo() {
    return NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, value) {
          return [
            SliverAppBar(
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(70),
                      bottomRight: Radius.circular(70))),
              backgroundColor: const Color(0xFF619aa5),
              expandedHeight: 400,
              elevation: 0,
              floating: true,
              pinned: true,
              automaticallyImplyLeading: false,
              iconTheme: IconThemeData(
                color: Colors.black, //change your color here
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: _poster2(context),
              ),
              leading: Padding(
                padding: const EdgeInsets.all(12),
                child: RawMaterialButton(
                  shape: CircleBorder(),
                  padding: const EdgeInsets.all(0),
                  fillColor: Colors.white54,
                  splashColor: Colors.grey[400],
                  child: Icon(
                    Icons.arrow_back,
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              actions: [
                Container(
                  width: 40,
                  child: likedService.contains(restaurants.restaurant.resId)
                      ? Padding(
                          padding: const EdgeInsets.all(4),
                          child: RawMaterialButton(
                            shape: CircleBorder(),
                            padding: const EdgeInsets.all(0),
                            fillColor: Colors.white54,
                            splashColor: Colors.grey[400],
                            child: Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () {
                              unLikeServiceFunction(
                                  restaurants.restaurant.resId, userID);
                            },
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(4),
                          child: RawMaterialButton(
                            shape: CircleBorder(),
                            padding: const EdgeInsets.all(0),
                            fillColor: Colors.white54,
                            splashColor: Colors.grey[400],
                            child: Icon(
                              Icons.favorite_border,
                              size: 20,
                            ),
                            onPressed: () {
                              likeServiceFunction(
                                  restaurants.restaurant.resId, userID);
                            },
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: RawMaterialButton(
                    shape: CircleBorder(),
                    padding: const EdgeInsets.all(0),
                    fillColor: Colors.white54,
                    splashColor: Colors.grey[400],
                    child: Icon(
                      Icons.fullscreen,
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewImages(
                                  images: restaurants.restaurant.allImage,
                                  number: 0,
                                )),
                      );
                    },
                  ),
                ),
              ],
            ),
            // flexibleSpace: _poster2(context)),
          ];
        },
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: SizeConfig.screenWidth,
                child: Image.asset(
                  "assets/images/img6.jpg",
                  fit: BoxFit.cover,
                ),
              ),
              Container(height: 10),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => ReviewService(
                          resReview: restaurants.review,
                          restID: restaurants.restaurant.resId,
                          restName: restaurants.restaurant.resName,
                          restDesc: restaurants.restaurant.resDesc,
                          resNameU: restaurants.restaurant.resNameU,
                          resWebsite: restaurants.restaurant.resWebsite,
                          resPhone: restaurants.restaurant.resPhone,
                          resAddress: restaurants.restaurant.resAddress,
                          restRatings: restaurants.restaurant.resRatings,
                          images: restaurants.restaurant.allImage,
                          refresh: refresh),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        "Ratings",
                        style: TextStyle(
                          color: appColorBlack,
                          fontSize: 17,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: RatingBar.builder(
                        initialRating: restaurants.restaurant.resRatings !=
                                    null &&
                                restaurants.restaurant.resRatings.length > 0
                            ? double.parse(restaurants.restaurant.resRatings)
                            : 0.0,
                        minRating: 0,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 20,
                        ignoreGestures: true,
                        unratedColor: Colors.grey,
                        itemBuilder: (context, _) =>
                            Icon(Icons.star, color: appColorOrange),
                        onRatingUpdate: (rating) {
                          print(rating);
                        },
                      ),
                    ),
                    Container(height: 5),
                  ],
                ),
              ),
              Container(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 0, right: 0),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            tab1 = true;
                            tab2 = false;
                            tab3 = false;
                          });
                        },
                        child: Text(
                          "Description",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: tab1 == true ? appColorBlack : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            tab1 = false;
                            tab2 = true;
                            tab3 = false;
                          });
                        },
                        child: Text(
                          "Review",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: tab2 == true ? appColorBlack : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            tab1 = false;
                            tab2 = false;
                            tab3 = true;
                          });
                        },
                        child: Text(
                          "Instruction",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: tab3 == true ? appColorBlack : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 10),
              Container(
                color: backgroundgrey,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 20, bottom: 30, left: 30, right: 30),
                  child: tab1 == true
                      ? Text(
                          restaurants.restaurant.resDesc,
                          style: TextStyle(
                            color: appColorBlack,
                          ),
                        )
                      : tab2 == true
                          ? reviewWidget(restaurants.review)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 0),
                                  child: Text(
                                    restaurants.restaurant.hours,
                                    style: TextStyle(
                                        color: appColorBlack,
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(height: 5),
                                Padding(
                                  padding: const EdgeInsets.only(left: 0),
                                  child: Text(
                                    restaurants.restaurant.experts,
                                    style: TextStyle(
                                        color: appColorBlack,
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
              Container(height: 15),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  "Area",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: appColorBlack,
                    fontWeight: FontWeight.normal,
                    fontSize: 17,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: GridView.builder(
                  shrinkWrap: true,
                  //physics: NeverScrollableScrollPhysics(),
                  primary: false,
                  padding: EdgeInsets.all(5),
                  itemCount: restaurants.restaurant.type.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 300 / 200,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(15),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedType =
                                restaurants.restaurant.type[index].type;
                            selectedTypePrice =
                                restaurants.restaurant.type[index].price;
                            selectedTypeSize =
                                restaurants.restaurant.type[index].typeName;
                          });
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: selectedType ==
                                        restaurants.restaurant.type[index].type
                                    ? Colors.grey[400]
                                    : appColorWhite,
                                border: Border.all(width: 0.5),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            child: Center(
                                child: Text(
                              restaurants.restaurant.type[index].typeName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ))),
                      ),
                    );
                  },
                ),
              ),
              Container(height: 10),
              Container(
                color: backgroundgrey,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Container(
                    color: appColorWhite,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(width: 40),
                          Padding(
                            padding: const EdgeInsets.only(right: 0),
                            child: Column(
                              children: [
                                Text(
                                  'One Fair Price :',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  'Inclusive of all taxes \n and a good discount',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                )
                              ],
                            ),
                          ),
                          Container(width: 15),
                          Text(
                            "\$ " + selectedTypePrice,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                                fontFamily: 'OpenSansBold'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Book  your Service',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
                child: InkWell(
                  onTap: () {
                    _selectDate();
                  },
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Icon(Icons.date_range),
                        ),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: new Text(
                            _dateValue.length > 0 ? _dateValue : "Pick a date",
                            textAlign: TextAlign.start,
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 10),
                child: InkWell(
                  onTap: () {
                    openBottmSheet(context);
                  },
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Icon(Icons.timer_sharp),
                        ),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: new Text(
                            _timeValue.length > 0
                                ? _timeValue
                                : "choose a time",
                            textAlign: TextAlign.start,
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 10),
                child: InkWell(
                  onTap: () {
                    _getLocation();
                  },
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Icon(Icons.location_on_outlined),
                        ),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: new Text(
                            _pickedLocation.length > 0
                                ? _pickedLocation
                                : "find your location",
                            maxLines: 2,
                            textAlign: TextAlign.start,
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 10),
                child: TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                      hintText: "Enter Address",
                      hintStyle:
                          TextStyle(color: Colors.grey[500], fontSize: 13),
                      alignLabelWithHint: true,
                      fillColor: appColorWhite,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        color: appColorBlack,
                      )),

                  // scrollPadding: EdgeInsets.all(20.0),
                  // keyboardType: TextInputType.multiline,
                  // maxLines: 99999,
                  style: TextStyle(color: appColorBlack, fontSize: 15),
                  autofocus: false,
                ),
              ),
              Container(height: 30),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: InkWell(
                  onTap: () {
                    closeKeyboard();
                    if (_dateValue.isNotEmpty &&
                        _timeValue.isNotEmpty &&
                        _pickedLocation.isNotEmpty &&
                        selectedTypePrice.isNotEmpty) {
                      // checkOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CheckOutService(
                                restaurants: restaurants,
                                selectedTypePrice: selectedTypePrice,
                                selectedTypeSize: selectedTypeSize,
                                pickedLocation:
                                    addressController.text.isNotEmpty
                                        ? addressController.text.toString() +
                                            "," +
                                            _pickedLocation
                                        : _pickedLocation,
                                dateValue: _dateValue,
                                timeValue: _timeValue)),
                      );
                    } else {
                      if (_dateValue.isEmpty) {
                        Toast.show("Select Date", context,
                            duration: Toast.LENGTH_SHORT,
                            gravity: Toast.BOTTOM);
                      } else if (_timeValue.isEmpty) {
                        Toast.show("Select Time", context,
                            duration: Toast.LENGTH_SHORT,
                            gravity: Toast.BOTTOM);
                      } else if (_pickedLocation.isEmpty) {
                        Toast.show("Select Location", context,
                            duration: Toast.LENGTH_SHORT,
                            gravity: Toast.BOTTOM);
                      } else if (selectedTypePrice.isEmpty) {
                        Toast.show("Select Size", context,
                            duration: Toast.LENGTH_SHORT,
                            gravity: Toast.BOTTOM);
                      }
                    }
                  },
                  child: SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: new LinearGradient(
                                colors: [
                                  const Color(0xFF4b6b92),
                                  const Color(0xFF619aa5),
                                ],
                                begin: const FractionalOffset(0.0, 0.0),
                                end: const FractionalOffset(1.0, 0.0),
                                stops: [0.0, 1.0],
                                tileMode: TileMode.clamp),
                            border: Border.all(color: Colors.grey[400]),
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                        height: 50.0,
                        // ignore: deprecated_member_use
                        child: Center(
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "CHECKOUT",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: appColorWhite,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ),
              ),
              Container(height: 15),
              Container(
                width: SizeConfig.screenWidth,
                child: Image.asset(
                  "assets/images/img2.jpg",
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ));
  }

  Widget _poster2(BuildContext context) {
    Widget carousel = restaurants.restaurant.allImage == null
        ? Center(
            child: SpinKitCubeGrid(
              color: Colors.white,
            ),
          )
        : Stack(
            children: <Widget>[
              Carousel(
                images: restaurants.restaurant.allImage.map((it) {
                  return ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30)),
                    child: CachedNetworkImage(
                      imageUrl: it,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Center(
                        child: Container(
                          height: 100,
                          width: 100,
                          // margin: EdgeInsets.all(70.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                appColorGreen),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
                showIndicator: true,
                dotBgColor: Colors.transparent,
                borderRadius: false,
                autoplay: false,
                dotSize: 5.0,
                dotSpacing: 15.0,
              ),
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30)),
                  ),
                  margin: EdgeInsets.zero,
                  color: Colors.black45.withOpacity(0.1),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50, left: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurants.restaurant.resName,
                        style: TextStyle(
                            fontSize: 25,
                            color: appColorWhite,
                            fontWeight: FontWeight.bold),
                      ),
                      Container(
                        height: 10,
                      ),
                      Container(
                        height: 4,
                        width: 100,
                        decoration: BoxDecoration(
                            color: appColorWhite,
                            borderRadius:
                                BorderRadius.all(Radius.circular(30))),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );

    return SizedBox(width: SizeConfig.screenWidth, child: carousel);
  }

  Widget reviewWidget(List<Review> model) {
    return model.length > 0
        ? ListView.builder(
            padding: const EdgeInsets.all(0),
            shrinkWrap: true,
            itemCount: model.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return model[index].revUserData == null
                  ? Container()
                  : InkWell(
                      onTap: () {},
                      child: Center(
                        child: Container(
                          child: SizedBox(
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Card(
                                        elevation: 4.0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50.0)),
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(50.0)),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50.0),
                                            child: CachedNetworkImage(
                                              imageUrl: model[index]
                                                  .revUserData
                                                  .profilePic,
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  Center(
                                                child: Container(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.0,
                                                    valueColor:
                                                        new AlwaysStoppedAnimation<
                                                                Color>(
                                                            appColorGreen),
                                                  ),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(width: 10.0),
                                      Flexible(
                                        fit: FlexFit.loose,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(height: 10.0),
                                            Text(
                                              model[index].revUserData.username,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Container(height: 5),
                                            RatingBar.builder(
                                              initialRating: double.parse(
                                                  model[index].revStars),
                                              minRating: 0,
                                              direction: Axis.horizontal,
                                              allowHalfRating: true,
                                              itemCount: 5,
                                              itemSize: 15,
                                              ignoreGestures: true,
                                              unratedColor: Colors.grey,
                                              itemBuilder: (context, _) => Icon(
                                                Icons.star,
                                                color: Colors.orange,
                                              ),
                                              onRatingUpdate: (rating) {
                                                print(rating);
                                              },
                                            ),
                                            Container(height: 5),
                                            Text(
                                              model[index].revText,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.clip,
                                            ),
                                            // Text(
                                            //   dateformate,
                                            //   style: TextStyle(fontSize: 12),
                                            // ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Container(
                                      height: 0.8,
                                      color: Colors.grey[600],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ));
            })
        : Text("No reviews found.");
  }

  openBottmSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState1) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  height: SizeConfig.screenHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                    color: appColorWhite,
                  ),
                  child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                      )),
                      margin: EdgeInsets.zero,
                      //color: Colors.black45.withOpacity(0.6),
                      child: Column(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15.0),
                                topRight: Radius.circular(15.0),
                              ),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15, top: 15, bottom: 10),
                                  child: Text(
                                    "Time Slot:",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.normal,
                                      //color: Colors.purple
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        icon: Icon(Icons.close)),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: 1,
                            color: Colors.grey,
                          ),
                          Container(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 20,
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _timeValue = "8AM - 12PM";
                                      one = true;
                                      two = false;
                                      three = false;
                                      four = false;
                                    });
                                    setState1(() {});
                                  },
                                  child: Container(
                                    height: 45,
                                    decoration: BoxDecoration(
                                        color: one
                                            ? appColorBlack
                                            : Colors.grey[300],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30))),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 25, right: 25),
                                      child: Center(
                                        child: Text(
                                          "8AM - 12PM",
                                          style: TextStyle(
                                              color: one
                                                  ? appColorWhite
                                                  : Colors.grey[800],
                                              fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 15,
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _timeValue = "12PM - 3PM";
                                      one = false;
                                      two = true;
                                      three = false;
                                      four = false;
                                    });
                                    setState1(() {});
                                  },
                                  child: Container(
                                    height: 45,
                                    decoration: BoxDecoration(
                                        color: two
                                            ? appColorBlack
                                            : Colors.grey[300],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30))),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 25, right: 25),
                                      child: Center(
                                        child: Text(
                                          "12PM - 3PM",
                                          style: TextStyle(
                                              color: two
                                                  ? appColorWhite
                                                  : Colors.grey[800],
                                              fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 20,
                              ),
                            ],
                          ),
                          Container(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 20,
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _timeValue = "3PM - 6PM";
                                      one = false;
                                      two = false;
                                      three = true;
                                      four = false;
                                    });
                                    setState1(() {});
                                  },
                                  child: Container(
                                    height: 45,
                                    decoration: BoxDecoration(
                                        color: three
                                            ? appColorBlack
                                            : Colors.grey[300],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30))),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 25, right: 25),
                                      child: Center(
                                        child: Text(
                                          "3PM - 6PM",
                                          style: TextStyle(
                                              color: three
                                                  ? appColorWhite
                                                  : Colors.grey[800],
                                              fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 15,
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _timeValue = "6PM - 9PM";
                                      one = false;
                                      two = false;
                                      three = false;
                                      four = true;
                                    });
                                    setState1(() {});
                                  },
                                  child: Container(
                                    height: 45,
                                    decoration: BoxDecoration(
                                        color: four
                                            ? appColorBlack
                                            : Colors.grey[300],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30))),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 25, right: 25),
                                      child: Center(
                                        child: Text(
                                          "6PM - 9PM",
                                          style: TextStyle(
                                              color: four
                                                  ? appColorWhite
                                                  : Colors.grey[800],
                                              fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 20,
                              ),
                            ],
                          ),
                        ],
                      )),
                );
              },
            );
          });
        });
  }

  _getLocation() async {
    LocationResult result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PlacePicker(
              "AIzaSyCqQW9tN814NYD_MdsLIb35HRY65hHomco",
            )));
    setState(() {
      _pickedLocation = result.formattedAddress.toString();
    });
  }

//   checkOut() {
//     generateOrderId("rzp_test_xM5O48R6soyM4v", "rXG0rFMU4Q4uGSLB9Oh8biMp",
//         int.parse(selectedTypePrice) * 100);

//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     if (_razorpay != null) _razorpay.clear();
//   }

//   Future<String> generateOrderId(String key, String secret, int amount) async {
//     setState(() {
//       isLoading = true;
//     });
//     var authn = 'Basic ' + base64Encode(utf8.encode('$key:$secret'));

//     var headers = {
//       'content-type': 'application/json',
//       'Authorization': authn,
//     };

//     var data =
//         '{ "amount": $amount, "currency": "INR", "receipt": "receipt#R1", "payment_capture": 1 }'; // as per my experience the receipt doesn't play any role in helping you generate a certain pattern in your Order ID!!

//     var res = await http.post('https://api.razorpay.com/v1/orders',
//         headers: headers, body: data);
//     //if (res.statusCode != 200) throw Exception('http.post error: statusCode= ${res.statusCode}');
//     print('ORDER ID response => ${res.body}');
//     orderid = json.decode(res.body)['id'].toString();
//     print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" + orderid);
//     if (orderid.length > 0) {
//       openCheckout();
//     } else {
//       setState(() {
//         isLoading = false;
//       });
//     }

//     return json.decode(res.body)['id'].toString();
//   }

//   //rzp_live_UMrVDdnJjTUhcc
// //rzp_test_rcbv2RXtgmOyTf
//   void openCheckout() async {
//     var options = {
//       'key': 'rzp_test_rcbv2RXtgmOyTf',
//       'amount': int.parse(selectedTypePrice) * 100,
//       'currency': 'INR',
//       'name': 'Ezshield',
//       'description': '',
//       // 'order_id': orderid,
//       'prefill': {'contact': userMobile, 'email': userEmail},
//       // 'external': {
//       //   'wallets': ['paytm']
//       // }
//     };

//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       debugPrint(e);
//     }
//   }

//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     Toast.show("SUCCESS Order: " + response.paymentId, context,
//         duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);

//     bookApiCall(response.paymentId);

//     print(response.paymentId);
//   }

//   void _handlePaymentError(PaymentFailureResponse response) {
//     Toast.show("ERROR: " + response.code.toString() + " - " + response.message,
//         context,
//         duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);

//     print(response.code.toString() + " - " + response.message);
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     Toast.show("EXTERNAL_WALLET: " + response.walletName, context,
//         duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);

//     print(response.walletName);
//   }

//   bookApiCall(String txnId) async {
//     setState(() {
//       isLoading = true;
//     });
//     var uri = Uri.parse(baseUrl() + "booking");

//     var request = new http.MultipartRequest("POST", uri);

//     Map<String, String> headers = {
//       "Accept": "application/json",
//     };
//     request.headers.addAll(headers);

//     request.fields['res_id'] = restaurants.restaurant.resId;
//     request.fields['user_id'] = userID;
//     request.fields['date'] = _dateValue;
//     request.fields['slot'] = _timeValue;
//     request.fields['size'] = selectedTypeSize;
//     request.fields['address'] =
//         addressController.text.toString() + "," + _pickedLocation;

// // send
//     var response = await request.send();

//     print(response.statusCode);

//     String responseData = await response.stream
//         .transform(utf8.decoder)
//         .join(); // decodes on response data using UTF8.decoder
//     Map data = json.decode(responseData);
//     print(data);
//     print(data["booking"]["booking_id"]);

//     setState(() {
//       isLoading = false;

//       if (data["response_code"] == "1") {
//         successPaymentApiCall(txnId, data["booking"]["booking_id"].toString());
//       } else {
//         isLoading = false;
//         bookDialog(
//           context,
//           "something went wrong. Try again",
//           button: true,
//         );
//       }
//     });
//   }

//   successPaymentApiCall(txnId, String bookingId) async {
//     setState(() {
//       isLoading = true;
//     });

//     var uri = Uri.parse(baseUrl() + "payment_success");

//     var request = new http.MultipartRequest("POST", uri);

//     Map<String, String> headers = {
//       "Accept": "application/json",
//     };
//     request.headers.addAll(headers);

//     request.fields['txn_id'] = txnId;
//     request.fields['amount'] = selectedTypePrice;
//     request.fields['booking_id'] = bookingId;

// // send
//     var response = await request.send();

//     print(response.statusCode);

//     String responseData = await response.stream
//         .transform(utf8.decoder)
//         .join(); // decodes on response data using UTF8.decoder
//     Map data = json.decode(responseData);
//     print(data);

//     setState(() {
//       isLoading = false;

//       if (data["response_code"] == "1") {
//         Toast.show("Payment Success", context,
//             duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (context) => BookingSccess(
//                   image: restaurants.restaurant.allImage[0],
//                   name: restaurants.restaurant.resName,
//                   location: _pickedLocation,
//                   date: _dateValue,
//                   time: _timeValue)),
//         );
//       } else {
//         setState(() {
//           isLoading = false;
//           Toast.show("something went wrong. Try again", context,
//               duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
//         });
//       }
//     });
//   }

  likeServiceFunction(String resId, String userID) async {
    LikeServiceModal likeServiceModal;

    var uri = Uri.parse('${baseUrl()}/likeRes');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields.addAll({
      'res_id': resId,
      'user_id': userID,
    });

    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);

    likeServiceModal = LikeServiceModal.fromJson(userData);

    if (likeServiceModal.responseCode == "1") {
      setState(() {
        likedService.add(restaurants.restaurant.resId);
      });
      Flushbar(
        backgroundColor: appColorWhite,
        messageText: Text(
          likeServiceModal.message,
          style: TextStyle(
            fontSize: SizeConfig.blockSizeHorizontal * 4,
            color: appColorBlack,
          ),
        ),

        duration: Duration(seconds: 3),
        // ignore: deprecated_member_use
        mainButton: FlatButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WishListScreen(
                  back: true,
                ),
              ),
            );
          },
          child: Text(
            "Go to wish list",
            style: TextStyle(color: appColorBlack),
          ),
        ),
        icon: Icon(
          Icons.favorite,
          color: appColorBlack,
          size: 25,
        ),
      )..show(context);
    } else {
      Flushbar(
        title: "Fail",
        message: likeServiceModal.message,
        duration: Duration(seconds: 3),
        icon: Icon(
          Icons.error,
          color: Colors.red,
        ),
      )..show(context);
    }
  }

  unLikeServiceFunction(String resId, String userID) async {
    UnlikeServiceModal unlikeServiceModal;

    var uri = Uri.parse('${baseUrl()}/unlike');
    var request = new http.MultipartRequest("POST", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields.addAll({
      'res_id': resId,
      'user_id': userID,
    });

    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);

    unlikeServiceModal = UnlikeServiceModal.fromJson(userData);

    if (unlikeServiceModal.status == '1') {
      setState(() {
        likedService.remove(restaurants.restaurant.resId);
      });
      Flushbar(
        backgroundColor: appColorWhite,
        messageText: Text(
          unlikeServiceModal.msg,
          style: TextStyle(
            fontSize: SizeConfig.blockSizeHorizontal * 4,
            color: appColorBlack,
          ),
        ),

        duration: Duration(seconds: 3),
        // ignore: deprecated_member_use
        mainButton: Container(),
        icon: Icon(
          Icons.favorite_border,
          color: appColorBlack,
          size: 25,
        ),
      )..show(context);
    } else {
      Flushbar(
        title: "Fail",
        message: unlikeServiceModal.msg,
        duration: Duration(seconds: 3),
        icon: Icon(
          Icons.error,
          color: Colors.red,
        ),
      )..show(context);
    }
  }
}
