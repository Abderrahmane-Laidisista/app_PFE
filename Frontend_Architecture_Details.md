# MedAssist AI Frontend Architecture & Implementation Report

This document details the frontend architecture, system layout, state management, dependencies, and core modules of the **MedAssist AI** Flutter application. This report is structured for inclusion in a graduation thesis (**Projet de Fin d'Études - PFE**).

---

## 1. System Overview

The **MedAssist AI Mobile Application** serves as the user-facing interface for the multimodal deep learning diagnostic backend. Built with the **Flutter SDK**, it provides a cross-platform, responsive experience that allows clinical professionals to:
1. Capture or upload high-resolution skin lesion images.
2. Fill out detailed patient clinical forms (Age, Sex, Anatomical Region, Growth History, Bleeding, Diameter, History, and Elevation).
3. Send requests asynchronously to the FastAPI backend.
4. Render interactive diagnostic results, confidence breakdowns, clinical risk indicators, and customized recommendations.
5. Export results as formatted PDF reports and share them.
6. Browse local diagnostic history offline.

---

## 2. Technical Stack & Dependencies

The frontend is built on a clean, scalable architectural framework with the following core dependencies:

*   **SDK**: `Flutter (Dart SDK ^3.11.1)` for high-performance rendering and single-codebase compiling.
*   **State Management & Dependency Injection**: `GetX (^4.6.6)` for light, fast reactive state management, controller bindings, and clean dependency injection.
*   **Routing**: `GetX Routing` for named routes and seamless animation transitions.
*   **Local Storage**: `GetStorage (^2.1.1)` to persist patient metadata, API keys, and offline histories.
*   **Networking**: `http (^1.2.0)` for asynchronous HTTP requests and multipart file transfers.
*   **Media Handling**: `camera (^0.12.0)` and `image_picker (^1.2.1)` to capture high-quality dermoscopy images.
*   **Utility & Exporting**: `pdf (^3.11.1)` and `share_plus (^10.1.2)` to compile and export clinical reports.
*   **Typography**: The `Cairo` font family for modern, clean UI rendering.

---

## 3. Directory Structure & Architecture

The application adopts the **Clean Architecture / GetX Pattern**, dividing the codebase into clean layers to separate concerns (Data, Logic, UI).

```
lib/
├── app/
│   ├── config/          # Theme configurations, colors, and styling
│   ├── routes/          # Navigation routes and page definitions
│   └── translations/    # Localization/translation files (AR, FR, EN)
├── core/
│   └── services/        # Singleton services (API, Storage, PDF, Connectivity)
├── data/
│   ├── models/          # Data serialization models (PatientMetadata, PredictionResponse)
│   └── providers/       # Local database or network data providers
├── global_widgets/      # Reusable UI widgets across multiple modules
└── modules/             # App modules (each containing views, controllers, and bindings)
    ├── splash/
    ├── onboarding/
    ├── home/
    ├── clinical_form/   # Form collection for the 8 patient metadata features
    ├── camera/          # Custom camera interface for dermoscopy capture
    ├── analysis/        # Inference load screening
    ├── result/          # Rich diagnostic visualization & PDF export
    ├── history/         # Local historical diagnoses
    ├── settings/        # Server configuration and preference panel
    └── education/       # Dermatological guidelines and tutorial content
```

---

## 4. Key Implementation Services

### 4.1. Storage Service (`StorageService`)
Manages secure persistence using the lightweight `GetStorage` engine. Saves the active API URL configurations, user profile options, and caches historical predictions locally to keep them accessible without network connections.

### 4.2. API Integration Service (`ApiService`)
Handles communication with the FastAPI back-end. Maps Flutter's native models to the API request payload, constructs a `MultipartRequest` containing the image binary alongside clinical variables, and processes structured JSON responses into Dart objects.

### 4.3. Document Generation Service (`PdfService`)
Compiles patient data, prediction percentages, risk scores, and recommendations into standard PDF formats. Integrates styling and fonts directly, saving the document to native cache for printing or sharing.

---

## 5. User Interface (UI) System

The UI uses a **Responsive Grid Layout** configured with custom Light/Dark theme sheets.
*   **Visual Styling**: Clean gradients, card elevations, and custom icons are used to map risk severity indicators clearly.
*   **Localization**: Multi-language support allows seamless switching between languages (English, French, Arabic) to serve localized clinic operations.
*   **Animations**: Built-in micro-interactions and transitions (e.g., custom fading loader screens) enrich user satisfaction during model inference wait times.
