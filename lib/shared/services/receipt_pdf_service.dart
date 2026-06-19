import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/appointment.dart';
import '../models/doctor.dart';

class ReceiptPdfService {
  const ReceiptPdfService._();

  static Future<Uint8List> build({
    required Appointment appointment,
    required Doctor doctor,
  }) async {
    final pdf = pw.Document();
    final createdAt = DateFormat('MMM d, yyyy').format(appointment.createdAt);
    final visitDate = DateFormat('MMM d, yyyy').format(appointment.date);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'MedLink Receipt',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue700,
                    ),
                  ),
                  pw.Text(createdAt),
                ],
              ),
              pw.SizedBox(height: 24),
              _line('Receipt ID', appointment.id),
              _line('Patient', appointment.patientName),
              _line('Doctor', doctor.name),
              _line('Specialty', doctor.specialty),
              _line('Consultation Type', appointment.consultationType),
              _line('Date & Time', '$visitDate, ${appointment.timeSlot}'),
              _line('Payment Method', appointment.paymentMethod),
              _line('Payment Status', appointment.paymentStatus),
              pw.Divider(height: 32),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Rs.${appointment.fee}',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.Spacer(),
              pw.Text(
                'Thank you for using MedLink.',
                style: const pw.TextStyle(color: PdfColors.grey700),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _line(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 130,
            child: pw.Text(
              label,
              style: const pw.TextStyle(color: PdfColors.grey700),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
