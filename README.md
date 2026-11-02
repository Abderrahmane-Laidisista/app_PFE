# MedAssist AI — Clinical Mobile Client (Flutter V2.0)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B.svg?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2.svg?logo=dart&logoColor=white)](https://dart.dev)
[![GetX](https://img.shields.io/badge/GetX-State_Management-8A2BE2.svg)](https://pub.dev/packages/get)
[![Architecture](https://img.shields.io/badge/Architecture-Clean_Architecture-green.svg)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A cross-platform Flutter application engineered for clinical practitioners, general practitioners, and dermatologists to perform automated multimodal skin lesion screening, clinical triage, tele-dermatology referrals, and follow-up tracking.

> **Academic & Innovation Context**: Developed within the framework of Master 2 Software Engineering (GLAA) and the Algerian Ministerial Decree 1275 (*Un diplôme... une startup / un brevet*).

---

## 📱 Key Features (V2.0)

### 1. Clinical Dermoscopy & Multimodal Capture
* High-resolution camera capture with dermoscope lens attachment support and device gallery import.
* Synchronized input form collecting 7 critical clinical parameters: Patient Age, Biological Sex, Anatomical Site, Lesion Growth History (`grew`), Bleeding History (`bleed`), Diameter (`diameter_1`), Personal Skin Cancer History, and Lesion Elevation (`elevation`).

### 2. Deep Learning Inference & Explainable AI
* Asynchronous multipart transmission to the MedAssist AI V6.0 neural network with 90-second timeout resilience.
* Softmax confidence probability distribution across 6 diagnostic classes:
  * **NEV** (Nevus)
  * **SEK** (Seborrheic Keratosis)
  * **ACK** (Actinic Keratosis)
  * **BCC** (Basal Cell Carcinoma)
  * **SCC** (Squamous Cell Carcinoma)
  * **MEL** (Melanoma)
* **Grad-CAM visual saliency heatmaps** showing region-of-interest activation maps explaining the neural network's diagnostic focus.

### 3. 5-Tier Clinical Triage & Risk Stratification
Dynamic color-coded risk assessment matching official clinical guidelines:
* 🟢 **LOW Risk** (`#10b981`): Benign lesions (Nevus, Seborrheic Keratosis).
* 🟡 **MODERATE Risk** (`#f59e0b`): Pre-malignant lesions (Actinic Keratosis).
* 🔴 **HIGH Risk** (`#ef4444`): Malignant non-melanoma carcinomas (BCC, SCC).
* 🟣 **CRITICAL Risk** (`#7c3aed`): Highly aggressive malignant Melanoma requiring urgent surgical triage.
* ⚪ **UNKNOWN Risk**: Low confidence or unclassified observations.

### 4. Telemedicine & Second-Opinion Workflow
* Clinician case referrals enabling primary care physicians to request second opinions from verified dermatologists.
* Referral tracking with status badges (`PENDING`, `ACCEPTED`, `REJECTED`, `COMPLETED`).

### 5. Clinician Authentication & Security Lifecycle
* JWT-based secure authentication with automatic access token rotation.
* **Mandatory Force Password Change**: Automatically prompts newly onboarded doctors to replace their initial temporary password on first login.
* Biometric authentication integration and local session termination (Logout with refresh token invalidation).

### 6. Clinical PDF Report & QR Verification
* Generates formatted, high-fidelity PDF medical diagnostic reports on-device.
* Embeds unique QR verification tokens allowing external auditors or patients to securely verify report authenticity.
* Native system sharing via `share_plus`.

### 7. Offline-First Resilience & Multilingual UI
* Local offline analysis cache (`GetStorage`) allowing clinicians to review past patient timelines without an active internet connection.
* Dynamic internationalization supporting **Arabic (`ar`)**, **French (`fr`)**, and **English (`en`)** with typographic optimization via the `Cairo` font family.

---

## 🏛️ Clean Architecture & Directory Structure

The application strictly follows **Clean Architecture** combined with the **GetX Pattern** to maintain separation of concerns:

```
lib/
├── app/
│   ├── config/              # Colors, dark/light themes, and API route constants
│   ├── routes/              # Named GetX routing and page bindings
│   └── translations/        # Multilingual localization dictionaries (ar, fr, en)
├── core/
│   └── services/            # Core singletons: ApiService, StorageService, PdfService
├── data/
│   ├── models/              # DTOs: PatientMetadata, PredictionResponse, User, Referral
│   └── providers/           # Remote and local data abstraction
├── global_widgets/          # Reusable UI widgets: buttons, cards, dialogs, badges
└── modules/                 # Feature modules (View + Controller + Binding)
    ├── splash/              # Animated brand launcher
    ├── onboarding/          # Feature introduction carousel
    ├── auth/                # Login, registration, and force change password
    ├── home/                # Clinical dashboard and quick actions
    ├── clinical_form/       # 7+1 variable clinical data entry form
    ├── camera/              # Camera viewfinder with guidelines
    ├── analysis/            # Asynchronous inference progress screen
    ├── result/              # Diagnostic visualization, Grad-CAM, & PDF export
    ├── history/             # Offline patient analysis cache & search
    ├── telemedicine/        # Specialist referral requests and responses
    └── settings/            # API server endpoint configuration and language toggle
```

---

## 💻 Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.11.1` or newer)
* [Android Studio](https://developer.android.com/studio) / Xcode for emulator or physical device deployment

### Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Abderrahmane-Laidisista/app_PFE_frontend.git
   cd app_PFE_frontend
   ```

2. **Install Flutter packages**:
   ```bash
   flutter pub get
   ```

3. **Configure API Endpoint**:
   * Open the app and navigate to **Settings** -> **API URL**, or edit the default URL in `lib/app/config/api/api_constants.dart`:
     * **Android Emulator**: `http://10.0.2.2:8000/api/v1`
     * **Physical Device (LAN)**: `http://<YOUR_COMPUTER_LOCAL_IP>:8000/api/v1`
     * **Cloudflare Tunnel / Production**: `https://<YOUR-TUNNEL>.trycloudflare.com/api/v1`

4. **Run the Application**:
   ```bash
   flutter run
   ```

---

## 🔬 Static Analysis & Code Quality

To verify syntax balance and lint compliance:
```bash
flutter analyze
```

All 134 Dart source files pass structural and syntax balance checks with 0 broken imports.

---

## ⚖️ License & Medical Disclaimer

This project is licensed under the [MIT License](LICENSE).

> **⚠️ Medical Decision Support Disclaimer**:  
> MedAssist AI is designed exclusively as an assistive decision support tool for medical professionals. Algorithmic outputs must always be evaluated in conjunction with comprehensive clinical correlation and histopathological examination.
