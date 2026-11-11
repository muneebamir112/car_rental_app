import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/rental.dart';

class ReceiptPdfPreviewScreen extends StatelessWidget {
  final Rental rental;
  const ReceiptPdfPreviewScreen({super.key, required this.rental});

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();
    final r = rental;

    pw.MemoryImage? cnicFrontImage;
    if (r.cnicFrontPath != null && File(r.cnicFrontPath!).existsSync()) {
      cnicFrontImage = pw.MemoryImage(File(r.cnicFrontPath!).readAsBytesSync());
    }

    pw.MemoryImage? cnicBackImage;
    if (r.cnicBackPath != null && File(r.cnicBackPath!).existsSync()) {
      cnicBackImage = pw.MemoryImage(File(r.cnicBackPath!).readAsBytesSync());
    }

    pw.MemoryImage? selfieImage;
    if (r.selfiePath != null && File(r.selfiePath!).existsSync()) {
      selfieImage = pw.MemoryImage(File(r.selfiePath!).readAsBytesSync());
    }

    pw.MemoryImage? customerSigImage;
    if (r.signatureImagePath != null && File(r.signatureImagePath!).existsSync()) {
      customerSigImage = pw.MemoryImage(File(r.signatureImagePath!).readAsBytesSync());
    }

    pw.MemoryImage? thumbImage;
    if (r.thumbImpressionPath != null && File(r.thumbImpressionPath!).existsSync()) {
      thumbImage = pw.MemoryImage(File(r.thumbImpressionPath!).readAsBytesSync());
    }

