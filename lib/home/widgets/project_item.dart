import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mrs/config/colors.dart';
import 'package:mrs/models/Project.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../common.dart';
import '../../models/Project.dart';
import '../../models/Project.dart';
import '../backend/Home_Controller.dart';

class Project_item extends StatefulWidget {
  String? id;
  Project? project;

  Project_item({required this.id,required this.project});

  @override
  State<Project_item> createState() => _Project_itemState();
}

class _Project_itemState extends State<Project_item> {
  HomeContr homeC=new HomeContr();
  String loggedInName="";
  @override
  void initState() {
    _getLoggedInName();
  }



  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 10,vertical: 6),
      child: ListTile(
        onTap: (){
          Navigator.pushNamed(context, '/projectDetails', arguments: {'id': widget.id});

        },
        contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical:10),
        title:Text(
          '${widget.project?.title ?? 'N/A'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,children: [
              Icon(Icons.linear_scale_outlined,color: AppColorss.darkmainColor,)
              , Text('Deadline:1/3/2022',style:TextStyle(fontSize: 16),),
        ]),
        trailing:loggedInName==widget.project?.createdBy ? PopupMenuButton(
          itemBuilder: (BuildContext context)=>[
            PopupMenuItem(
              child: widget.project?.isDone==true?Text("Mark as Undone"):Text("Mark as Done"),
              value: 1,
            ),
            PopupMenuItem(
              child: Text('Delete'),
              value: 2,
            ),
          ],
          onSelected: (value) {
            markOptions(value);
          },
        ):null,
        leading: Icon(
          widget.project?.isDone == true
              ? Icons.done
              : widget.project?.isLate == true
                ? Icons.warning
                : Icons.timelapse,
          size: 39,
          color: AppColorss.activeColor
        ),

      ),
    );
  }
  markOptions(int value)async{
    if(value==1){
      bool? done=widget.project?.isDone;
      if(done!=null){
        try{
          await homeC.updateProjectIsDone(widget.id, !done);
        }
        catch(e){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred.Please try again!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

    }
    if(value==2){
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(
            'Delete ${widget.project?.title ?? 'N/A'}',
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500),
          ),
          content: const Text('Are You sure you want to delete?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel',style:TextStyle( color:Color(0xFF005466),fontSize: 19),),
            ),
            TextButton(
              onPressed: (){

              },
              child: const Text('Yes',style:TextStyle( color:Color.fromRGBO(230, 46, 4, 1),fontSize: 19),),
            ),
          ],
        ),
      );
    }
  }
  void _getLoggedInName()async{
    try {
      String x=await getLoggedInName();
      setState(() {
        loggedInName=x;
      });
      debugPrint("pi $x");

    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred.Please try again!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }





}
