## 0.1.0 - 2025-05-21

- Initial release: Added `date_input_formatter_pao` package with custom `TextInputFormatter`.
  - Implemented `DateInputFormatter` for formatting date input based on specified patterns (e.g., 'dd/MM/yyyy', 'MM-dd-yy').
  - Created internal structure to manage placeholder slots and entered digits.
  - Ensured correct cursor positioning during input, deletion, and pasting operations.
  - Added comprehensive unit tests to validate formatter behavior across various scenarios.
  - Included an example application demonstrating usage and Flutter for Windows compatibility.
