# MedAssist AI — Mobile Client (Flutter Frontend)

Welcome to the **MedAssist AI** mobile client! This is a cross-platform Flutter application built to interface with the **MedAssist AI V6.0** deep learning diagnostic backend. It is designed to assist clinical practitioners with automated skin lesion categorization and rapid clinical risk screening.

---

## 🚀 Key Features

*   **Dermoscopy Capture & Upload**: Interface with mobile camera lenses or pick high-resolution images from the device gallery.
*   **Clinical Metadata Processing**: Collects critical diagnostic parameters including Age, Biological Sex, Anatomical Site, Lesion Growth, Bleeding History, Diameter, Personal Skin Cancer History, and Elevation.
*   **Real-time Multimodal Inference**: Submits image binaries alongside the clinical vector to the FastAPI backend with extended resilience settings (90-second timeout).
*   **Diagnostic Breakdown Visualization**: Visualizes softmax confidence scores across all 6 diagnostic classes (NEV, SEK, ACK, BCC, SCC, MEL).
*   **Clinical Risk Scoring**: Dynamically evaluates risk categories (`LOW`, `MODERATE`, `HIGH`, `CRITICAL`) with color-coded safety indicators.
*   **PDF Report Generation**: Exports patient information and predictive risk diagnostics into formatted PDF reports for clinical tracking and offline sharing.
*   **Local Offline History**: Saves historical analyses locally on the device utilizing `GetStorage`.

---

## 🛠️ Technology Stack & Dependencies

*   **SDK**: `Flutter (Dart SDK ^3.11.1)`
*   **State Management & DI**: `GetX (^4.6.6)`
*   **Local Storage**: `GetStorage (^2.1.1)`
*   **HTTP Client**: `http (^1.2.0)`
*   **Hardware Interface**: `camera (^0.12.0)` & `image_picker (^1.2.1)`
*   **Report Compilation**: `pdf (^3.11.1)` & `share_plus (^10.1.2)`
*   **Typography**: `Cairo` font family for Arabic/Latin UI clarity

---

## 📂 Repository Architecture

The project adheres to the **Clean Architecture / GetX Pattern**:

```
lib/
├── app/
│   ├── config/          # Dark/Light themes, color styles, and layouts
│   ├── routes/          # Application routes and page bindings
│   └── translations/    # Localization/translation files (AR, FR, EN)
├── core/
│   └── services/        # Singleton services (API, Storage, Connectivity, PDF)
├── data/
│   └── models/          # Serialization schemas (PatientMetadata, PredictionResponse)
├── global_widgets/      # Shared custom UI widgets
└── modules/             # UI Modules (Views, Controllers, Bindings)
    ├── splash/          # Custom branding screen
    ├── home/            # Primary dashboard
    ├── clinical_form/   # Multi-variable input form
    ├── camera/          # Custom camera layer
    ├── result/          # Diagnostics & PDF compiler
    ├── history/         # Offline query cache
    └── settings/        # Host config & preferences
```

---

## 💻 Getting Started

### Prerequisites
Make sure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.

### Setup Instructions
1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/Abderrahmane-Laidisista/app_PFE.git
    cd app_PFE
    ```
2.  **Fetch Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the Project**:
    ```bash
    flutter run
    ```

---

## 🔄 Recent Backend V6.0 Integration Updates

The app has been fully updated to support the **MedAssist AI Backend V6.0** multimodal upgrade:
1.  **Critical Risk Support**: Added support for the new `CRITICAL` risk status (Melanoma). It is color-coded with a purple theme (`#7C3AED`) matching the backend specification.
2.  **Clinical Field Support**: Synchronized input fields to send `grew`, `bleed`, `diameter_1`, `skin_cancer_history`, and the new `elevation` state inside the request payload.
3.  **Timeout Resilience**: Configured a `90s` connection timeout inside `api_service.dart` to support test-time augmentation (TTA) and high-parameter neural network inference.
