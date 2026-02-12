# Image Processing App

**ImageFlow** – Intelligent image processing with face detection and document scanning.


## Overview

ImageFlow is a Flutter mobile app that captures an image from the camera or gallery, **automatically classifies** the content as **face** or **document**, runs the corresponding pipeline, and **persists results** with full history. It was built as a hiring case study with emphasis on **clean architecture**, **GetX** (state, routing, DI), and **no `setState`**. Heavy work (decode, resize, pixel ops) runs off the UI thread via `compute()` isolates.

**App flow:** Splash → Home → (FAB) Capture (bottom sheet) → Processing → Result → Done → back to Home; history items open Detail (face result images open a full-screen zoom viewer).

---

## Features

- **Capture** – Camera or gallery via bottom sheet; image is copied and resized (max 1920px) to avoid OOM.
- **Content detection** – ML Kit Face Detection: if ≥1 face → face pipeline; else → document pipeline.
- **Face pipeline** – Detect faces → crop each → grayscale → paste back → save composite PNG; supports multiple faces.
- **Document pipeline** – Enhance contrast → OCR on enhanced image → single-page PDF; extracted text stored and shown.
- **Result** – Face: before/after; Document: PDF preview, extracted text (search, copy), Open PDF, Done to save.
- **History** – List with thumbnail, type, date; delete; tap → detail.
- **Detail** – Full metadata; for documents: extracted text + Open PDF; for face: tap image → full-screen zoom/pan viewer.
- **Splash** – Gradient screen with tagline and tech chips, then navigates to Home.
- **Error handling** – Permission, image load, ML, and storage failures surface as snackbars and error state.

---

## Architecture

Clean architecture with clear layer separation:

```
lib/
  core/           # Errors (AppFailure), constants, services (StorageService)
  data/           # Data sources (Hive, ML Kit, file system), models, repository implementations
  domain/         # Entities, repository contracts, use cases
  presentation/   # GetX controllers, pages, reusable widgets
  routes/         # GetX routing and bindings (DI per route)
  main.dart
```

**Data flow (no ML or IO in UI):**

- **UI** → **Controller** → **UseCase** → **Repository** → **DataSource** / **Service**
- Controllers are thin: call use cases, map results/failures to reactive state (Obx).
- Business logic lives in **use cases**; **repositories** abstract Hive, file system, and ML Kit.

**Key packages:**

| Package | Purpose |
|--------|--------|
| **GetX** | State management, routing, dependency injection; no `setState`. |
| **Hive** | Metadata storage (list of maps in one box); no codegen. |
| **path_provider** | App documents dir; `ImageFlow/faces/` and `ImageFlow/docs/` under it. |
| **google_mlkit_face_detection** | Content type: face vs document. |
| **google_mlkit_text_recognition** | OCR in document pipeline; text stored in metadata. |
| **image** | Decode, crop, grayscale, encode; used inside `compute()`. |
| **pdf** | Single-page PDF from processed image. |
| **open_filex** | Open generated PDF in external app. |
| **permission_handler** | Camera and photo library permissions. |
| **uuid** | Unique IDs for history items. |

---

## State Management

- **GetX reactive pattern** – Controllers hold `Rx*` / `.obs` variables; pages use `Obx(() => ...)` so only widgets that read those values rebuild when they change. No `setState` anywhere.
- **GetView&lt;Controller&gt;** – Each page is a `GetView<XController>`; `controller` is resolved by GetX from the current route’s binding.
- **Bindings** – Each route has a Binding that registers that screen’s controller (e.g. `Get.lazyPut<HomeController>(...)`). Shared repos and use cases are registered once (e.g. in a shared `_putReposAndUseCases()` called from bindings).
- **Routing** – `Get.toNamed`, `Get.offNamed`, `Get.offAllNamed`, `Get.back()`; arguments passed via `Get.arguments`.
- **Capture flow** – No dedicated controller; `CaptureSheet` uses `Get.find<PickImageUseCase>()` and navigates to Processing with the picked path.

---

## Processing Pipelines

### Content detection

