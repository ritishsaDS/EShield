import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ez/constant/global.dart';
import 'package:ez/screens/view/newUI/detail.dart';
import 'package:ez/screens/view/models/catModel.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class ViewCategory extends StatefulWidget {
  String id;
  String name;
  ViewCategory({this.id, this.name});
  @override
  _ServiceTabState createState() => _ServiceTabState();
}

class _ServiceTabState extends State<ViewCategory> {
  bool isLoading = false;

  CatModal catModal;

  @override
  void initState() {
    super.initState();
    getResidential();
  }

  getResidential() async {
    try {
      Map<String, String> headers = {
        'content-type': 'application/x-www-form-urlencoded',
      };
      var map = new Map<String, dynamic>();
      map['cat_id'] = widget.id;

      final response = await client.post(baseUrl() + "get_cat_res",
          headers: headers, body: map);

      var dic = json.decode(response.body);
      Map userMap = jsonDecode(response.body);
      setState(() {
        catModal = CatModal.fromJson(userMap);
      });
      print(">>>>>>");
      print(dic);
    } on Exception {
      Toast.show("No Internet connection", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

      throw Exception('No Internet connection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          // bottom:
          title: Text(
            widget.name,
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: catModal == null
            ? Center(
                child: CupertinoActivityIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 20),
                child: bestSellerItems(context),
              ));
  }

  Widget bestSellerItems(BuildContext context) {
    return catModal.restaurants != null
        ? GridView.builder(
            shrinkWrap: true,
            //physics: NeverScrollableScrollPhysics(),
            primary: false,
            padding: EdgeInsets.all(10),
            itemCount: catModal.restaurants.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 170 / 230,
            ),
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DetailScreen(
                                resId: catModal.restaurants[index].resId,
                              )),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              width: 180,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 15, left: 15, right: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      catModal.restaurants[index].resName,
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
                                                  catModal.restaurants[index]
                                                      .type[0].price,
                                              style: TextStyle(
                                                  color: appColorBlack,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          child: Padding(
                                              padding: EdgeInsets.all(0),
                                              child: Text(
                                                "BOOK \nNOW",
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 12),
                                              )),
                                        ),
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
                              image: NetworkImage(
                                  catModal.restaurants[index].allImage[0]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
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
                color: appColorBlack,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
  }
}
