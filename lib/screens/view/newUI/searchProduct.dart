import 'dart:convert';
import 'package:ez/screens/view/models/allProduct_modal.dart';
import 'package:ez/screens/view/newUI/productDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ez/constant/global.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class SearchProduct extends StatefulWidget {
  bool back;
  SearchProduct({this.back});
  @override
  _ServiceTabState createState() => _ServiceTabState();
}

class _ServiceTabState extends State<SearchProduct> {
  AllProductModal allProduct;
  TextEditingController controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getAllProduct();
  }

  getAllProduct() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: appColorWhite,
        appBar: AppBar(
          title: Padding(
              padding: const EdgeInsets.only(top: 10, right: 0, left: 0),
              child: Container(
                decoration: new BoxDecoration(
                    color: Colors.green,
                    borderRadius: new BorderRadius.all(
                      Radius.circular(15.0),
                    )),
                height: 40,
                child: Center(
                  child: TextField(
                    controller: controller,
                    onChanged: onSearchTextChanged,
                    autofocus: true,
                    style: TextStyle(color: Colors.grey),
                    decoration: new InputDecoration(
                      border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[200]),
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(15.0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[200]),
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(15.0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey[200]),
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(15.0),
                        ),
                      ),
                      filled: true,
                      hintStyle:
                          new TextStyle(color: Colors.grey[600], fontSize: 14),
                      hintText: "Search",
                      contentPadding: EdgeInsets.only(top: 10.0),
                      fillColor: Colors.grey[200],
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[600],
                        size: 25.0,
                      ),
                    ),
                  ),
                ),
              )),
          centerTitle: false,
          elevation: 1,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: null,
          actions: <Widget>[
            Container(
              width: 50,
              child: IconButton(
                padding: const EdgeInsets.all(0),
                icon: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    controller.clear();
                    onSearchTextChanged("");
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            Container(width: 15),
          ],
        ),
        body: serviceWidget());
  }

  Widget serviceWidget() {
    return allProduct == null
        ? Center(
            child: CupertinoActivityIndicator(),
          )
        : allProduct.products.length > 0
            ? _searchResult.length != 0 ||
                    controller.text.trim().toLowerCase().isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      //physics: NeverScrollableScrollPhysics(),
                      primary: false,
                      padding: EdgeInsets.all(5),
                      itemCount: _searchResult.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 170 / 200,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return itemWidget(_searchResult[index]);
                      },
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      //physics: NeverScrollableScrollPhysics(),
                      primary: false,
                      padding: EdgeInsets.all(5),
                      itemCount: allProduct.products.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 170 / 200,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return itemWidget(allProduct.products[index]);
                      },
                    ),
                  )
            : Center(
                child: Text(
                  "Don't have any product",
                  style: TextStyle(
                    color: appColorBlack,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
  }

  Widget itemWidget(Products products) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProductDetails(
                    productId: products.productId,
                  )),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
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
                padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
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
                          child: Image.network(products.productImage[0]),
                        ),
                      ],
                    ),
                    Container(height: 5),
                    Text(
                      products.productName,
                      maxLines: 2,
                      style: TextStyle(
                          color: appColorBlack,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    Container(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.local_offer_outlined, size: 20),
                                Container(width: 5),
                                Text(
                                  "\$" + products.productPrice,
                                  style: TextStyle(
                                      color: appColorOrange,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: appColorOrange,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
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
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    allProduct.products.forEach((userDetail) {
      if (userDetail.productName != null) if (userDetail.productName
          .toLowerCase()
          .contains(text.toLowerCase())) _searchResult.add(userDetail);
    });

    setState(() {});
  }
}

List _searchResult = [];