- **ML Kit Face Detection** on the selected image.
- If **at least one face** → **Face pipeline**; otherwise → **Document pipeline**.

### Face pipeline

1. Detect faces (ML Kit) on main isolate; get bounding boxes.
2. In a **compute()** isolate: decode image → for each face rect, crop → grayscale → paste back onto original → encode PNG.
3. Save PNG under `ImageFlow/faces/` with timestamped filename (e.g. `face_1234567890.png`).
4. Metadata saved on Result “Done”: `id`, `originalPath`, `resultPath`, `type: face`, `date`, `fileSizeBytes`.

### Document pipeline

1. Decode image; **enhance contrast** (`image` package).
2. Write enhanced image to a **temporary file** (for OCR).
3. **OCR** (ML Kit text recognition) on that file; extracted string attached to result.
4. Build **single-page PDF** from enhanced image; save under `ImageFlow/docs/` (e.g. `doc_1234567890.pdf`).
5. Temp image deleted; metadata on “Done”: `type: document`, `ocrText` (extracted string), plus paths, date, file size.

Document boundary detection and perspective correction are **not implemented**; structure is extension-ready (full image is used).

---

## Persistence Strategy

- **Files** – Stored under `getApplicationDocumentsDirectory()/ImageFlow/`:
  - **faces/** – PNG result images (face pipeline).
  - **docs/** – PDF files (document pipeline).
- **Filenames** – `{prefix}_{timestamp}{extension}` (e.g. `face_1234567890.png`, `doc_1234567890.pdf`).
- **Metadata** – **Hive** box `imageflow_metadata` stores a single list of maps. Each map has: `id`, `originalPath`, `resultPath`, `type` (`face` | `document`), `dateMillis`, `fileSizeBytes`, optional `title`, optional `ocrText` (documents). Data survives app restarts.
- **Delete** – Removing an item from history deletes its metadata from Hive and the result file from disk.

---

## Bonus Feature

**OCR text extraction (documents)**

- **When** – During the document pipeline, after enhancement; not when opening Result or Detail.
- **Flow** – Enhanced image → temp file → OCR repository (ML Kit) → extracted string → attached to `DocumentProcessingResult` → shown on Result screen and, on “Done”, persisted as `ocrText` in Hive.
- **UI** – Result and Detail share a reusable **Extracted Text** section: scrollable text, **search** (case-insensitive highlight, auto-scroll to first match), **Copy** (clipboard + snackbar). Empty result shows “No text detected.”
- **Why persist** – Avoid recomputing OCR on Detail; detail reads `ocrText` from DB only.
- **Implementation** – Domain: `ExtractDocumentTextRepository`; data: `OcrDataSource` (ML Kit, recognizer created/closed per call), `ExtractDocumentTextRepositoryImpl`. Failures yield empty string; UI stays safe.

**Possible improvements:** confidence scores, multiple scripts, optional “Re-run OCR” from detail.

---

## Trade-offs & Future Work

**Document pipeline**

- No real document boundary or perspective correction; full image used. Could add contour/edge detection and deskew.
- Single-page PDF; could support multi-page and higher-quality rendering.

**Performance & robustness**

- Face detection runs on main isolate (plugin limitation); could move more into isolates if the plugin allows.
- Thumbnail generation/caching for history list.
- Retry and backoff for transient storage/ML failures.

**UX & product**

- Onboarding and clearer permission rationale.
- Stronger empty/loading/error states and accessibility.
- Optional cloud backup/sync.

**Code & ops**

- Unit tests for use cases/repositories; widget tests for main flows.
- CI (e.g. `flutter analyze`, tests, build).
- Crash reporting and analytics.
- Feature flags for pipelines.

**Security & privacy**

- No logging of image content or paths in production.
- Optional encryption for stored files and metadata.

---

## How to Run

**Prerequisites:** Flutter SDK (latest stable), null safety. For iOS: Xcode (latest stable), CocoaPods.

**First-time or after dependency changes:**

```bash
flutter pub get
flutter run
```

For **iOS**, if the app does not run or pods fail:

```bash
flutter clean
flutter pub get
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..
flutter run
```