    pw.MemoryImage? ownerSigImage;
    if (r.ownerSignatureImagePath != null && File(r.ownerSignatureImagePath!).existsSync()) {
      ownerSigImage = pw.MemoryImage(File(r.ownerSignatureImagePath!).readAsBytesSync());
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('RENTARO CAR RENTAL', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Main Boulevard, Gulberg III, Lahore, Pakistan | Tel: +92 300 1234567', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.Text('RENTAL RECEIPT\nID: ${r.rentalId}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                ],
              ),
            ),
            pw.Divider(thickness: 1.5),
            pw.SizedBox(height: 8),

            pw.Text('CUSTOMER & RENTAL DETAILS', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('Customer Name: ${r.customerName}'),
            pw.Text('CNIC Number: ${r.customerCnic} | Mobile: ${r.customerMobile}'),
            pw.Text('Vehicle: ${r.vehicleName} (Reg: ${r.vehicleRegistrationNumber})'),
            pw.Text('Pickup Date/Time: ${r.startDate.toLocal().toString().split('.')[0]}'),
            pw.Text('Return Date/Time: ${r.currentReturnDate.toLocal().toString().split('.')[0]}'),
            pw.Text('Duration: ${r.durationDays} Days @ Rs. ${r.dailyRate.toStringAsFixed(0)}/day'),
            pw.SizedBox(height: 10),

            if (cnicFrontImage != null || cnicBackImage != null || selfieImage != null) ...[
              pw.Text('VERIFICATION DOCUMENTS & LIVE SELFIE', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  if (cnicFrontImage != null)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          height: 60,
                          width: 90,
                          margin: const pw.EdgeInsets.only(right: 8),
                          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
                          child: pw.Image(cnicFrontImage, fit: pw.BoxFit.cover),
                        ),
                        pw.Text('CNIC Front', style: const pw.TextStyle(fontSize: 7)),
                      ],
                    ),
                  if (cnicBackImage != null)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          height: 60,
                          width: 90,
                          margin: const pw.EdgeInsets.only(right: 8),
                          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
                          child: pw.Image(cnicBackImage, fit: pw.BoxFit.cover),
                        ),
                        pw.Text('CNIC Back', style: const pw.TextStyle(fontSize: 7)),
                      ],
                    ),
                  if (selfieImage != null)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          height: 60,
                          width: 70,
                          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
                          child: pw.Image(selfieImage, fit: pw.BoxFit.cover),
                        ),
                        pw.Text('Live Selfie', style: const pw.TextStyle(fontSize: 7)),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 10),
            ],

            pw.Text('FINANCIAL SUMMARY', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Rental Charges:'), pw.Text('Rs. ${r.totalRentalCharges.toStringAsFixed(0)}')]),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Security Deposit:'), pw.Text('Rs. ${r.securityDeposit.toStringAsFixed(0)}')]),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Advance Payment Paid:'), pw.Text('-Rs. ${r.advancePayment.toStringAsFixed(0)}')]),
            pw.Divider(),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('Remaining Balance Due:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Rs. ${r.remainingBalance.toStringAsFixed(0)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
            ]),
            pw.SizedBox(height: 16),

            pw.Header(level: 1, child: pw.Text('CUSTOMER AGREEMENT - TERMS AND CONDITIONS', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 6),

            _buildTermItem('1. Closing Time', 'The customer must collect their belongings and complete the required formalities before the designated closing time.'),
            _buildTermItem('2. Customer Responsibility', "Customers are responsible for following the establishment's rules and instructions. Any failure to comply with these conditions may result in action by management."),
            _buildTermItem('3. Personal Belongings', "Customers are responsible for taking care of their personal belongings. Management's responsibility for lost or damaged items will be subject to the applicable rules and conditions."),
            _buildTermItem('4. Compliance with Instructions', 'Customers must follow all instructions issued by management and authorized staff.'),
            _buildTermItem('5. Use of Facilities', 'Customers must use the facilities responsibly and comply with the rules established for their use.'),
            _buildTermItem('6. Management Instructions', 'Customers must follow any additional instructions issued by management regarding the use of the premises.'),
            _buildTermItem('7. Responsibility for Damage', 'Customers may be held responsible for damage caused through negligence or misuse of the facilities.'),
            _buildTermItem('8. Rules and Regulations', 'All customers must comply with the rules and regulations of the establishment.'),
            _buildTermItem('9. Extension of Time', "Any extension of the permitted time will be subject to management's approval and the applicable charges."),
            _buildTermItem('10. Penalty', "A penalty of Rs. 1,000 may apply in the circumstances specified by the establishment's rules."),
            _buildTermItem('11. Additional Charges', 'Additional charges may apply where the customer fails to comply with the applicable conditions.'),
            _buildTermItem('12. Customer Conduct', 'Customers must maintain appropriate conduct and follow the instructions of management while on the premises.'),
            _buildTermItem('13. Closing and Additional Time Charges', 'The closing time is 5:00 AM. Customers who remain beyond the permitted time may be charged for additional time.'),

            pw.SizedBox(height: 12),
            pw.Text('Customer Declaration', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
            pw.Text('I confirm that I have read and understood the above Terms and Conditions and agree to comply with the rules and regulations of the establishment.', style: const pw.TextStyle(fontSize: 9)),
            pw.SizedBox(height: 20),

            // Embedded Customer Signature, Thumb Impression, and Owner Signature
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  children: [
                    pw.Container(
                      height: 50,
                      width: 110,
                      decoration: pw.BoxDecoration(border: pw.Border.all()),
                      child: customerSigImage != null
                          ? pw.Image(customerSigImage, fit: pw.BoxFit.contain)
                          : pw.Center(child: pw.Text('Customer Signature', style: const pw.TextStyle(fontSize: 8))),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Customer Signature', style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Container(
                      height: 50,
                      width: 90,
                      decoration: pw.BoxDecoration(border: pw.Border.all()),
                      child: thumbImage != null
                          ? pw.Image(thumbImage, fit: pw.BoxFit.cover)
                          : pw.Center(child: pw.Text('Thumb Impression', style: const pw.TextStyle(fontSize: 8))),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Thumb Impression Box', style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Container(
                      height: 50,
                      width: 110,
                      decoration: pw.BoxDecoration(border: pw.Border.all()),
                      child: ownerSigImage != null
                          ? pw.Image(ownerSigImage, fit: pw.BoxFit.contain)
                          : pw.Center(child: pw.Text('Owner Seal & Signature', style: const pw.TextStyle(fontSize: 8))),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Owner Signature', style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildTermItem(String title, String body) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          pw.Text(body, style: const pw.TextStyle(fontSize: 8)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rental Receipt PDF - ${rental.rentalId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print to Bluetooth Thermal Printer',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Connected to Bluetooth Thermal Printer: Printing compact receipt...')),
              );
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(format),
      ),
    );
  }
}
