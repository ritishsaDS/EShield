import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ez/screens/view/models/allKey_modal.dart';
import 'package:ez/screens/view/models/allProduct_modal.dart';
import 'package:ez/screens/view/models/bannerModal.dart';
import 'package:ez/screens/view/models/categories_model.dart';
import 'package:ez/screens/view/models/getCart_modal.dart';
import 'package:ez/screens/view/models/getServiceWishList_modal.dart';
import 'package:ez/screens/view/models/getWishList_modal.dart';
import 'package:ez/screens/view/newUI/cart.dart';
import 'package:ez/screens/view/newUI/fb_sign_in.dart';
import 'package:ez/screens/view/newUI/google_sign_in.dart';
import 'package:ez/screens/view/newUI/notificationScreen.dart';
import 'package:ez/screens/view/newUI/productDetails.dart';
import 'package:ez/screens/view/newUI/searchProduct.dart';
import 'package:ez/screens/view/newUI/serviceScreenNew.dart';
import 'package:ez/screens/view/newUI/welcome2.dart';
import 'package:ez/screens/view/newUI/wishList.dart';
import 'package:fancy_drawer/fancy_drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ez/constant/global.dart';
import 'package:ez/constant/sizeconfig.dart';
import 'package:ez/screens/view/newUI/detail.dart';
import 'package:ez/screens/view/models/catModel.dart';
import 'package:ez/screens/view/newUI/viewCategory.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:ez/screens/view/newUI/newTabbar.dart';
import 'package:ez/screens/view/newUI/profile.dart';
import 'package:ez/share_preference/preferencesKey.dart';

class HomeScreen extends StatefulWidget {
  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  var orientation;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  CatModal sortingModel;
  BannerModal bannerModal;
  AllCateModel collectionModal;
  FancyDrawerController _controller;
  AllProductModal allProduct;
  GetCartModal getCartModal;
  GetWishListModal getWishListModal;
  Position currentLocation;
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  String _currentAddress;

  @override
  void initState() {
    _getAddressFromLatLng();
    getUserDataFromPrefs();
    _controller = FancyDrawerController(
        vsync: this, duration: Duration(milliseconds: 250))
      ..addListener(() {
        setState(() {});
      });

    super.initState();
  }

  Future getUserCurrentLocation() async {
    await Geolocator().getCurrentPosition().then((position) {
      if (mounted)
        setState(() {
          currentLocation = position;
        });
    });
  }

  _getAddressFromLatLng() async {
    getUserCurrentLocation().then((_) async {
      try {
        List<Placemark> p = await geolocator.placemarkFromCoordinates(
            currentLocation.latitude, currentLocation.longitude);

        Placemark place = p[0];

        setState(() {
          _currentAddress = "${place.locality}, ${place.country}";
          //"${place.name}, ${place.locality},${place.administrativeArea},${place.country}";
          print(_currentAddress);
        });
      } catch (e) {
        print(e);
      }
    });
  }

  getUserDataFromPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String userDataStr =
        preferences.getString(SharedPreferencesKey.LOGGED_IN_USERRDATA);
    Map<String, dynamic> userData = json.decode(userDataStr);
    print(userData);

