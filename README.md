# Beat Flutter

## Don't use this use [Obsidian MD](https://obsidian.md/) with [Fountain Plugin](https://github.com/chuangcaleb/obsidian-fountain-editor?tab=readme-ov-file) instead

This is a vibe-coded work in-progress, the original Beat application is brilliant and I always miss it when I'm away from my Mac. There isn't a decent `.fountain` editor on Windows or Linux and this is an effort to do that.

This mostly doesn't work in it's current state.


A cross-platform screenwriting application using the Fountain format, built with Flutter.

This is a port of the [Beat](https://github.com/lmparppei/Beat) screenwriting app to Flutter, targeting Linux and Windows desktop platforms.

## Features (MVP)

- Write screenplays using the Fountain markup format
- Automatic formatting for screenplay elements (scene headings, dialogue, action, etc.)
- Autocompletion for character names and scene headings
- Bold, italic, and underline text styling
- Save/load `.fountain` files with Beat settings compatibility

## Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Linux or Windows development environment

### Running the App

```bash
flutter pub get
flutter run -d linux  # or -d windows
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── fountain_parser/          # Fountain markup parser
│   ├── parser.dart           # Main parser implementation
│   ├── line.dart             # Line model with type and formatting
│   └── line_type.dart        # Enum of Fountain line types
├── editor/                   # Super Editor customization
│   ├── screenplay_editor.dart
│   ├── nodes/                # Custom document nodes
│   └── styles/               # Screenplay styling
├── document/                 # File I/O and settings
│   ├── fountain_document.dart
│   └── document_settings.dart
└── app/                      # Application UI
    ├── app.dart
    ├── editor_screen.dart
    └── widgets/
```

## License

GPL-3.0 (same as original Beat)
