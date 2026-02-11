# ImageFlow

A production-ready Flutter mobile application that acts as an **intelligent image processing system**: it accepts an image from the camera or gallery, automatically determines whether the content is a **face** or a **document**, runs the appropriate pipeline, and persists results with full history.

Built as a hiring case study with emphasis on **code quality**, **clean architecture**, and **maintainability**.

---

## Architecture

The app follows **clean architecture** with clear separation of concerns:

```
lib/
  core/           # Cross-cutting: errors, constants, services (e.g. storage)
  data/           # Data sources (Hive, ML Kit, file system), models, repository implementations
  domain/         # Business rules: entities, repository contracts, use cases
  presentation/   # UI: GetX controllers, pages, reusable widgets
  routes/         # GetX routing and dependency injection (bindings)
  main.dart
```

**Data flow (no ML or IO in UI):**

- **UI** → **Controller** (GetX, reactive) → **UseCase** → **Repository** (abstract) → **DataSource** / **Service**
- Controllers are thin: they call use cases and map results/failures to UI state (Obx).
- Business logic lives in **use cases**; **repositories** abstract data (Hive, file system, ML Kit).
- **Heavy work** (image decode, pixel ops) runs off the UI thread via `compute()` (isolate) where applicable.

**Package choices and trade-offs:**

| Choice | Reason |
|--------|--------|
| **GetX** | State management, routing, and DI in one package; no `setState` anywhere; bindings give clear dependency wiring per route. |
| **Hive** | Fast, no native dependency, works well for small metadata lists; data stored as `List<Map>` in one box to avoid code generation. |
| **path_provider** | Standard way to get app documents dir; we create `/ImageFlow/faces/` and `/ImageFlow/docs/` under it. |
| **google_mlkit_face_detection** | Official ML Kit; face detection drives content type (face vs document). |
| **google_mlkit_text_recognition** | Used in document pipeline for structure; document bounds/perspective are placeholder for real CV. |
| **image** | Pure Dart decode/crop/grayscale/encode; used inside `compute()` so UI never blocks. |
| **pdf** | Generates PDF from processed image for document flow. |
| **open_filex** | Opens generated PDF in external viewer. |

---

## How detection works

1. **Content type**
   - Run **ML Kit Face Detection** on the selected image.
   - If **at least one face** is found → **Face flow**.
   - Otherwise → **Document flow**.

2. **Face pipeline**
   - Detect faces (ML Kit) on the main isolate (plugin uses platform channels).
   - Get bounding boxes, then run in a **compute()** isolate: decode image → crop each face → convert to grayscale → paste back onto original → encode PNG.
   - Save under `ImageFlow/faces/` with a timestamped name.
   - Save metadata in Hive: `id`, `originalPath`, `resultPath`, `type: face`, `date`, `fileSize`.

3. **Document pipeline**
   - Run text recognition (for future use; structure is extension-ready).
   - Best-effort “document” = full image (real edge detection / perspective correction can be plugged in later).
   - Contrast enhancement via `image` package; enhanced image is written to a temp file.
   - **OCR** runs on the enhanced image (ML Kit text recognition); extracted text is attached to the result and stored in metadata.
   - Build a single-page PDF and save under `ImageFlow/docs/`.
   - Save metadata with `type: document` and `ocrText` (extracted string).

---

## How to run

**Prerequisites:** Flutter SDK (latest stable), null safety.

```bash
flutter pub get
flutter run
```

- **Android:** Camera and (if needed) storage/photo permissions are in `AndroidManifest.xml`; request at runtime via `permission_handler`.
- **iOS:** Usage descriptions for camera and photo library are in `Info.plist`.

**Suggested:** Use a real device for camera; simulator can use gallery only.

---

## Storage rules

- **Folders:** `getApplicationDocumentsDirectory()/ImageFlow/faces/` and `.../ImageFlow/docs/`.
- **Filenames:** Meaningful prefixes + timestamp (e.g. `face_1234567890.png`, `doc_1234567890.pdf`).
- **Metadata:** Hive box `imageflow_metadata` stores a list of maps (id, paths, type, date, file size, optional `ocrText` for documents).