    setState(() {
      userID = userData['user_id'];
    });
    _getAllKey();
    _getBanners();
    _getCollection();
    sortingApiCall();
    _getAllProduct();
    _getCart();
    _getWishList();
    _getServiceWishList();
  }

  _getAllKey() async {
    AllKeyModal allKeyModal;
    var uri = Uri.parse('${baseUrl()}/general_setting');
    var request = new http.MultipartRequest("GET", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    // request.fields['vendor_id'] = userID;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);

    if (mounted) {
      setState(() {
        allKeyModal = AllKeyModal.fromJson(userData);
        if (allKeyModal != null) {
          stripSecret = allKeyModal.setting.sSecretKey;
          stripPublic = allKeyModal.setting.sPublicKey;
          rozSecret = allKeyModal.setting.rSecretKey;
          rozPublic = allKeyModal.setting.rPublicKey;
        }
      });
    }

    print(responseData);
  }

  sortingApiCall() async {
    if (mounted)
      setState(() {
        isLoading = true;
      });

    try {
      Map<String, String> headers = {
        'content-type': 'application/x-www-form-urlencoded',
      };

      final response = await client.post(
        baseUrl() + "get_all_cat_nvip_sorting",
        headers: headers,
      );

      var dic = json.decode(response.body);
      Map userMap = jsonDecode(response.body);
      sortingModel = CatModal.fromJson(userMap);
      print("Sorting>>>>>>");
      print(dic);
      if (mounted)
        setState(() {
          isLoading = false;
        });
    } on Exception {
      if (mounted)
        setState(() {
          isLoading = false;
        });
      Toast.show("No Internet connection", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

      throw Exception('No Internet connection');
    }
  }

  _getBanners() async {
    var uri = Uri.parse('${baseUrl()}/get_all_banners');
    var request = new http.MultipartRequest("GET", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    // request.fields['vendor_id'] = userID;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);

    if (mounted) {
      setState(() {
        bannerModal = BannerModal.fromJson(userData);
      });
    }

    print(responseData);
  }

  _getCollection() async {
    var uri = Uri.parse('${baseUrl()}/get_all_cat');
    var request = new http.MultipartRequest("GET", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    // request.fields['vendor_id'] = userID;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);

    if (mounted) {
      setState(() {
        collectionModal = AllCateModel.fromJson(userData);
      });
    }

    print(responseData);
  }

  _getAllProduct() async {
    var uri = Uri.parse('${baseUrl()}/get_all_products');
    var request = new http.MultipartRequest("GET", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    // request.fields['vendor_id'] = userID;
    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);

    if (mounted) {
      setState(() {
        allProduct = AllProductModal.fromJson(userData);
      });
    }

    print(responseData);
  }

  _getCart() async {
    setState(() {
      isLoading = true;
    });

    var uri = Uri.parse('${baseUrl()}/get_cart_items');
    var request = new http.MultipartRequest("Post", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields.addAll({'user_id': userID});

    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    if (mounted) {
      setState(() {
        getCartModal = GetCartModal.fromJson(userData);
        isLoading = false;
      });
    }
  }

  _getWishList() async {
    var uri = Uri.parse('${baseUrl()}/wishlist');
    var request = new http.MultipartRequest("Post", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields.addAll({'user_id': userID});

    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    if (mounted) {
      setState(() {
        likedProduct.clear();
        getWishListModal = GetWishListModal.fromJson(userData);
        for (var i = 0; i < getWishListModal.wishlist.length; i++) {
          likedProduct.add(getWishListModal.wishlist[i].proId.toString());
        }
      });
    }
  }

  _getServiceWishList() async {
    GetServiceWishListModal getServiceWishListModal;
    var uri = Uri.parse('${baseUrl()}/service_wishlist');
    var request = new http.MultipartRequest("Post", uri);
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    request.headers.addAll(headers);
    request.fields.addAll({'user_id': userID});

    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.transform(utf8.decoder).join();
    var userData = json.decode(responseData);
    if (mounted) {
      setState(() {
        likedService.clear();
        getServiceWishListModal = GetServiceWishListModal.fromJson(userData);
        for (var i = 0; i < getServiceWishListModal.wishlist.length; i++) {
          likedService
              .add(getServiceWishListModal.wishlist[i].resId.toString());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return FancyDrawerWrapper(
      backgroundColor: Colors.white,
      controller: _controller,
      drawerItems: <Widget>[
        applogo(),
        Container(height: 30),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TabbarScreen()),
            );
          },
          child: Row(
            children: [
              Icon(
                Icons.home,
                color: Colors.black45,
              ),
              SizedBox(
                width: 10,
              ),
              Text("Home",
                  style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 5,
                      fontFamily: 'OpenSans',
                      fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => StoreScreenNew(back: true)),
            );
          },
          child: Row(
            children: [
              Icon(
                Icons.shopping_bag,
                color: Colors.black45,
              ),
              SizedBox(
                width: 10,
              ),
              Text("Services",
                  style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'OpenSans',
                      fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WishListScreen(back: true)),
            );
          },
          child: Row(
            children: [
              Icon(
                Icons.favorite,
                color: Colors.black45,
              ),
              SizedBox(
                width: 10,
              ),
              Text("Wish List",
                  style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'OpenSans',
                      fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Profile(back: true)),
            );
          },
          child: Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.black45,
              ),
              SizedBox(
                width: 10,
              ),
              Text("Profile",
                  style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'OpenSans',
                      fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationList()),
            );
          },
          child: Row(
            children: [
              Icon(
                Icons.notifications,
                color: Colors.black45,
              ),
              SizedBox(
                width: 10,
              ),
              Text("Notification",
                  style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'OpenSans',
                      fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            Alert(
              context: context,
              title: "Log out",
              desc: "Are you sure you want to log out?",
              style: AlertStyle(
                  isCloseButton: false,
                  descStyle: TextStyle(fontFamily: "MuliRegular", fontSize: 15),
                  titleStyle: TextStyle(fontFamily: "MuliRegular")),
              buttons: [
                DialogButton(
                  child: Text(
                    "OK",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: "MuliRegular"),
                  ),
                  onPressed: () async {
                    setState(() {
                      userID = '';

                      userEmail = '';
                      userMobile = '';
                      likedProduct = [];
                      likedService = [];
                    });
                    signOutGoogle();
                    signOutFacebook();
                    preferences
                        .remove(SharedPreferencesKey.LOGGED_IN_USERRDATA)
                        .then((_) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => Welcome2(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    });

                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  color: Color.fromRGBO(0, 179, 134, 1.0),
                ),
                DialogButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: "MuliRegular"),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  gradient: LinearGradient(colors: [
                    Color.fromRGBO(116, 116, 191, 1.0),
                    Color.fromRGBO(52, 138, 199, 1.0)
                  ]),
                ),
              ],
            ).show();
          },
          child: Row(
            children: [
              Icon(
                Icons.settings_power,
                color: Colors.red,
              ),
              SizedBox(
                width: 10,
              ),
              Text("Logout",
                  style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'OpenSans',
                      fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        Container(height: 100),
      ],
      child: Scaffold(
        backgroundColor: appColorWhite,
        appBar: AppBar(
          backgroundColor: appColorWhite,
          elevation: 0,
          title: Text(
            "",
            style: TextStyle(
                fontSize: 20,
                color: appColorBlack,
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: InkWell(
              onTap: () {
                _controller.toggle();
              },
              child: Image.asset("assets/images/icMenu.png")),
          actions: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey[100],
              child: IconButton(
                icon: Icon(
                  Icons.search,
                  color: appColorBlack,
                  size: 25,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchProduct()),
                  );
                },
              ),
            ),
            Container(width: 10),
            Stack(
              alignment: AlignmentDirectional.centerEnd,
              fit: StackFit.loose,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey[100],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GetCartScreeen(),
                          ),
                        );
                      },
                      child: Stack(
                        alignment: AlignmentDirectional.centerEnd,
                        fit: StackFit.loose,
                        children: <Widget>[
                          Icon(
                            Icons.shopping_cart_outlined,
                            color: appColorBlack,
                            size: 25,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                isLoading
                    ? Container(
                        height: 10,
                        width: 10,
                        child: Center(
                            child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                              new AlwaysStoppedAnimation<Color>(Colors.black),
                        )))
                    : getCartModal != null
                        ? Padding(
                            padding: EdgeInsets.only(top: 18, left: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Text(
                                    getCartModal.totalItems == null
                                        ? '0'
                                        : getCartModal.totalItems.toString(),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .merge(
                                          TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container()
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                'assets/images/logo.png',
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              servicesWidget(),
              Container(height: 10),
              collectionWidget(),
              Container(height: 20),
              _banner(context),
              Container(height: 20),
              Container(
                width: SizeConfig.screenWidth,
                child: Image.asset(
                  "assets/images/img6.jpg",
                  fit: BoxFit.cover,
                ),
              ),
              Container(height: 20),
              Container(
                width: SizeConfig.screenWidth,
                child: Image.asset(
                  "assets/images/img4.png",
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                width: SizeConfig.screenWidth,
                child: Image.asset(
                  "assets/images/img7.png",
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                width: SizeConfig.screenWidth,
                child: Image.asset(
                  "assets/images/img5.png",
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                width: SizeConfig.screenWidth,
                child: Image.asset(
                  "assets/images/img3.jpg",
                  fit: BoxFit.cover,
                ),
              ),
              bestSellerWidget(),
              Container(
                height: 10,
              ),
              Container(
                width: SizeConfig.screenWidth,
                child: Image.asset(
                  "assets/images/img1.jpg",
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                height: 10,
              ),
              Container(
                width: SizeConfig.screenWidth,
                child: Image.asset(
                  "assets/images/img2.jpg",
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget applogo() {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: 50,
        ),
        SizedBox(
          height: 10,
        ),
        Text(appName,
            style: TextStyle(
                color: appColorBlack,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
                fontStyle: FontStyle.italic)),
        SizedBox(
          height: 5,
        ),
        Text('Your Hygiene App',
            style: TextStyle(
              color: appColorBlack,
              fontSize: 12,
            )),
      ],
    );
  }

  Widget servicesWidget() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: appColorWhite,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, 1.0), //(x,y)
                blurRadius: 1,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 5),
            child: Row(
              children: [
                Text(appName,
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'OpenSans',
                        fontStyle: FontStyle.italic)),
                Expanded(
                  child: Container(),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: appColorOrange,
                      size: 20,
                    ),
                    Text(
                      _currentAddress != null
                          ? _currentAddress
                          : "please wait..",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  width: 5,
                ),
              ],
            ),
          ),
        ),
        Container(
          color: backgroundgrey,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 10),
                Text(
                  "Services",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Making Life easy",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                Container(height: 10),
                Container(height: 240, child: serviceWidget()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget serviceWidget() {
    return sortingModel == null
        ? Center(
            child: CupertinoActivityIndicator(),
          )
        : sortingModel.restaurants.length > 0
            ? ListView.builder(
                padding: EdgeInsets.only(
                  bottom: 10,
                  top: 10,
                ),
                itemCount: sortingModel.restaurants.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (
                  context,
                  int index,
                ) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DetailScreen(
                                  resId: sortingModel.restaurants[index].resId,
                                )),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                width: 170,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 15, left: 15, right: 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        sortingModel.restaurants[index].resName,
                                        maxLines: 1,
                                        style: TextStyle(
                                            color: appColorBlack,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Container(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "starting @",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                              Text(
                                                "\$" +
                                                    sortingModel
                                                        .restaurants[index]
                                                        .type[0]
                                                        .price,
                                                style: TextStyle(
                                                    color: appColorBlack,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                color: appColorOrange,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15))),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.shopping_bag_outlined,
                                                color: appColorWhite,
                                                size: 20,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 120,
                            width: 140,
                            alignment: Alignment.topCenter,
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(sortingModel
                                    .restaurants[index].allImage[0]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  "Don't have any services",
                  style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
  }

  Widget _banner(BuildContext context) {
    return bannerModal == null
        ? Center(
            child: CupertinoActivityIndicator(),
          )
        : ImageSlideshow(
            width: double.infinity,
            height: 240,
            initialPage: 0,
            indicatorColor: Colors.black,
            indicatorBackgroundColor: Colors.grey,
            children: bannerModal.banners
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: item,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: Container(
                              margin: EdgeInsets.all(70.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 5,
                            width: 5,
                            child: Icon(
                              Icons.error,
                            ),
                          ),
                        )),
                  ),
                )
                .toList(),
            onPageChanged: (value) {
              print('Page changed: $value');
            },
          );
  }

  Widget collectionWidget() {
    return Column(
      children: [
        Container(
          color: backgroundgrey,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 10),
                Text(
                  "Collections",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Hygiene & Safety Store",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                Container(height: 10),
                Container(height: 100, child: collectionData()),
                Container(height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget collectionData() {
    return collectionModal == null
        ? Center(
            child: CupertinoActivityIndicator(),
          )
        : collectionModal.categories.length > 0
            ? ListView.builder(
                padding: EdgeInsets.only(
                  bottom: 10,
                  top: 0,
                ),
                itemCount: collectionModal.categories.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (
                  context,
                  int index,
                ) {
                  return sortingCard(
                      context, collectionModal.categories[index]);
                },
              )
            : Center(
                child: Text(
                  "No data found",
                  style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
  }

  Widget sortingCard(BuildContext context, Categories categories) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ViewCategory(id: categories.id, name: categories.cName)),
          );
        },
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(width: 5),
              Image.network(
                categories.icon,
                height: 60,
              ),
              Container(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categories.cName,
                    style: TextStyle(
                        color: appColorBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                  Text(
                    "24x7 Shield",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Container(width: 15)
            ],
          ),
        ),
      ),
    );
  }

  Widget bestSellerWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 30),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            "Bestsellers",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            "check out our best selling products",
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        Container(height: 30),
        Container(
          color: backgroundgrey,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchProduct(
                                      back: true,
                                    )),
                          );
                        },
                        child: Text(
                          "View All",
                          style: TextStyle(
                              color: appColorBlack,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 250, child: bestSellerItems()),
                Container(height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget bestSellerItems() {
    return allProduct == null
        ? Center(
            child: CupertinoActivityIndicator(),
          )
        : allProduct.products.length > 0
            ? ListView.builder(
                padding: EdgeInsets.only(bottom: 10, top: 0),
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: allProduct.products.length,
                itemBuilder: (
                  context,
                  int index,
                ) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProductDetails(
                                  productId:
                                      allProduct.products[index].productId,
                                )),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            width: 180,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 15, left: 15, right: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 120,
                                        width: 140,
                                        child: Image.network(allProduct
                                            .products[index].productImage[0]),
                                      ),
                                    ],
                                  ),
                                  Container(height: 5),
                                  Text(
                                    allProduct.products[index].productName,
                                    maxLines: 2,
                                    style: TextStyle(
                                        color: appColorBlack,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Container(height: 5),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "\$" +
                                                allProduct.products[index]
                                                    .productPrice,
                                            style: TextStyle(
                                                color: appColorBlack,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: appColorOrange,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15))),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.shopping_bag_outlined,
                                            color: appColorWhite,
                                            size: 20,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  "Don't have any product now",
                  style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
  }
}
