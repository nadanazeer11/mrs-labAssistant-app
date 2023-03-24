import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path/path.dart';

import '../../config/colors.dart';
import '../../config/text_styles.dart';

class PDFViewerPage extends StatefulWidget {
  final File file;

  const PDFViewerPage({
    required this.file,
  });

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
 // PDFViewController controller;
  int pages = 0;
  int indexPage = 0;

  @override
  Widget build(BuildContext context) {
    final name = basename(widget.file.path);
    final text = '${indexPage + 1} of $pages';

    return SafeArea(
      child: Scaffold(
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
        body: PDFView(
          filePath: widget.file.path,
          autoSpacing: true,
          swipeHorizontal: true,

        ),
      ),
    );
  }
}