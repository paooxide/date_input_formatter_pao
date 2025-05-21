<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# date_input_formatter_pao

A Dart package that provides a custom `TextInputFormatter` for formatting date input in Flutter applications. It allows users to enter dates in a specific format (e.g., 'dd/MM/yyyy') and ensures that the input is valid according to the specified format. The package also includes options for customizing the date format and handling invalid input gracefully.

This package aims to provide a user-friendly way to guide users to enter dates in a predefined structure, improving data quality and user experience.

## Features

*   **Custom Date Patterns**: Define your desired date format (e.g., 'dd/MM/yyyy', 'MM-dd-yy', 'yyyy.MM.dd').
*   **Placeholder Characters**: Optionally specify a custom character for unfilled date parts (e.g., using '_' instead of 'D', 'M', 'Y').
*   **Logical Digit Mapping**: Intelligently maps entered digits to their logical positions (day, month, year) even with deletions and insertions.
*   **Cursor Management**: Attempts to position the cursor intuitively after input or deletion.
*   **Works with `FilteringTextInputFormatter.digitsOnly`**: Designed to be used alongside `FilteringTextInputFormatter.digitsOnly` for a seamless numeric-only date input experience.

## Getting started

To use this package, add `date_input_formatter_pao` as a dependency in your `pubspec.yaml` file.

```yaml
dependencies:
  flutter:
    sdk: flutter
  date_input_formatter_pao: ^0.0.1 # Replace with the latest version
```

Then, run `flutter pub get` in your terminal.

## Usage

Import the package in your Dart file:

```dart
import \'package:date_input_formatter_pao/date_input_formatter_pao.dart\';
import \'package:flutter/services.dart\'; // For FilteringTextInputFormatter
```

Then, use the `DateInputFormatter` in your `TextField`\'s `inputFormatters` list. It\'s highly recommended to also include `FilteringTextInputFormatter.digitsOnly` to ensure only numeric input is processed by the formatter.

Here are a few examples:

**Basic Usage (dd/MM/yyyy):**

```dart
TextField(
  decoration: const InputDecoration(
    hintText: \'DD/MM/YYYY\',
    border: OutlineInputBorder(),
  ),
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    DateInputFormatter(pattern: \'dd/MM/yyyy\'),
  ],
)
```

**Custom Placeholder Character (MM-dd-yy with '_'):**

```dart
TextField(
  decoration: const InputDecoration(
    hintText: \'MM-DD-YY\',
    border: OutlineInputBorder(),
  ),
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    DateInputFormatter(pattern: \'MM-dd-yy\', placeholderChar: \'_\'),
  ],
)
```

**Different Pattern (yyyy.MM.dd):**

```dart
TextField(
  decoration: const InputDecoration(
    hintText: \'YYYY.MM.DD\',
    border: OutlineInputBorder(),
  ),
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    DateInputFormatter(pattern: \'yyyy.MM.dd\'),
  ],
)
```

For a more complete example, please see the `/example` folder in this package.

## Additional information

### Contributing

Contributions are welcome! If you find any issues or have suggestions for improvements, please feel free to:

1.  **Open an issue**: Report bugs or suggest new features on the [issue tracker](https://github.com/paooxide/date_input_formatter_pao/issues).
2.  **Submit a pull request**: If you\'d like to contribute code, please fork the repository and submit a pull request with your changes.

When contributing, please try to:
*   Follow the existing code style.
*   Write tests for any new functionality or bug fixes.
*   Ensure your changes pass all existing tests.

### Reporting Issues

Please report any bugs or issues you find on the [GitHub Issues](https://github.com/paooxide/date_input_formatter_pao/issues) page.

### License

This package is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
