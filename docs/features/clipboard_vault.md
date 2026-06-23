# Clipboard Vault Module (v1.5.0)

The Clipboard Vault module isolates, classifies, and secures copied snippets locally. By using local heuristic classification, the vault automatically parses and organizes clipboard content without sharing sensitive clipboard info externally.

## Key Features

1. **Heuristic Classification**:
   - Classifies clipboard data into three distinct types:
     - **Links**: Validated web URLs.
     - **Snippets**: Short multi-line pieces of code or structured text.
     - **Plain Text**: Standard short strings or notes.
   - Operates entirely on device with zero regex backtracking penalties or runtime lag.

2. **Filter Chips & Search**:
   - Filter items dynamically by classification types using Material 3 compact chips.
   - High-density list displays classified badges (Link, Snippet, Text) alongside timestamp information.

3. **Secure Vault Operations**:
   - One-tap clipboard import.
   - Quick card actions: tap to re-copy back into the native clipboard, or tap the preview icon to inspect long code snippets in a custom dialog.
   - Swipe-to-delete gesture removes snippets permanently from local storage.

## Architecture

- **`lib/features/clipboard/domain/services/clipboard_classifier.dart`**: Evaluates strings on-the-fly and stamps them with the correct `ClipboardType`.
- **`lib/features/clipboard/data/datasources/clipboard_local_data_source.dart`**: Handles reading/writing clipboard archives to local disk.
- **`lib/features/clipboard/presentation/bloc/clipboard_bloc.dart`**: Processes events like `ImportFromClipboard`, `DeleteClipboardItem`, and state management.
- **`lib/features/clipboard/presentation/pages/clipboard_vault_page.dart`**: High-density screen utilizing animated list expansions and action overlays.
