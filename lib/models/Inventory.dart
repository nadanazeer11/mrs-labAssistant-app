import 'package:cloud_firestore/cloud_firestore.dart';

class Inventory{
  String itemId;
  String itemName;
  String status;
  Timestamp creationDate;
  String createdBy;
  String borrowedUser;
  String borrowedFrom;
  Timestamp borrowedDate;

  Inventory(
      {
        required this.itemId,
        required this.itemName,
        required this.status,
        required this.createdBy,
        required this.borrowedUser,
        required this.creationDate,
        required this.borrowedFrom,
        required this.borrowedDate
      });
  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'status': status,
      'creationDate': creationDate,
      'createdBy':createdBy,
      'borrowedUser':borrowedUser,
      'borrowedDate':borrowedDate,
      'borrowedFrom':borrowedFrom,


    };
  }

}
