import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import '../../data/models/patient_metadata.dart';
import '../../data/models/prediction_response.dart';

class PdfService extends GetxService {
  Future<PdfService> init() async {
    return this;
  }

  Future<void> generateAndShareReport({
    required PredictionResponse result,
    required PatientMetadata metadata,
    required String? imagePath,
  }) async {
    try {
      final pdf = pw.Document();

      // Read image if provided
      pw.ImageProvider? pdfImage;
      if (imagePath != null && File(imagePath).existsSync()) {
        final imageFile = File(imagePath);
        final imageBytes = await imageFile.readAsBytes();
        pdfImage = pw.MemoryImage(imageBytes);
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              _buildHeader(),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              _buildPatientInfo(metadata),
              pw.SizedBox(height: 30),
              _buildDiagnosisSection(result, pdfImage),
              pw.SizedBox(height: 30),
              if (result.allProbabilities.isNotEmpty)
                _buildProbabilities(result.allProbabilities),
              pw.SizedBox(height: 40),
              _buildFooter(),
            ];
          },
        ),
      );

      // Save to temp directory
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/MedAssist_Report_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      // Share standard file
      final xFile = XFile(file.path);
      await Share.shareXFiles([xFile], text: 'MedAssist AI - Clinical Diagnostic Report');
    } catch (e) {
      print('Error generating PDF: $e');
      throw e;
    }
  }

  pw.Widget _buildHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'MedAssist AI',
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.Text(
              'Clinical Diagnostic Report',
              style: pw.TextStyle(
                fontSize: 16,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'Date: ${DateTime.now().toString().split(' ')[0]}',
              style: const pw.TextStyle(
                fontSize: 12,
              ),
            ),
            pw.Text(
              'Ref: MA-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
              style: const pw.TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPatientInfo(PatientMetadata metadata) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _infoItem('Age', metadata.age?.toString() ?? 'N/A'),
          _infoItem('Sex', metadata.sex.toUpperCase()),
          _infoItem('Lesion Site', metadata.region.toUpperCase()),
        ],
      ),
    );
  }

  pw.Widget _infoItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
        pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
      ],
    );
  }

  pw.Widget _buildDiagnosisSection(PredictionResponse result, pw.ImageProvider? image) {
    PdfColor riskColor;
    switch (result.riskLevel.toUpperCase()) {
      case 'CRITICAL':
      case 'CRITIQUE':
        riskColor = PdfColors.purple700;
        break;
      case 'HIGH':
      case 'ÉLEVÉ':
        riskColor = PdfColors.red700;
        break;
      case 'MODERATE':
      case 'MODÉRÉ':
        riskColor = PdfColors.orange500;
        break;
      case 'LOW':
      case 'FAIBLE':
        riskColor = PdfColors.green600;
        break;
      default:
        riskColor = PdfColors.grey500;
    }

    // Mapping codes to full names for PDF (English)
    final labelMap = {
      'MEL': 'Melanoma',
      'BCC': 'Basal Cell Carcinoma',
      'SCC': 'Squamous Cell Carcinoma',
      'ACK': 'Actinic Keratosis',
      'NEV': 'Melanocytic Nevus',
      'SEK': 'Seborrheic Keratosis'
    };
    final fullDiagnosis = labelMap[result.predictedClass] ?? result.predictedClass;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (image != null)
          pw.Container(
            width: 150,
            height: 150,
            decoration: pw.BoxDecoration(
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
              border: pw.Border.all(color: PdfColors.grey300),
              image: pw.DecorationImage(image: image, fit: pw.BoxFit.cover),
            ),
          )
        else
          pw.Container(
            width: 150,
            height: 150,
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
            ),
            child: pw.Center(child: pw.Text('No Image Provided', style: const pw.TextStyle(color: PdfColors.grey500))),
          ),
        pw.SizedBox(width: 30),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('AI DIAGNOSIS', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text(fullDiagnosis, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
              pw.SizedBox(height: 16),
              pw.Text('RISK ASSESSMENT', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: pw.BoxDecoration(color: riskColor, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
                child: pw.Text(
                  result.riskLevel.toUpperCase(),
                  style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 14),
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text('CONFIDENCE SCORE', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text(
                '${(result.confidence * 100).toStringAsFixed(1)}%',
                style: pw.TextStyle(fontSize: 18, color: PdfColors.blueGrey800, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildProbabilities(Map<String, dynamic> probabilities) {
    final sorted = probabilities.entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('DIFFERENTIAL DIAGNOSIS (AI Probabilities)',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 12),
        ...sorted.map((e) {
          final val = (e.value as num).toDouble();
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Row(
              children: [
                pw.SizedBox(
                  width: 50,
                  child: pw.Text(e.key, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                ),
                pw.Expanded(
                  child: pw.Container(
                    height: 8,
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Container(
                      width: 300 * val, // Approximate max width
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue500,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.SizedBox(
                  width: 40,
                  child: pw.Text('${(val * 100).toStringAsFixed(1)}%', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(),
        pw.SizedBox(height: 8),
        pw.Text(
          'DISCLAIMER: This report is generated by MedAssist AI. It is an auxiliary diagnostic tool and should NOT replace professional medical advice. A certified dermatologist should evaluate all concerning skin lesions.',
          style: pw.TextStyle(fontSize: 9, color: PdfColors.red700, fontStyle: pw.FontStyle.italic),
        ),
      ],
    );
  }
}