---

## Error handling

- **No permission:** `PermissionFailure` → snackbar.
- **Image load failure:** `ImageLoadFailure` (e.g. picker cancel, missing file).
- **ML failure:** `MLFailure` (e.g. no faces when expected, detector error).
- **Storage failure:** `StorageFailure` (e.g. write/read errors).

Controllers catch these (or generic `Exception`), show snackbar/dialog, and set error state for UI (Obx).

---

## Bonus – OCR Text Extraction

Document processing includes **OCR text extraction** so users can view, search, and copy text from scanned documents.

**Where OCR runs**  
OCR runs **during the document pipeline**, not when the user opens the result or detail screen. After the image is enhanced, it is written to a temporary file; the document repository then calls the OCR repository (ML Kit text recognition) on that file. The extracted string is attached to `DocumentProcessingResult` and passed through to the result screen and, on "Done", persisted in Hive as `ocrText`.

**Why we store results**  
Storing the extracted text in metadata (Hive) avoids recomputing OCR every time the user opens the detail screen. It keeps the detail screen fast and avoids holding or re-running the recognizer. The history list and detail screen read `ocrText` from the database only.

**Why not recompute**  
Recomputing would require either re-running the full document pipeline (expensive) or running OCR again on the saved PDF/image (duplicate work, extra latency, and unnecessary recognizer usage). Storing once at processing time is the intended design.

**Implementation notes**  
- Domain: `ExtractDocumentTextRepository`; data: `OcrDataSource` (ML Kit, create/close recognizer per call) and `ExtractDocumentTextRepositoryImpl`.  
- OCR failures or empty results are handled safely: the repository returns an empty string and the UI shows "No text detected."  
- Result and Detail screens share a reusable **Extracted Text** section: scrollable/selectable text, search bar (case-insensitive highlight), and Copy button (clipboard + snackbar).

**Possible improvements**  
- Use ML Kit’s block/element structure or confidence scores for better UX (e.g. low-confidence warning).  
- Support multiple language scripts via `TextRecognitionScript` or separate models.  
- Optional “Re-run OCR” from detail for when the user improves the source image later.
---

## What would be improved in production

1. **Document pipeline**
   - Real document boundary detection (e.g. contour/edge detection).
   - Perspective correction and deskew.
   - Optional multi-page PDF and higher-quality rendering.

2. **Performance and robustness**
   - Move more of the face pipeline (including ML) into isolates where the plugin allows, or use a dedicated isolate for heavy steps.
   - Thumbnail generation/caching for the history list.
   - Retry and backoff for transient storage/ML failures.

3. **UX and product**
   - Onboarding and explicit permission rationale.
   - Better empty/loading/error states and accessibility.
   - Optional cloud backup and sync of metadata (and/or files).

4. **Code and ops**
   - Unit tests for use cases and repositories; widget tests for main flows.
   - CI (e.g. `flutter analyze`, tests, build).
   - Crash reporting and analytics.
   - Feature flags for face vs document pipelines.

5. **Security and privacy**
   - No logging of image content or paths in production.
   - Optional app-level encryption for stored files and metadata.

---

## Screens (required flow)

1. **Home** – List/grid of history (thumbnail, type, date), delete, tap → detail, FAB → capture (bottom sheet).
2. **Capture** – Bottom sheet: Camera / Gallery.
3. **Processing** – Shows image, progress bar, status text (e.g. “Detecting faces…”, “Cropping…”, “Enhancing…”).
4. **Result** – Face: before/after; Document: PDF icon/title and “Open PDF”. Done → save metadata and go back to Home.
5. **Detail** – Full-screen metadata and “Open PDF” for documents.

All state and navigation use **GetX** (reactive state and routing); **no `setState`** is used.
# Image-Processing-Analysis-App
