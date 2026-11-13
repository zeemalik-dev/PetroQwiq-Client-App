// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:pdf/pdf.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart' as pdf;
// import 'package:flutter/services.dart' show rootBundle;
// import 'dart:typed_data';
// import 'dart:html' as html;
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:open_file/open_file.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

// class ProductInventoryTransferSlip extends StatefulWidget {
//   // final List<Data(transferProduct)> selectedFuelType=[];
//   final String stagingArea = ''; 
//   @override
//   _ProductInventoryTransferSlipState createState() =>
//       _ProductInventoryTransferSlipState();
// }

// class _ProductInventoryTransferSlipState
//     extends State<ProductInventoryTransferSlip> {
//   final List<Map<String, String>> products = [
//     {'name': 'Diesel', 'quantity': '1000', 'type': 'Liters'},
//     {'name': 'Biodiesel', 'quantity': '1000', 'type': 'Liters'},
//     {'name': 'Engine Oil', 'quantity': '500', 'type': 'Pales'},
//   ];
//   int totalLiters = 0;
//   int totalPales = 0;
//   String formattedDate =
//       DateFormat('MMMM d, yyyy').format(DateTime.now()); // AUGUST 1, 2025
//   String formattedTime = DateFormat('h:mm a').format(DateTime.now()); // 9:56 AM

//   @override
//   void initState() {
//     super.initState(); // Always call super first

//     // Fetch data from an API when the widget is initialized
//     for (var product in products) {
//       if (product['type'] == 'Liters' || product['type'] == 'Fuel') {
//         totalLiters += int.parse(product['quantity']!);
//       } else if (product['type'] == 'Pales' || product['type'] == 'Lube') {
//         totalPales += int.parse(product['quantity']!);
//       }
//     }
//   }

//   Future<void> _generatePDF() async {
//     final pdf = pw.Document();

//     // Load the image asynchronously
//     final imageProvider = await _loadImage('assets/Layer_1.png');

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               _buildPdfHeader(imageProvider),
//               pw.SizedBox(height: 20),
//               _buildPdfTable(),
//               pw.SizedBox(height: 20),
//               _buildPdfFooter(),
//               pw.SizedBox(height: 50),
//               _buildPdfSignatures(),
//             ],
//           );
//         },
//       ),
//     );

//     final Uint8List bytes = await pdf.save();

//     if (kIsWeb) {
//       final blob = html.Blob([bytes], 'application/pdf');
//       final url = html.Url.createObjectUrlFromBlob(blob);
//       html.window.open(url, '_blank');
//       html.Url.revokeObjectUrl(url);
//     } else {
//       final String path = (await getApplicationDocumentsDirectory()).path;
//       final File file = File('$path/Inventory_Transfer.pdf');
//       await file.writeAsBytes(bytes, flush: true);
//       OpenFile.open(file.path);
//     }
//   }

//   pw.Widget _buildPdfHeader(pw.MemoryImage imageProvider) {
//     return pw.Row(
//       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         // Left Column - Text Information
//         pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Text('Product Inventory Transfer',
//                 style:
//                     pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
//             pw.SizedBox(height: 10),
//             pw.Text('TRANSFER',
//                 style:
//                     pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
//             _buildPdfDetailRow('TRANSFER ID:', 'TS-002'),
//             _buildPdfDetailRow('PRODUCT TYPE:', 'FUEL & LUBE'),
//             _buildPdfDetailRow('STAGING LOCATION:', 'PASAY CITY'),
//             pw.SizedBox(height: 10),
//             pw.Text('TANKER',
//                 style:
//                     pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
//             _buildPdfDetailRow('DRIVER NAME:', 'JOHN DOE'),
//             _buildPdfDetailRow('TANKER MODEL:', 'ISUZU 10,000'),
//             _buildPdfDetailRow('PLATE NUMBER:', '1233 AGS'),
//           ],
//         ),

