import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:pdf/pdf.dart' as pdf;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:tabpos/screens/pdf_viewer_page.dart';

class SalesReportPage extends StatefulWidget {
  @override
  _SalesReportPageState createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  DateTime? fromDate;
  DateTime? toDate;


  void openPDF(BuildContext context, File file) => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PDFViewerPage(file: file)),
      );

  Future<void> _generateAndDownloadPdfReport() async {
  // Fetch transactions data based on the selected date range
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('transactions')
      .where('date', isGreaterThanOrEqualTo: fromDate.toString())
      .where('date', isLessThanOrEqualTo: toDate.toString())
      .get();

  List<Map<String, dynamic>> transactions = querySnapshot.docs
      .map((doc) => doc.data() as Map<String, dynamic>)
      .toList();

  // Check if transactions are found
  if (transactions.isEmpty) {
    // Show a message or handle the case where no transactions are found
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('No Transactions Found'),
          content: Text('There are no transactions for the selected date range.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
    return;
  }

  // Generate PDF report
  final pdfWidgets.Document pdfDocument = pdfWidgets.Document();
  pdfDocument.addPage(
    pdfWidgets.MultiPage(
      build: (context) => [
        pdfWidgets.Header(
          level: 0,
          text: 'Sales Report',
        ),
        pdfWidgets.Paragraph(text: 'From: ${fromDate.toString()}'),
        pdfWidgets.Paragraph(text: 'To: ${toDate.toString()}'),
        pdfWidgets.Table.fromTextArray(
          context: context,
          data: [
            ['Name', 'Quantity', 'Unit Price', 'Total Amount'],
            for (var transaction in transactions)
              ...transaction['products'].map((product) => [
                product['name'],
                product['quantity'].toString(),
                'ZMK ${product['unitPrice']}',
                'ZMK ${product['totalAmount']}',
              ]),
          ],
        ),
        pdfWidgets.Paragraph(text: ''),
        pdfWidgets.Paragraph(text: 'Total Gain From above Sales: ZMK ${transactions.fold<double>(0.0, (sum, transaction) => sum + transaction['totalPrice'])}'),
        // Add other information or widgets as needed
      ],
    ),
  );

  // Save the PDF report to a file
  final output = await getTemporaryDirectory();
  final outputFile = File('${output.path}/report.pdf');
  await outputFile.writeAsBytes(await pdfDocument.save());

  // Show a confirmation dialog for successful generation
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('PDF Report Generated'),
        content: Text('The PDF sales report has been generated and saved successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openPDF(context, outputFile);
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Sales Reports'),
        centerTitle: true, // Center the title
        backgroundColor: Color.fromARGB(255, 65, 84, 146),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Select From Date'),
            subtitle: fromDate != null ? Text(fromDate!.toString()) : null,
            onTap: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: fromDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );

              if (pickedDate != null && pickedDate != fromDate) {
                setState(() {
                  fromDate = pickedDate;
                });
              }
            },
          ),
          ListTile(
            title: Text('Select To Date'),
            subtitle: toDate != null ? Text(toDate!.toString()) : null,
            onTap: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: toDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );

              if (pickedDate != null && pickedDate != toDate) {
                setState(() {
                  toDate = pickedDate;
                });
              }
            },
          ),
          ElevatedButton(
            onPressed: (fromDate != null && toDate != null)
                ? _generateAndDownloadPdfReport
                : null,
            child: Text('Generate and Download PDF Report'),
          ),
        ],
      ),
    );
  }
}
