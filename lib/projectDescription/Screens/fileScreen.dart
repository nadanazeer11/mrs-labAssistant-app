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
    String link=args.url ?? "https://firebasestorage.googleapis.com/v0/b/mrslab-1c119.appspot.com/o/images.png?alt=media&token=87f0491f-aa66-4f2b-8437-20404a819e1c";
    if(args.url==null || args.baseName==null){
      return Center(child:Text("nothing to see",style: TextStyle(fontSize: 16,color: AppColorss.darkmainColor),));
    }
    else{
      debugPrint("url gay sa7 $link");
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
                    Expanded(child: Text("${args.baseName}",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400,overflow: TextOverflow.ellipsis),)),
                    //   Tooltip(message: args.baseName, child: Text("... ${args.baseName?.substring(0, 10)}" ) ),
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
                ),
                // Stack(
                //   children: [
                //     Image.network(
                //       link,
                //       // height: double.infinity,
                //       // width: double.infinity,
                //       errorBuilder: (context,error,stackTrace)=>Text("Error loading the image"),
                //     ),
                //     Center(child: CircularProgressIndicator(),)
                //   ],
                // ),
            Image.network(
                link,
                fit: BoxFit.fill,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, exception, stackTrace) {
                  return Text("Error loading the image");
                }
            )]),
            ),
          )
      );
    }
  }
}