//         // Right Column - Image
//         pw.Column(
//           children: [
//             pw.Container(
//               width: 126.99,
//               height: 71.18,
//               child: pw.Image(
//                 imageProvider,
//                 fit: pw.BoxFit.cover,
//                 alignment: pw.Alignment.center,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   /// ✅ Function to Load Image from Assets as `pw.MemoryImage`
//   Future<pw.MemoryImage> _loadImage(String path) async {
//     final ByteData data = await rootBundle.load(path);
//     final Uint8List bytes = data.buffer.asUint8List();
//     return pw.MemoryImage(bytes);
//   }

//   pw.Widget _buildPdfDetailRow(String title, String value) {
//     return pw.Padding(
//       padding: pw.EdgeInsets.symmetric(vertical: 2.0),
//       child: pw.Text('$title $value',
//           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.normal)),
//     );
//   }

//   pw.Widget _buildPdfTable() {
//     return pw.Table.fromTextArray(
//       border: pw.TableBorder.all(),
//       headers: [
//         'Product Name',
//         'Quantity',
//       ],
//       data: [
//         for (var product in products) ...[
//           [
//             product['name'],
//             '${product['quantity']}  ${product['type']}',
//           ]
//         ],
//         [
//           'Total',
//           '${totalLiters.toString()} Liters Fuel | ${totalPales.toString()} Pale Lube'
//         ],
//       ],
//       headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//       cellAlignment: pw.Alignment.centerLeft,
//     );
//   }

//   pw.Widget _buildPdfFooter() {
//     return pw.Container(
//       width: 350,
//       decoration: pw.BoxDecoration(
//         border: pw.Border.all(color: PdfColors.grey),
//         borderRadius: pw.BorderRadius.circular(8),
//         color: PdfColors.grey300,
//       ),
//       padding: pw.EdgeInsets.all(16),
//       child: pw.Row(
//         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//         children: [
//           pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text('DATE LIFTED',
//                   style: pw.TextStyle(
//                       fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
//               pw.Text('DATE: ${formattedDate}',
//                   style: pw.TextStyle(color: PdfColors.black)),
//               pw.Text('TIME: ${formattedTime}',
//                   style: pw.TextStyle(color: PdfColors.black)),
//             ],
//           ),
//           pw.Container(
//             height: 40,
//             width: 1,
//             color: PdfColors.grey,
//           ),
//           pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text('DATE RECEIVED',
//                   style: pw.TextStyle(
//                       fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
//               pw.SizedBox(height: 5),
//               pw.Row(
//                 children: [
//                   pw.Text('DATE: '),
//                   pw.Container(
//                     width: 100,
//                     child: pw.Divider(color: PdfColors.black, thickness: 1),
//                   ),
//                 ],
//               ),
//               pw.SizedBox(height: 5),
//               pw.Row(
//                 children: [
//                   pw.Text('TIME: '),
//                   pw.Container(
//                     width: 100,
//                     child: pw.Divider(color: PdfColors.grey, thickness: 1),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   pw.Widget _buildPdfSignatures() {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.center,
//       children: [
//         _pdfSignatureField('Site Manager Signature'),
//         pw.SizedBox(height: 100),
//         pw.Row(
//           mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
//           children: [
//             _pdfSignatureField('Driver Signature'),
//             _pdfSignatureField('Authorized Receiver Signature'),
//             _pdfSignatureField('Site Guard'),
//           ],
//         ),
//         pw.SizedBox(height: 10),
//       ],
//     );
//   }

