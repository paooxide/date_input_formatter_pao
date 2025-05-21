import 'package:flutter/services.dart'; // Import for TextEditingValue
import 'package:flutter_test/flutter_test.dart';
import 'package:date_input_formatter_pao/date_input_formatter_pao.dart';

void main() {
  group('DateInputFormatter', () {
    test('should format initial input correctly for dd/MM/yyyy', () {
      final formatter = DateInputFormatter(pattern: 'dd/MM/yyyy');
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(
        text: '1',
        selection: TextSelection.collapsed(offset: 1),
      );
      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '1D/MM/YYYY');
      expect(result.selection.baseOffset, 1);
    });

    test('should format second digit correctly for dd/MM/yyyy', () {
      final formatter = DateInputFormatter(pattern: 'dd/MM/yyyy');
      // Simulate state after '1' was typed
      TextEditingValue oldValue = const TextEditingValue(
        text: '1', // This is what the user sees as raw input from digitsOnly
        selection: TextSelection.collapsed(offset: 1),
      );
      // User types '2'
      TextEditingValue newValue = const TextEditingValue(
        text: '12',
        selection: TextSelection.collapsed(offset: 2),
      );
      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '12/MM/YYYY');
      // Cursor should be after '12/', which is index 3
      expect(result.selection.baseOffset, 3);
    });

    test('should format full date correctly for dd/MM/yyyy', () {
      final formatter = DateInputFormatter(pattern: 'dd/MM/yyyy');
      TextEditingValue oldValue = const TextEditingValue(
        text: '3009202', // User has typed up to this point
        selection: TextSelection.collapsed(offset: 7),
      );
      // User types '3'
      TextEditingValue newValue = const TextEditingValue(
        text: '30092023',
        selection: TextSelection.collapsed(offset: 8),
      );
      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '30/09/2023');
      // Cursor should be at the end
      expect(result.selection.baseOffset, 10);
    });

    test('should format full date with placeholderChar for MM-dd-yy', () {
      final formatter = DateInputFormatter(
        pattern: 'MM-dd-yy',
        placeholderChar: '_',
      );
      TextEditingValue oldValue = const TextEditingValue(
        text: '12312', // User has typed up to this point
        selection: TextSelection.collapsed(offset: 5),
      );
      // User types '3'
      TextEditingValue newValue = const TextEditingValue(
        text: '123123',
        selection: TextSelection.collapsed(offset: 6),
      );
      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '12-31-23');
      expect(result.selection.baseOffset, 8);
    });

    test('should handle backspace correctly', () {
      final formatter = DateInputFormatter(pattern: 'dd/MM/yyyy');
      // Simulate state: '12/MM/YYYY' with cursor after '/'
      // Raw digits entered so far: "12"
      TextEditingValue oldValue = const TextEditingValue(
        text: '12', // Raw digits before backspace
        selection: TextSelection.collapsed(
          offset: 2,
        ), // Cursor was at the end of "12"
      );
      // User presses backspace, removing '2'
      TextEditingValue newValue = const TextEditingValue(
        text: '1', // Raw digits after backspace
        selection: TextSelection.collapsed(offset: 1), // Cursor is after '1'
      );
      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '1D/MM/YYYY');
      expect(result.selection.baseOffset, 1);
    });

    test('should handle pasting a valid full date string', () {
      final formatter = DateInputFormatter(pattern: 'dd/MM/yyyy');
      const oldValue = TextEditingValue.empty;
      // User pastes '25122023'
      const newValue = TextEditingValue(
        text: '25122023',
        selection: TextSelection.collapsed(
          offset: 8,
        ), // Cursor at the end of pasted content
      );
      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '25/12/2023');
      expect(result.selection.baseOffset, 10);
    });

    test('should handle pasting a string with non-digits', () {
      final formatter = DateInputFormatter(pattern: 'dd/MM/yyyy');
      const oldValue = TextEditingValue.empty;
      // User pastes 'abc25def12ghi2023jkl'
      // Assuming FilteringTextInputFormatter.digitsOnly runs first, newValue.text would be '25122023'
      const newValue = TextEditingValue(
        text:
            '25122023', // This is what DateInputFormatter receives after digitsOnly
        selection: TextSelection.collapsed(offset: 8),
      );
      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '25/12/2023');
      expect(result.selection.baseOffset, 10);
    });

    test(
      'should correctly place cursor when typing into middle of MM-dd-yyyy',
      () {
        final formatter = DateInputFormatter(pattern: 'MM-dd-yyyy');
        // Initial state: 1M-DD-YYYY, user typed "1"
        TextEditingValue oldValue = const TextEditingValue(
          text: "1",
          selection: TextSelection.collapsed(offset: 1),
        );
        // User types "2"
        TextEditingValue newValue = const TextEditingValue(
          text: "12",
          selection: TextSelection.collapsed(offset: 2),
        );
        var result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, "12-DD-YYYY");
        expect(result.selection.baseOffset, 3); // Cursor after "12-"

        // Simulate state: 12-DD-YYYY, user typed "12"
        oldValue = newValue; // The new value from previous step is now old
        // User types "3"
        newValue = const TextEditingValue(
          text: "123",
          selection: TextSelection.collapsed(offset: 3),
        );
        result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, "12-3D-YYYY");
        expect(result.selection.baseOffset, 4); // Cursor after "12-3"
      },
    );
  });
}
