import 'package:cloud_firestore/cloud_firestore.dart';

class Inventory{
  String itemId;
  String itemName;
  Timestamp creationDate;
  String createdBy;

  String status;
  String borrowedUser; //only in case of borrow else " "
  String borrowedFrom; //in case of borrow or death administered by who
  String borrowedDate;

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
