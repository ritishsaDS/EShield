import 'dart:convert';
import 'package:ez/screens/view/models/categories_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ez/constant/global.dart';
import 'package:ez/constant/sizeconfig.dart';
import 'package:ez/screens/view/newUI/viewCategory.dart';
import 'package:http/http.dart' as http;

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<CategoriesScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  AllCateModel collectionModal;

  @override
  void initState() {
    _getCollection();
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        backgroundColor: appColorWhite,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          title: Text(
            'Categories',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
        ),
        body: collectionModal == null
            ? Center(
                child: CupertinoActivityIndicator(),
              )
            : collectionModal.categories.length > 0
                ? Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      //physics: const NeverScrollableScrollPhysics(),
                      itemCount: collectionModal.categories.length,
                      itemBuilder: (context, int index) {
                        return widgetCatedata(
                            collectionModal.categories[index]);
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      "Don't have any categories now",
                      style: TextStyle(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ));
  }

  Widget widgetCatedata(Categories categories) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ViewCategory(
              id: categories.id,
              name: categories.cName,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 25, right: 25, bottom: 10),
        child: new Card(
          margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          color: Colors.black45,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 100,
            child: Row(
              children: <Widget>[
                Container(width: 20),
                Container(
                    height: 50,
                    child: Image.network(
                      categories.img,
                      fit: BoxFit.cover,
                      color: appColorWhite,
                    )),
                Container(width: 20),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    categories.cName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'OpenSansBold',
                        fontWeight: FontWeight.bold,
                        color: appColorWhite),
                  ),
                ),
                Container(width: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
