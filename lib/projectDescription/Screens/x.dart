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
  bool isReady = false;
  String errorMessage = '';

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
        body:
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text("${name}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
              Expanded(
                child: PDFView(
                  filePath: widget.file.path,
                  autoSpacing: true,
                  swipeHorizontal: true,
                  onRender: (_pages) {
                    setState(() {
                     // pages = _pages;
                      isReady = true;
                    });
                  },
                  onError: (error) {
                    setState(() {
                      errorMessage = error.toString();
                    });
                    print(error.toString());
                  },

                ),
              ),
            ],
          ),
        ),
        
        // errorMessage.isEmpty
        //     ? !isReady
        //     ? Center(
        //   child: CircularProgressIndicator(),
        // )
        //     : Container()
        //     : Center(
        //   child: Text(errorMessage),
        // )
      ),
    );
  }
}
