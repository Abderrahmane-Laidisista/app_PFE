/// 6-Class Thesis Taxonomy for Dermatological Lesion Diagnosis.
enum LesionType {
  mel, // Melanoma
  bcc, // Basal Cell Carcinoma
  scc, // Squamous Cell Carcinoma
  ack, // Actinic Keratosis
  nev, // Melanocytic Nevus
  sek, // Seborrheic Keratosis
  unknown,
}

class LesionClass {
  final String code;
  final String fullNameEn;
  final String fullNameFr;
  final String fullNameAr;
  final String category;
  final String defaultRiskLevel;

  const LesionClass({
    required this.code,
    required this.fullNameEn,
    required this.fullNameFr,
    required this.fullNameAr,
    required this.category,
    required this.defaultRiskLevel,
  });

  static const List<LesionClass> all = [
    LesionClass(
      code: 'MEL',
      fullNameEn: 'Melanoma',
      fullNameFr: 'Mélanome Malin',
      fullNameAr: 'الورم الميلانيني الخبيث',
      category: 'Malignant',
      defaultRiskLevel: 'CRITICAL',
    ),
    LesionClass(
      code: 'BCC',
      fullNameEn: 'Basal Cell Carcinoma',
      fullNameFr: 'Carcinome Basocellulaire',
      fullNameAr: 'سرطان الخلايا القاعدية',
      category: 'Malignant',
      defaultRiskLevel: 'HIGH',
    ),
    LesionClass(
      code: 'SCC',
      fullNameEn: 'Squamous Cell Carcinoma',
      fullNameFr: 'Carcinome Spinocellulaire',
      fullNameAr: 'سرطان الخلايا الحرشفية',
      category: 'Malignant',
      defaultRiskLevel: 'HIGH',
    ),
    LesionClass(
      code: 'ACK',
      fullNameEn: 'Actinic Keratosis',
      fullNameFr: 'Kératose Actinique',
      fullNameAr: 'التقران السفعي',
      category: 'Pre-malignant',
      defaultRiskLevel: 'MODERATE',
    ),
    LesionClass(
      code: 'NEV',
      fullNameEn: 'Melanocytic Nevus',
      fullNameFr: 'Naevus Mélanocytaire (Grain de beauté)',
      fullNameAr: 'شامة صبغية حميدة',
      category: 'Benign',
      defaultRiskLevel: 'LOW',
    ),
    LesionClass(
      code: 'SEK',
      fullNameEn: 'Seborrheic Keratosis',
      fullNameFr: 'Kératose Séborrhéique',
      fullNameAr: 'التقران الزهمي الحميد',
      category: 'Benign',
      defaultRiskLevel: 'LOW',
    ),
  ];

  static LesionClass fromCode(String code) {
    final upper = code.toUpperCase().trim();
    return all.firstWhere(
      (element) => element.code == upper,
      orElse: () => const LesionClass(
        code: 'UNKNOWN',
        fullNameEn: 'Unspecified Lesion',
        fullNameFr: 'Lésion non spécifiée',
        fullNameAr: 'آفة غير محددة',
        category: 'Atypical',
        defaultRiskLevel: 'INCONCLUSIVE',
      ),
    );
  }
}
