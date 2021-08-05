class GetServiceDetailsModal {
  int status;
  String msg;
  Restaurant restaurant;
  List<Review> review;

  GetServiceDetailsModal({this.status, this.msg, this.restaurant, this.review});

  GetServiceDetailsModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    restaurant = json['restaurant'] != null
        ? new Restaurant.fromJson(json['restaurant'])
        : null;
    if (json['review'] != null) {
      //review = new List<Review>();
       review = List<Review>.empty(growable: true);
      json['review'].forEach((v) {
        review.add(new Review.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['msg'] = this.msg;
    if (this.restaurant != null) {
      data['restaurant'] = this.restaurant.toJson();
    }
    if (this.review != null) {
      data['review'] = this.review.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Restaurant {
  String resId;
  String catId;
  String scatId;
  String resName;
  String resNameU;
  String resDesc;
  String resDescU;
  String resWebsite;
  ResImage resImage;
  String logo;
  String resPhone;
  String resAddress;
  String resIsOpen;
  String resStatus;
  String resCreateDate;
  String resRatings;
  String status;
  String resVideo;
  String resUrl;
  String mfo;
  String lat;
  String lon;
  String vid;
  String structure;
  String hours;
  String experts;
  List<String> allImage;
  String cName;
  List<Type> type;

  Restaurant(
      {this.resId,
      this.catId,
      this.scatId,
      this.resName,
      this.resNameU,
      this.resDesc,
      this.resDescU,
      this.resWebsite,
      this.resImage,
      this.logo,
      this.resPhone,
      this.resAddress,
      this.resIsOpen,
      this.resStatus,
      this.resCreateDate,
      this.resRatings,
      this.status,
      this.resVideo,
      this.resUrl,
      this.mfo,
      this.lat,
      this.lon,
      this.vid,
      this.structure,
      this.hours,
      this.experts,
      this.allImage,
      this.cName,
      this.type});

  Restaurant.fromJson(Map<String, dynamic> json) {
    resId = json['res_id'];
    catId = json['cat_id'];
    scatId = json['scat_id'];
    resName = json['res_name'];
    resNameU = json['res_name_u'];
    resDesc = json['res_desc'];
    resDescU = json['res_desc_u'];
    resWebsite = json['res_website'];
    resImage = json['res_image'] != null
        ? new ResImage.fromJson(json['res_image'])
        : null;
    logo = json['logo'];
    resPhone = json['res_phone'];
    resAddress = json['res_address'];
    resIsOpen = json['res_isOpen'];
    resStatus = json['res_status'];
    resCreateDate = json['res_create_date'];
    resRatings = json['res_ratings'];
    status = json['status'];
    resVideo = json['res_video'];
    resUrl = json['res_url'];
    mfo = json['mfo'];
    lat = json['lat'];
    lon = json['lon'];
    vid = json['vid'];
    structure = json['structure'];
    hours = json['hours'];
    experts = json['experts'];
    allImage = json['all_image'].cast<String>();
    cName = json['c_name'];
    if (json['type'] != null) {
     // type = new List<Type>();
       type = List<Type>.empty(growable: true);
      json['type'].forEach((v) {
        type.add(new Type.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['res_id'] = this.resId;
    data['cat_id'] = this.catId;
    data['scat_id'] = this.scatId;
    data['res_name'] = this.resName;
    data['res_name_u'] = this.resNameU;
    data['res_desc'] = this.resDesc;
    data['res_desc_u'] = this.resDescU;
    data['res_website'] = this.resWebsite;
    if (this.resImage != null) {
      data['res_image'] = this.resImage.toJson();
    }
    data['logo'] = this.logo;
    data['res_phone'] = this.resPhone;
    data['res_address'] = this.resAddress;
    data['res_isOpen'] = this.resIsOpen;
    data['res_status'] = this.resStatus;
    data['res_create_date'] = this.resCreateDate;
    data['res_ratings'] = this.resRatings;
    data['status'] = this.status;
    data['res_video'] = this.resVideo;
    data['res_url'] = this.resUrl;
    data['mfo'] = this.mfo;
    data['lat'] = this.lat;
    data['lon'] = this.lon;
    data['vid'] = this.vid;
    data['structure'] = this.structure;
    data['hours'] = this.hours;
    data['experts'] = this.experts;
    data['all_image'] = this.allImage;
    data['c_name'] = this.cName;
    if (this.type != null) {
      data['type'] = this.type.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ResImage {
  String resImag0;

  ResImage({this.resImag0});

  ResImage.fromJson(Map<String, dynamic> json) {
    resImag0 = json['res_imag0'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['res_imag0'] = this.resImag0;
    return data;
  }
}

class Type {
  String type;
  String typeName;
  String price;

  Type({this.type, this.typeName, this.price});

  Type.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    typeName = json['type_name'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['type_name'] = this.typeName;
    data['price'] = this.price;
    return data;
  }
}

class Review {
  String revId;
  String revUser;
  String revRes;
  String revStars;
  String revText;
  String revDate;
  RevUserData revUserData;

  Review(
      {this.revId,
      this.revUser,
      this.revRes,
      this.revStars,
      this.revText,
      this.revDate,
      this.revUserData});

  Review.fromJson(Map<String, dynamic> json) {
    revId = json['rev_id'];
    revUser = json['rev_user'];
    revRes = json['rev_res'];
    revStars = json['rev_stars'];
    revText = json['rev_text'];
    revDate = json['rev_date'];
    revUserData = json['rev_user_data'] != null
        ? new RevUserData.fromJson(json['rev_user_data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rev_id'] = this.revId;
    data['rev_user'] = this.revUser;
    data['rev_res'] = this.revRes;
    data['rev_stars'] = this.revStars;
    data['rev_text'] = this.revText;
    data['rev_date'] = this.revDate;
    if (this.revUserData != null) {
      data['rev_user_data'] = this.revUserData.toJson();
    }
    return data;
  }
}

class RevUserData {
  String id;
  String email;
  String password;
  String username;
  String profilePic;
  String facebookId;
  String type;
  String isGold;
  String date;
  String mobile;
  String address;
  String city;
  String country;

  RevUserData(
      {this.id,
      this.email,
      this.password,
      this.username,
      this.profilePic,
      this.facebookId,
      this.type,
      this.isGold,
      this.date,
      this.mobile,
      this.address,
      this.city,
      this.country});

  RevUserData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    password = json['password'];
    username = json['username'];
    profilePic = json['profile_pic'];
    facebookId = json['facebook_id'];
    type = json['type'];
    isGold = json['isGold'];
    date = json['date'];
    mobile = json['mobile'];
    address = json['address'];
    city = json['city'];
    country = json['country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['password'] = this.password;
    data['username'] = this.username;
    data['profile_pic'] = this.profilePic;
    data['facebook_id'] = this.facebookId;
    data['type'] = this.type;
    data['isGold'] = this.isGold;
    data['date'] = this.date;
    data['mobile'] = this.mobile;
    data['address'] = this.address;
    data['city'] = this.city;
    data['country'] = this.country;
    return data;
  }
}