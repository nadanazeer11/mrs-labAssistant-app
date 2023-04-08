import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:mrs/config/colors.dart';
import 'package:mrs/models/Project.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';

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
  // List<String> _selectedItems=[];
  // List<String> items=[];

  @override
  void initState() {
    _getLoggedInName();
  }

  // void _showMultiSelect  ()async {
  //   List<String> res = await showDialog(context: context, builder:
  //       (BuildContext) {
  //     // return MultiSelect(items:items,);
  //     return MultiSelect(items: items, preSelectedItems: _selectedItems);
  //   });
  //   if (items != null) {
  //     setState(() {
  //       _selectedItems = res;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    DateTime n=widget.project?.endDate.toDate() ?? DateTime.now();
    String x=DateFormat(
        'dd/MM/yy')
        .format(n);

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
              , Text('Deadline:${x}',style:TextStyle(fontSize: 16),),
        ]),
        trailing:loggedInName==widget.project?.createdBy ? PopupMenuButton(
          itemBuilder: (BuildContext context)=>[
            PopupMenuItem(
              child: widget.project?.isDone==true?
              Row(
                children: [
                  Icon(Icons.remove_done),
                  Text("Mark as Undone"),
                ],
              ):Row(
                children: [
                  Icon(Icons.done),
                  Text("Mark as Done"),
                ],
              ),
              value: 1,
            ),
            PopupMenuItem(child: Row(children: [
              Icon(Icons.edit),
              Text("Edit Contributers"),
            ],),
            value: 3,),
            PopupMenuItem(
              child: Container(
                  color: Colors.red,
                  child: Row(
                    children: [
                      Icon(Icons.delete),
                      Text('Delete'),
                    ],
                  )),
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
              onPressed: ()async{
                try{
                  await homeC.deleteDocument(widget.id);
                  Navigator.pop(context, 'yes');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Successfully Deleted project'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                catch(e){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Update error occurred.Please try again!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }

              },
              child: const Text('Yes',style:TextStyle( color:Color.fromRGBO(230, 46, 4, 1),fontSize: 19),),
            ),
          ],
        ),
      );
    }
    if(value==3){
    try{
      List<String> users=await homeC.getProjUsers(widget.id);
      List<String> ausers=await homeC.getUserNames();

      List<String> ?res=await showDialog(context: context, builder:
          (BuildContext){
        return MultiSelect(items: [...ausers], preSelectedItems: [...users]);
      });
      debugPrint("empty $res");
      if(res!=null){
        await homeC.editUsers(res,users,widget.id);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully updated contributers'),
          backgroundColor: Colors.green,
        ),
      );

      // debugPrint("${res.join(',')}");
      }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update error occurred.Please try again!'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred.Please try again!'),
            backgroundColor: Colors.red,
          ),
        );
      }

    }
  }

}
class MultiSelect extends StatefulWidget {
  final List<String> items;
  final List<String> preSelectedItems;
  const MultiSelect({Key? key, required this.items, required this.preSelectedItems}) : super(key: key);

  @override
  State<MultiSelect> createState() => _MultiSelectState();
}
class _MultiSelectState extends State<MultiSelect> {
  List<String> _selectedItems=[];
  void initState() {
    super.initState();
    _selectedItems = widget.preSelectedItems;
  }
  void _itemChange(String itemValue,bool isSelected){
    setState(() {
      if(isSelected){
        _selectedItems.add(itemValue);
      }
      else{
        _selectedItems.remove(itemValue);
      }

    });
  }
  void _cancel(){
    Navigator.pop(context);
  }
  void _submit(){
    Navigator.pop(context,_selectedItems);
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Contributors'),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
      content: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // color: Colors.grey[300],
        ),
        child: SizedBox(
          // height: 300.0,
          // width: 300.0,
          child: Scrollbar(
            child: SingleChildScrollView(
              child: ListBody(
                children: widget.items.map((item) => CheckboxListTile(
                  value: _selectedItems.contains(item),
                  title: Text(item),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (isChecked) => _itemChange(item, isChecked!),
                )).toList(),
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: _cancel,
            child: Text("Cancel",style: TextStyle(
                color: AppColorss.darkmainColor
            ),)
        ),
        TextButton(
            onPressed: _submit,
            child:Text("Submit",style: TextStyle(
                color: AppColorss.darkmainColor
            ),)
        )
      ],
    );


  }
}

