import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:mrs/config/colors.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../../config/text_styles.dart';
import '../../models/FileObj.dart';
import '../backend/projectDescripController.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class fileScreen extends StatefulWidget {
  const fileScreen({Key? key}) : super(key: key);

  @override
  State<fileScreen> createState() => _fileScreenState();
}

class _fileScreenState extends State<fileScreen> {
  @override
  Widget build(BuildContext context) {
    ProjectDContr pdc=new ProjectDContr();
    bool loading=false;
    final args=ModalRoute.of(context)!.settings.arguments as FileObj;
    if(args.url==null || args.baseName==null){
      return Center(child:Text("nothing to see",style: TextStyle(fontSize: 16,color: AppColorss.darkmainColor),));
    }
    else{
      return SafeArea(
          child:Scaffold(
            appBar:AppBar(
              backgroundColor:AppColorss.lightmainColor ,
              elevation: 0,
              title:Text("MRS",style:subHeadingStyle) ,
              actions: [
                IconButton(onPressed: (){}, icon:Icon(Icons.filter_list_outlined))
              ],
              leading: IconButton(onPressed: (){
                Navigator.pop(context);
              },icon: Icon(Icons.arrow_back_ios),),
            ),
            body: SingleChildScrollView(
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Text("${args.baseName}",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400),),
                    loading==true ? CircularProgressIndicator():IconButton(onPressed: ()async {
                      setState(() {
                        loading=true;
                      });
                     String result=await pdc.downloadFile(args.baseName);
                     setState(() {
                       loading=false;
                     });
                     if(result=="done"){
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                           content: Text('Downloaded ${args.baseName}'),
                           backgroundColor: Colors.green,
                         ),
                       );
                     }
                     else if(result=="was not able to get reference"){
                       showPlatformDialog(
                         context: context,
                         builder: (context) => BasicDialogAlert(
                           title: Text("Reference Error"),
                           content:
                           Text("File not found, please try again"),
                           actions: <Widget>[
                             BasicDialogAction(
                               title: Text("OK"),
                               onPressed: () {
                                 Navigator.pop(context);
                               },
                             ),
                           ],
                         ),
                       );
                     }
                     else if(result=="was not able to download"){
                       showPlatformDialog(
                         context: context,
                         builder: (context) => BasicDialogAlert(
                           title: Text("Download Error"),
                           content:
                           Text("An error occured while downloading, please try again!"),
                           actions: <Widget>[
                             BasicDialogAction(
                               title: Text("OK"),
                               onPressed: () {
                                 Navigator.pop(context);
                               },
                             ),
                           ],
                         ),
                       );

                     }
                    }, icon:Icon(Icons.download))
                  ],),
                )
              ]),
            ),
          )
      );
    }
  }
}