//   pw.Widget _pdfSignatureField(String title) {
//     return pw.Column(
//       children: [
//         pw.Container(height: 2, width: 131, color: PdfColors.black),
//         pw.SizedBox(height: 10),
//         pw.Text(title, style: pw.TextStyle(fontSize: 12)),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildHeader(),
//               SizedBox(height: 20),
//               _buildProductTable(),
//               SizedBox(height: 20),
//               _buildFooter(context),
//               SizedBox(height: 40),
//               _buildSignatures(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Product Inventory Transfer',
//                 style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                     fontSize: 20)),
//             SizedBox(height: 10),
//             _buildDetailRow('TRANSFER', '', isTitle: true),
//             _buildDetailRow('TRANSFER ID:', 'TS-002'),
//             _buildDetailRow('PRODUCT TYPE:', 'FUEL & LUBE'),
//             _buildDetailRow('STAGING LOCATION:', 'PASAY CITY'),
//             SizedBox(height: 10),
//             _buildDetailRow('TANKER', '', isTitle: true),
//             _buildDetailRow('DRIVER NAME:', 'JOHN DOE'),
//             _buildDetailRow('TANKER MODEL:', 'ISUZU 10,000'),
//             _buildDetailRow('PLATE NUMBER:', '1233 AGS'),
//           ],
//         ),
//         Column(
//           children: [
//             Image.asset(
//               'assets/Layer_1.png',
//               width: 126.99,
//               height: 71.18,
//               fit: BoxFit.cover,
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             IconButton(
//               icon: Icon(Icons.file_download_outlined,
//                   color: Colors.grey, size: 40),
//               onPressed: _generatePDF,
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildProductTable() {
//     return Table(
//       border: TableBorder.all(color: Colors.black),
//       columnWidths: {
//         0: FlexColumnWidth(2),
//         1: FlexColumnWidth(1),
//       },
//       children: [
//         _buildTableRow('Product Name', 'Quantity', isHeader: true),
//         for (var product in products) ...[
//           _buildTableRow(
//               product['name']!, product['quantity']! + ' ' + product['type']!),
//         ],
//         _buildTableRow(
//           'Total',
//           // '${products.fold<int>(0, (sum, item) => sum + int.parse(item['quantity']!))}'

//           '${totalLiters.toString()} Liters Fuel | ${totalPales.toString()} Pale Lube',
//         )
//       ],
//     );
//   }

//   TableRow _buildTableRow(String col1, String col2, {bool isHeader = false}) {
//     return TableRow(
//       decoration: BoxDecoration(
//         color: isHeader ? Colors.grey.shade300 : Colors.white,
//       ),
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text(col1,
//               style: TextStyle(
//                   fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text(col2,
//               style: TextStyle(
//                   fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
//         ),
//       ],
//     );
//   }

//   Widget _buildDetailRow(String title, String value, {bool isTitle = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2.0),
//       child: Text(
//         '$title $value',
//         style: TextStyle(
//           fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
//           color: Colors.black,
//         ),
//       ),
//     );
//   }

//   Widget _buildFooter(context) {
//     return Container(
//       width: MediaQuery.of(context).size.width * .60,
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade400),
//         borderRadius: BorderRadius.circular(8.0),
//         color: Colors.grey.shade100,
//       ),
//       padding: EdgeInsets.all(16.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('DATE LIFTED',
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold, color: Colors.black)),
//               Text('DATE: ${formattedDate}',
//                   style: TextStyle(color: Colors.black)),
//               Text('TIME: ${formattedTime}',
//                   style: TextStyle(color: Colors.black)),
//             ],
//           ),
//           Container(
//             height: 40,
//             width: 1,
//             color: Colors.grey,
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('DATE RECEIVED',
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold, color: Colors.black)),
//               Row(
//                 children: [
//                   Text('DATE: '),
//                   Container(
//                     width: 100,
//                     child: Divider(color: Colors.black, thickness: 1),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Text('TIME: '),
//                   Container(
//                     width: 100,
//                     child: Divider(color: Colors.grey, thickness: 1),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSignatures() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         _buildSignatureField('Site Manager Signature'),
//         const SizedBox(height: 50),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildSignatureField('Driver Signature'),
//             _buildSignatureField('Authorized Receiver Signature'),
//             _buildSignatureField('Site Guard'),
//           ],
//         ),
//         const SizedBox(height: 20),
//       ],
//     );
//   }

//   Widget _buildSignatureField(String title) {
//     return Column(
//       children: [
//         Container(height: 2, color: Colors.black, width: 131),
//         SizedBox(height: 10),
//         Text(title),
//       ],
//     );
//   }
// }
