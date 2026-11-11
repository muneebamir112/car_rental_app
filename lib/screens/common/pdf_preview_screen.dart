import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/rental_application.dart';

class PdfPreviewScreen extends StatelessWidget {
  final RentalApplication application;
  const PdfPreviewScreen({super.key, required this.application});

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();
    final app = application;

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('RENTARO RENT-A-CAR AGREEMENT', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text('ID: ${app.applicationId}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                ],
              ),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 10),
              pw.Text('Customer Information', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text('Full Name: ${app.fullName} (Father: ${app.fatherName})'),
              pw.Text('CNIC: ${app.cnicNumber} | Mobile: ${app.mobileNumber}'),
              pw.Text('Address: ${app.residentialAddress}, ${app.city}'),
              pw.SizedBox(height: 10),
              pw.Text('Driving Licence Details', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text('Licence No: ${app.licenceNumber} | Authority: ${app.licenceIssuingAuthority}'),
              pw.Text('Category: ${app.licenceCategory} | Expiry: ${app.licenceExpiryDate}'),
              pw.SizedBox(height: 10),
              pw.Text('Vehicle & Rental Details', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text('Vehicle: ${app.vehicleName} (${app.vehicleRegistrationNumber})'),
              pw.Text('Duration: ${app.rentalDurationDays} Days (${app.pickupDateTime.toString().split(' ')[0]} to ${app.returnDateTime.toString().split(' ')[0]})'),
              pw.Text('Pickup: ${app.pickupLocation}'),
              pw.Text('Drop-off: ${app.dropOffLocation}'),
              pw.SizedBox(height: 10),
              pw.Text('Financial Summary', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text('Daily Rate: \$${app.dailyRate} | Security Deposit: \$${app.securityDeposit}'),
              pw.Text('Total Estimated Charges: \$${app.totalEstimatedCharges}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Terms & Conditions accepted by customer on ${app.submissionDate}.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
              pw.Spacer(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(children: [
                    pw.Container(height: 40, width: 100, decoration: pw.BoxDecoration(border: pw.Border.all())),
                    pw.SizedBox(height: 4),
                    pw.Text('Customer Signature'),
                  ]),
                  pw.Column(children: [
                    pw.Container(height: 40, width: 100, decoration: pw.BoxDecoration(border: pw.Border.all())),
                    pw.SizedBox(height: 4),
                    pw.Text('Authorized Admin Seal'),
                  ]),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agreement PDF - ${application.applicationId}')),
      body: PdfPreview(
        build: (format) => _generatePdf(format),
      ),
    );
  }
}
