import 'package:flutter/services.dart';

class _MaskSlot {
  final String patternChar; // Character from the pattern (e.g., 'd', '/', 'Y')
  final bool isPlaceholder; // Is it a digit placeholder?
  final int
  logicalDigitIndex; // If placeholder, its 0-based index (0 to N-1). -1 otherwise.

  const _MaskSlot({
    required this.patternChar,
    required this.isPlaceholder,
    required this.logicalDigitIndex,
  });
}

/// A [TextInputFormatter] that formats user input into a date according to a given pattern,
/// using an internal Map to store entered digits based on their logical position.
///
/// It aims to maintain the correct mapping between entered digits and their logical
/// positions (Day, Month, Year) even after various deletion operations.
///
/// ## Example
///
/// To use this formatter, add it to the `inputFormatters` list of a `TextField`.
/// It is highly recommended to also include `FilteringTextInputFormatter.digitsOnly`
/// to ensure that only digits are passed to this formatter.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:flutter/services.dart';
/// import 'package:date_input_formatter_pao/date_input_formatter_pao.dart';
///
/// class MyForm extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Column(
///       children: <Widget>[
///         TextField(
///           decoration: const InputDecoration(
///             hintText: 'DD/MM/YYYY',
///           ),
///           keyboardType: TextInputType.number,
///           inputFormatters: [
///             FilteringTextInputFormatter.digitsOnly,
///             DateInputFormatter(pattern: 'dd/MM/yyyy'),
///           ],
///         ),
///         const SizedBox(height: 16),
///         TextField(
///           decoration: const InputDecoration(
///             hintText: 'MM-DD-YY (custom placeholder)',
///           ),
///           keyboardType: TextInputType.number,
///           inputFormatters: [
///             FilteringTextInputFormatter.digitsOnly,
///             DateInputFormatter(pattern: 'MM-dd-yy', placeholderChar: '_'),
///           ],
///         ),
///       ],
///     );
///   }
/// }
/// ```
class DateInputFormatter extends TextInputFormatter {
  /// Pattern for the date mask, e.g. 'dd/MM/yyyy' or 'MM-dd-yy'.
  final String pattern;

  /// Optional character to use for unfilled placeholders.
  /// If null, the uppercase version of the pattern character (e.g., 'D', 'M', 'Y') is used.
  final String? placeholderChar;

  /// Regex matching placeholder tokens in the pattern (alphabetic characters).
  final RegExp _placeholderRegex = RegExp(r'[A-Za-z]');

  /// Internal list representing the immutable structure of each character slot.
  late final List<_MaskSlot> _maskStructure;

  /// Total number of placeholder slots in the pattern.
  late final int _placeholderCount;

  /// Stores the currently entered digits, keyed by their logical index (0, 1, 2...).
  /// Using LinkedHashMap to preserve insertion order if needed later, though not strictly necessary here.
  final Map<int, String> _enteredDigitsMap =
      <int, String>{}; // Made final and used collection literal

  /// Constructs a [DateInputFormatter].
  DateInputFormatter({required this.pattern, this.placeholderChar})
    : assert(
        pattern.contains(RegExp(r'[A-Za-z]')),
        'Pattern must contain at least one placeholder.',
      ),
      assert(
        placeholderChar == null || placeholderChar.length == 1,
        'Placeholder character must be a single character.',
      ) {
    _buildMaskStructure();
  }

  /// Builds the internal list (_maskStructure) representing the mask slots based on the pattern.
  void _buildMaskStructure() {
    final structure = <_MaskSlot>[];
    int count = 0;
    int currentLogicalDigitIndex = 0;
    for (int i = 0; i < pattern.length; i++) {
      final char = pattern[i];
      final isPlaceholder = _placeholderRegex.hasMatch(char);
      int logicalIndex = -1;

      if (isPlaceholder) {
        logicalIndex = currentLogicalDigitIndex++;
        count++;
      }
      structure.add(
        _MaskSlot(
          patternChar: char,
          isPlaceholder: isPlaceholder,
          logicalDigitIndex: logicalIndex,
        ),
      );
    }
    _maskStructure = List.unmodifiable(structure);
    _placeholderCount = count;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue
    oldValue, // The previous TextEditingValue in the field (formatted)
    TextEditingValue
    newValue, // The new TextEditingValue from user input (digits-only due to previous formatter)
  ) {
    final String newDigits = newValue.text;
    final int cursorInDigits = newValue.selection.baseOffset;

    // 1. Update the Stored Digits Map (`_enteredDigitsMap`) based on newDigits
    _enteredDigitsMap.clear();
    for (int i = 0; i < newDigits.length && i < _placeholderCount; i++) {
      _enteredDigitsMap[i] = newDigits[i];
    }

    // 2. Build Final String
    final buffer = StringBuffer();
    for (int i = 0; i < _maskStructure.length; i++) {
      final slot = _maskStructure[i];
      if (slot.isPlaceholder) {
        if (_enteredDigitsMap.containsKey(slot.logicalDigitIndex)) {
          buffer.write(_enteredDigitsMap[slot.logicalDigitIndex]!);
        } else {
          final placeholder = placeholderChar ?? slot.patternChar.toUpperCase();
          buffer.write(placeholder);
        }
      } else {
        buffer.write(slot.patternChar);
      }
    }
    final String finalResult = buffer.toString();

    // 3. Calculate Cursor Position
    // Map cursor position from digit string to formatted string
    int tentativeCursorIndex = 0;
    int digitsProcessedCount = 0;

    // Iterate through the mask structure to find where the cursorInDigits maps to in the formatted string
    for (int i = 0; i < _maskStructure.length; i++) {
      // If we've processed enough digits to match the cursor's position in the digit string
      if (digitsProcessedCount == cursorInDigits) {
        tentativeCursorIndex = i;
        break;
      }
      // If the current mask slot is a placeholder and it's filled with an entered digit,
      // increment our count of processed digits.
      if (_maskStructure[i].isPlaceholder &&
          _enteredDigitsMap.containsKey(_maskStructure[i].logicalDigitIndex)) {
        digitsProcessedCount++;
      }
      // If we're at the end of the mask and the cursor was intended to be at the end of the digits,
      // place the tentative cursor at the end of the formatted result.
      if (i == _maskStructure.length - 1 &&
          digitsProcessedCount == cursorInDigits) {
        tentativeCursorIndex = finalResult.length;
      }
    }

    int selectionIndex = _findNextInputSlotIndex(tentativeCursorIndex);
    selectionIndex = selectionIndex.clamp(0, finalResult.length);

    return TextEditingValue(
      text: finalResult,
      selection: TextSelection.collapsed(offset: selectionIndex),
      composing: newValue.composing, // Preserve composing status
    );
  }

  /// Finds the index of the next placeholder slot at or after the given starting text index.
  /// Returns pattern.length if no more placeholders are found.
  int _findNextInputSlotIndex(int startIndex) {
    for (int i = startIndex; i < _maskStructure.length; i++) {
      if (_maskStructure[i].isPlaceholder) {
        return i;
      }
    }
    return pattern.length;
  }
}
