// ignore_for_file: public_member_api_docs, avoid_redundant_argument_values

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:phloura/definitions/globals.dart' as globals;
import 'package:phloura/l10n/app_localizations.dart';
import 'package:printing/printing.dart';

class Print extends StatefulWidget {
  const Print({
    super.key,
    required this.outlist,
    required this.dateSpan,
    required this.content,
  });
  final List<Map<String, dynamic>> outlist;
  final String content;
  final String dateSpan;

  @override
  State<Print> createState() => _PrintState();
}

class _PrintState extends State<Print> {
  final String title = ' ';
  String printDate = '';
  final List<Map<String, dynamic>> pdfList = [];

  @override
  void initState() {
    _getDate();
    _convertList();
    super.initState();
  }

  Future<void> _getDate() async {
    printDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _convertList() async {
    if (globals.origin == "NoteList") {
      String row = '';

      for (int i = 0; i < widget.outlist.length; i++) {
        row =
            '${widget.outlist[i]['date']} ${widget.outlist[i]['action']} ${widget.outlist[i]['vaxt']} ${widget.outlist[i]['place']}';

        pdfList.add({'rad': row});
      }
    } else {
      if (globals.origin == "Compilationlist") {
        String row = '';

        for (int i = 0; i < widget.outlist.length; i++) {
          row =
              '${widget.outlist[i]['date']} ${widget.outlist[i]['action']} ${widget.outlist[i]['vaxt']} ${widget.outlist[i]['place']}';

          pdfList.add({'rad': row});
        }
      } else {
        if (globals.origin == "PlantList") {
          String row = '';

          for (int i = 0; i < widget.outlist.length; i++) {
            row =
                '${widget.outlist[i]['vaxtName']} ${widget.outlist[i]['vaxtLatin']} ${widget.outlist[i]['vaxtText']}';

            pdfList.add({'rad': row});
          }
        } else {
          if (globals.origin == "Tasklist") {
            String row = '';

            for (int i = 0; i < widget.outlist.length; i++) {
              row = '${widget.outlist[i]['actionText']}';

              pdfList.add({'rad': row});
            }
          } else {
            if (globals.origin == "Placelist") {
              String row = '';

              for (int i = 0; i < widget.outlist.length; i++) {
                row = widget.outlist[i]['placeName'].toString();

                pdfList.add({'rad': row});
              }
            }
          }
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.yellow),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.yellow,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset('assets/phloura_logo.jpg'),
          ),
          title: Column(
            children: [
              Text(AppLocalizations.of(context)!.printappbartitle),
              //Text(widget.sortKey)
            ],
          ),
        ),
        body: PdfPreview(
          allowSharing: true,
          allowPrinting: true,
          canDebug: false,
          build: (format) => _generatePdf(format, pdfList),
        ),
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, pdfList) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final font = await PdfGoogleFonts.nunitoExtraLight();
    final customPageFormat = PdfPageFormat(
      PdfPageFormat.a4.width,
      PdfPageFormat.a4.height,
      marginTop: 10,
      marginBottom: 10,
      marginLeft: 20,
      marginRight: 10,
    );

    final image = await imageFromAssetBundle('assets/phloura_logo.jpg');
    const pageSize = 33;

    Map<int, List<pw.TableRow>> rows = {};

    final numberOfPages = (pdfList.length / pageSize).ceil();

    for (var page = 0; page < numberOfPages; page++) {
      rows[page] =
          /********************************** */
          [
            pw.TableRow(
              children: [
                pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Container(
                          alignment: pw.Alignment.centerLeft,
                          child: pw.SizedBox(
                            width: 100,
                            height: 20,
                            child: pw.Text(
                              'Phloura',
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ),
                        pw.Container(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text('Printed: $printDate'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Container(
                          alignment: pw.Alignment.centerLeft,
                          child: pw.SizedBox(
                            height: 100,
                            width: 100,
                            child: pw.Image(image),
                          ),
                        ),
                        pw.Column(
                          children: [
                            pw.Container(
                              height: 50,
                              width: 200,
                              alignment: pw.Alignment.center,
                              child: pw.Center(
                                child: pw.Text(
                                  widget.content,
                                  style: pw.TextStyle(
                                    fontSize: 20,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            pw.Container(
                              height: 50,
                              width: 300,
                              alignment: pw.Alignment.center,
                              child: pw.Center(child: pw.Text(widget.dateSpan)),
                            ),
                          ],
                        ),
                        pw.Container(
                          height: 100,
                          width: 100,
                          alignment: pw.Alignment.center,
                          child: pw.Center(child: pw.Text(' ')),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Container(
                          alignment: pw.Alignment.centerLeft,
                          child: pw.SizedBox(
                            width: 100,
                            height: 30,
                            child: pw.Text(
                              'A diary for your crops',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ),
                        pw.Container(
                          alignment: pw.Alignment.centerRight,
                          child: pw.SizedBox(
                            width: 100,
                            height: 20,
                            child: pw.Text('ASGOIT.SE'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Container(
                          alignment: pw.Alignment.centerLeft,
                          child: pw.SizedBox(height: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Container(
                          width: 1000,
                          height: 1,
                          padding: const pw.EdgeInsets.all(12.0),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                              color: PdfColors.black,
                              width: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Container(
                          alignment: pw.Alignment.centerLeft,
                          child: pw.SizedBox(height: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ];

      /******************************************************** */
      var loopLimit =
          pdfList.length - (pdfList.length - ((page + 1) * pageSize));

      if (loopLimit > pdfList.length) loopLimit = pdfList.length;

      for (var index = pageSize * page; index < loopLimit; index++) {
        rows[page]!.add(
          pw.TableRow(
            children: [
              pw.Text(
                pdfList[index].values.toString().replaceAll(
                  RegExp(r'\(|\)'),
                  '',
                ),
                style: pw.TextStyle(font: font, fontSize: 12),
              ),
            ],
          ),
        );
      }
    }
    /********************************************************* */
    pdf.addPage(
      pw.MultiPage(
        maxPages: 20,
        pageFormat: customPageFormat,
        build: (context) {
          return List<pw.Widget>.generate(rows.keys.length, (index) {
            return pw.Column(children: [pw.Table(children: rows[index]!)]);
          });
        },
      ),
    );

    return pdf.save();
  }
}
