# MedAssist AI Frontend - Backend Integration Updates (V6.0)

This document outlines the recent system integration adjustments applied to the **MedAssist AI Flutter Frontend** to ensure full compatibility with the **MedAssist AI Backend (V6.0)** multimodal deep learning pipeline.

---

## 1. Integration Status Overview

With the backend's upgrade to V6.0, the prediction model changed from a single-modality classifier to a **multimodal cross-attention fusion network** accepting a high-resolution image alongside **8 distinct clinical attributes**. 

A complete audit of client-server payloads was performed, resulting in key code optimizations across the models and services.

---

## 2. Implemented Compatibility Adjustments

### 2.1. Critical Risk Level Support
The V6.0 backend introduces a high-risk classification category labeled `CRITICAL` (specifically for aggressive Melanoma predictions).
*   **Color Mapping**: Updated `getRiskLevelColor()` inside [prediction_response.dart](lib/data/models/prediction_response.dart) to map `CRITICAL` risk to the brand-approved purple color (`#7C3AED`), matching the server response color.
*   **Clinical Recommendations**: Added fallback matching rules in the local recommendation generator (`_generateRecommendations()`) to trigger the dermatologist consult recommendation automatically if a `CRITICAL` response is received.

### 2.2. Clinical Metadata Expansion (Elevation Field)
The backend model added support for the `elevation` parameter (indicating if the skin lesion is raised/elevated).
*   **Model Update**: Extended the `PatientMetadata` model class inside [patient_metadata.dart](lib/data/models/patient_metadata.dart) to support the new optional `bool? elevation` property.
*   **JSON Serialization**: Adjusted the serialization pipeline to append `'elevation': elevation` into payloads when valid.

### 2.3. Request Payload Synchronization
Prior frontend request cycles omitted clinical metadata variables. The [api_service.dart](lib/core/services/api_service.dart) connection layer was modified to explicitly transmit:
*   `grew` (Boolean)
*   `bleed` (Boolean)
*   `diameter_1` (Float)
*   `skin_cancer_history` (Boolean)
*   `elevation` (Boolean, optional)

This guarantees the model has full context, reducing the need for default/imputed statistical values and boosting prediction accuracy.

### 2.4. Inference Connection Timeout Extension
Multimodal calculations, test-time data augmentation (TTA), and CPU execution can increase backend response time.
*   **Optimization**: Extended the network client connection timeout value from `30 seconds` to `90 seconds` inside `api_service.dart` to prevent premature socket timeouts.
