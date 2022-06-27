import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web1_app/BACK-END/AnalyzePDF/SentencePartClass.dart';
import 'package:web1_app/BACK-END/AnalyzePDF/AnalyzePDF.dart';
import 'package:web1_app/BACK-END/Exporting/ExportAllFiles.dart';
import 'package:web1_app/BACK-END/Exporting/ExportFile.dart';
import '../../BACK-END/AnalyzePDF/UploadPDF.dart';
import '../../BACK-END/AnalyzePDF/AnalyzePDF.dart';
import '../../BACK-END/AnalyzePDF/SentencePartClass.dart';
import '../../BACK-END/Exporting/ExportFile.dart';
import 'package:web1_app/BACK-END/PDFfileClass.dart';
import '../MainPageForAnalysisInputText/TooltipSpan.dart';
import 'MainAppBarWidget.dart';
import 'package:flutter/services.dart' as rootBundle;
import '../FeedbackPage/FeedbackPage.dart';

// Methods:
// ExportAllButton
// ExportButton
// MistakenSentenceElement
// MistakenSentenceList
// PartWithPDFsWidget
// PDFElementWidget
// PDFNamesList
// ReportPartWidget
// UploadPDFButton

class MainMainPageForAnalysisPDFsWidget extends StatefulWidget {
  const MainMainPageForAnalysisPDFsWidget({Key? key}) : super(key: key);

  @override
  _MainMainPageForAnalysisPDFsWidget createState() =>
      _MainMainPageForAnalysisPDFsWidget();
}

