import 'package:cloud_firestore/cloud_firestore.dart';

class Inventory{
  String itemId;
  String itemName;
  Timestamp creationDate;
  String createdBy;

  String status;
  String borrowedUser; //only in case of borrow else " "
  String administeredBy; //in case of borrow or death administered by who
  String borrowDeathDate; //in case of death and borrow
  String deathReason; //in case of death

  Inventory(
      {
        required this.itemId,
        required this.itemName,
        required this.status,
        required this.createdBy,
        required this.borrowedUser,
        required this.creationDate,
        required this.administeredBy,
        required this.borrowDeathDate,
        required this.deathReason,
      });
  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'status': status,
      'creationDate': creationDate,
      'createdBy':createdBy,
      'borrowedUser':borrowedUser,
      'borrowDeathDate':borrowDeathDate,
      'administeredBy':administeredBy,
      'deathReason':deathReason
    };
  }

}
