import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class GetCardToken {
  Future getCardToken(String cardNumber, String month, String year,
      String cvcNumber, String cardHolderName, BuildContext context) async {
    try {
      // print(responseJson["id"]);
    } on Exception {
      //   throw Exception('No Internet connection');
      Toast.show("Something went wrog.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  // sk_test_Vcv04sLCi00ljN3C8GqrpDmw00SJk0bP62
  // sk_test_Vcv04sLCi00ljN3C8GqrpDmw00SJk0bP62
// sk_live_lCtPjoinQO39U0PntCc9jqFB00OwzbUi5C
}

final getCardToken = GetCardToken();