class _MainMainPageForAnalysisPDFsWidget
    extends State<MainMainPageForAnalysisPDFsWidget> {
  List<List<SentencePart>>? mistakenSentenceList;
  late int indexOfSelectedPDF;

  @override
  void initState() {
    super.initState();
    mistakenSentenceList = Analyzer.reportData[Analyzer.reportData.keys.first];
    indexOfSelectedPDF = 0;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Fix my English",
      scrollBehavior: MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: MainAppBarWidget(context),
        body: Container(
            child: Row(
          children: [
            ReportPartWidget(),
            PartWithPDFsWidget(),
          ],
        )),
      ),
    );
  }

  Widget ReportPartWidget() {
    return Expanded(
        key: indexOfSelectedPDF == -1
            ? Key("Empty report")
            : Key(
                "report part ${Analyzer.reportData.keys.elementAt(indexOfSelectedPDF)}"),
        child: Column(
          children: [
            Container(
              height: 65,
            ),
            MistakenSentenceList(),
            ExportButton()
          ],
        ));
  }

  Widget MistakenSentenceList() {
    return Expanded(
      child: mistakenSentenceList != null
          ? ListView.builder(
              itemCount: mistakenSentenceList?.length,
              itemBuilder: (BuildContext context, int index) {
                Widget? x = MistakenSentenceElement(
                    mistakenSentenceList![index], index);
                return x != null ? x : SizedBox.shrink();
              })
          : Text(
              "Please, click on upload or any button with name of file on right panel"),
    );
  }

  Widget? MistakenSentenceElement(text, index) {
    if (prepareForCopying(text) == "") {
      return null;
    }
    return Container(
        decoration: const BoxDecoration(
          color: const Color(0xFFF2EEE1),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black26,
          //     blurRadius: 3,
          //     offset: Offset(1, 3),
          //     spreadRadius: 1,
          //   ),
          // ],
          borderRadius: BorderRadius.all(Radius.circular(23)),
        ),
        margin: const EdgeInsets.only(top: 15, right: 55, left: 55),
        padding: const EdgeInsets.only(top: 25, right: 35, left: 35, bottom: 3),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: RichText(
                text: TextSpan(
                  text: '',
                  children: convertTextToTextSpans(text),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: FittedBox(
                child: Row(children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 13.0, right: 10),
                    child: Material(
                        color: Colors.white.withOpacity(0.0),
                        child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  opaque: false, // set to false
                                  pageBuilder: (_, __, ___) => FeedbackPage(
                                      convertTextToTextSpans(text),
                                      index,
                                      Analyzer.reportData.keys
                                          .elementAt(indexOfSelectedPDF)),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.warning_rounded,
                              color: Color(0xDD864921),
                              size: 32,
                            ))),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 13.0),
                    child: Tooltip(
                      message: "Copy",
                      padding: EdgeInsets.all(6),
                      margin: EdgeInsets.all(10),
                      showDuration: Duration(seconds: 0),
                      decoration: BoxDecoration(
                        color: Color(0xFF49454F),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                      ),
                      textStyle: TextStyle(color: Colors.white),
                      preferBelow: true,
                      child: Material(
                          color: Colors.white.withOpacity(0.0),
                          child: InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(
                                    text: prepareForCopying(text)));
                              },
                              child: Image.asset(
                                "copy.png",
                                width: 30,
                                height: 30,
                              ))),
                    ),
                  )
                ]),
              ),
            )
          ],
        ));
  }

  String prepareForCopying(List<SentencePart> text) {
    String toRet = '';
    for (var element in text) {
      toRet += element.text;
    }
    return toRet;
  }

  List<TooltipSpan> convertTextToTextSpans(List<SentencePart> txt) {
    List<TooltipSpan> toRet = [];
    for (var i in txt) {
      i.description == null
          ? toRet.add(TooltipSpan(
              message: "",
              inlineSpan: TextSpan(
                  text: i.text,
                  style: const TextStyle(
                    height: 1.5,
                    fontSize: 20,
                    fontFamily: 'Eczar',
                  ))))
          : toRet.add(TooltipSpan(
              message: i.description!,
              inlineSpan: TextSpan(
                  text: i.text,
                  style: const TextStyle(
                    backgroundColor: Color(0x80DD4A4A),
                    height: 1.5,
                    fontSize: 20,
                    fontFamily: 'Eczar',
                  ))));
    }
    return toRet;
  }

  Widget ExportButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 30.0, bottom: 20, right: 30),
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3,
                offset: Offset(1, 3),
                spreadRadius: 1,
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(40)),
          ),
          child: FittedBox(
            child: ElevatedButton(
                onPressed: () {
                  print("Exporting file..");
                  String selected_file_name =
                      Analyzer.reportData.keys.elementAt(indexOfSelectedPDF);
                  print("Selected file name = " + selected_file_name);
                  Exporter.downloadFile(
                      Exporter.getCsv(selected_file_name), selected_file_name);
                },
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromRGBO(134, 73, 33, 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                ),
                child: Row(
                  children: <Widget>[
                    const Text("Export to CSV",
                        style: TextStyle(
                          color: Color.fromRGBO(251, 253, 247, 1),
                          fontFamily: 'Eczar',
                          fontSize: 30,
                        )),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  Widget PartWithPDFsWidget() {
    return Container(
      width: 386,
      color: const Color(0xFFE9F1E8),
      child: Column(children: [
        UploadPDFButton(),
        Container(child: Align(alignment: Alignment.centerRight, child: clearAllButton())),
        PDFNamesList(),
        ExportAllButton()
      ]),
    );
  }

  Widget clearAllButton() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3,
                offset: Offset(1, 3),
                spreadRadius: 1,
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(40)),
          ),
          child: FittedBox(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  Analyzer.reportData.clear();
                  indexOfSelectedPDF = -1;
                });
              },
              style: ElevatedButton.styleFrom(
                primary: const Color(0xFF4D6658),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
              ),
              child: Text("Clear all",
                  style: TextStyle(
                    color: Color.fromRGBO(251, 253, 247, 1),
                    fontFamily: 'Eczar',
                    fontSize: 30,
                  )),
            ),
          ),
        ),
      ),
    );
  }

  Widget ExportAllButton() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 25, bottom: 20),
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3,
                offset: Offset(1, 3),
                spreadRadius: 1,
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(40)),
          ),
          child: FittedBox(
            child: ElevatedButton(
              onPressed: () {
                exportAllFileS();
              },
              style: ElevatedButton.styleFrom(
                primary: const Color(0xFF4D6658),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
              ),
              child: Text("Export all to CSV",
                  style: TextStyle(
                    color: Color.fromRGBO(251, 253, 247, 1),
                    fontFamily: 'Eczar',
                    fontSize: 30,
                  )),
            ),
          ),
        ),
      ),
    );
  }

  Widget PDFNamesList() {
    return Expanded(
        child: Container(
      child: ListView.builder(
          itemCount: Analyzer.reportData.length,
          itemBuilder: (BuildContext context, int index) => Visibility(
              visible: Analyzer.reportData.keys.elementAt(index) !=
                  "textForAnalysis",
              child: PDFElementWidget(Analyzer.reportData.keys.elementAt(index),
                  index == indexOfSelectedPDF, index))),
    ));
  }

  Widget PDFElementWidget(String PDFName, bool selected, int index) {
    return Padding(
        padding: const EdgeInsets.only(top: 18, left: 30, right: 30),
        child: ElevatedButton(
            key: Key(PDFName),
            onPressed: () {
              setState(() {
                mistakenSentenceList = Analyzer.reportData[PDFName];
                indexOfSelectedPDF = index;
              });
            },
            style: ElevatedButton.styleFrom(
              primary:
                  !selected ? const Color(0xFF62806F) : const Color(0xFF4D6658),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7)),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    child: Container(
                      height: 60,
                      width: 300,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: Image.asset(
                              'Importpdficon.png',
                              height: 30,
                              width: 30,
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Tooltip(
                                message: "You can scroll this text",
                                padding: EdgeInsets.all(6),
                                margin: EdgeInsets.all(10),
                                showDuration: Duration(seconds: 0),
                                decoration: BoxDecoration(
                                  color: Color(0xFF49454F),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5)),
                                ),
                                textStyle: TextStyle(color: Colors.white),
                                preferBelow: true,
                                child: Text(PDFName,
                                    style: const TextStyle(
                                      color: Color.fromRGBO(251, 253, 247, 1),
                                      fontFamily: 'Eczar',
                                      fontSize: 24,
                                    )),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4, top: 3),
                    child: SizedBox(
                        height: 20,
                        width: 18,
                        child: Material(
                            color: Colors.white.withOpacity(0.0),
                            child: InkWell(
                                key: Key("delete button ${PDFName}"),
                                onTap: () {
                                  setState(() {
                                    Analyzer.reportData.remove(PDFName);
                                    if (selected) {
                                      indexOfSelectedPDF = -1;
                                      mistakenSentenceList = null;
                                    }
                                  });
                                },
                                child: const Icon(
                                  Icons.clear_rounded,
                                  size: 19,
                                  color: Color.fromARGB(255, 215, 215, 215),
                                )))),
                  ),
                )
              ],
            )
            //
            ));
  }

  Widget UploadPDFButton() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 10),
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3,
                offset: Offset(1, 3),
                spreadRadius: 1,
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(40)),
          ),
          child: SizedBox(
            width: 170,
            child: ElevatedButton(
                onPressed: () async {
                  // uncomment to unmock
                  /*
                  List<PDFfile>? files = PdfAPI.getFilesTexts(await PdfAPI.selectFiles());
                  if (files == null) {
                    print("problem");
                  }
                  Map<String, List<List<SentencePart>>> mistakes = await Analyzer.getMistakes(files!);*/
                  // mocked beginning
                  List<dynamic> files = [];
                  final jsondata = await rootBundle.rootBundle
                      .loadString('../../../assets/json1');
                  files.add(jsondata);
                  Map<String, List<List<SentencePart>>> mistakes =
                      await Analyzer.getMistakes(files);
                  // mocked ending

                  setState(() {
                    Analyzer.reportData.addAll(mistakes);
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xFF4D6658),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                ),
                child: Row(
                  children: <Widget>[
                    Spacer(),
                    Text("Upload  ",
                        style: TextStyle(
                          color: Color.fromRGBO(251, 253, 247, 1),
                          fontFamily: 'Eczar',
                          fontSize: 25,
                          fontWeight: FontWeight.w100,
                        )),
                    Expanded(
                        child: Icon(
                      Icons.add_outlined,
                      size: 32,
                    )),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
