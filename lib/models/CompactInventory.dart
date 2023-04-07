import 'package:cloud_firestore/cloud_firestore.dart';

class CompactInventory{
  String itemId;
  String itemName;
  Timestamp creationDate;
  String createdBy;

  String status;
  String description;
  String administeredBy; //in case of borrow or death administered by who
  String deathDate; //in case of death and borrow
  String deathReason; //in case of death


  CompactInventory(
      {
        required this.itemId,
        required this.itemName,
        required this.status,
        required this.createdBy,
        required this.creationDate,
        required this.administeredBy,
        required this.deathDate,
        required this.deathReason,
        required this.description
      });
}