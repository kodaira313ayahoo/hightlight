import 'package:flutter/services.dart';

class CharacterPair implements TextInputFormatter {
  /// Creates a CharacterPair with the ability to toggle it on/off with
  /// [enablePairing] which should be derived from the settings. This is final
  /// as a new instance is created when the note is navigated to again.
  CharacterPair(this.enablePairing);

  /// All the characters that can be paired, and their pairing character.
  // ignore: constant_identifier_names
  static const Map<String, String> PAIRED_CHARACTERS = <String, String>{
    '"': '"',
    "'": "'",
    '(': ')',
    '{': '}',
    '[': ']',
    '`': '`'
  };

  final bool enablePairing;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (enablePairing) {
      final String keyPressed =
          KeyPressUtils.getPressedKey(oldValue, newValue).trim();
      if (PAIRED_CHARACTERS.containsKey(keyPressed)) {
        return pairCharacter(keyPressed, oldValue, newValue);
      }
    }

    return newValue;
  }

  /// Pairs a character with the first character being [char] and the second
  /// corresponding to its value in [PAIRED_CHARACTERS]. Takes in the same
  /// [oldValue] and [newValue] as [formatEditUpdate] does. Does not do
  /// any checking if the pairing _should_ happen, that is left to its invoker.
  TextEditingValue pairCharacter(
      String char, TextEditingValue oldValue, TextEditingValue newValue) {
    final TextSelection oldSelection = oldValue.selection;

    final String before = oldValue.text.substring(0, oldSelection.start);
    final String content =
        oldValue.text.substring(oldSelection.start, oldSelection.end);
    final String after = oldValue.text.substring(oldSelection.end);

    final TextSelection newSelection = TextSelection(
        baseOffset: oldSelection.baseOffset + 1,
        extentOffset: oldSelection.extentOffset + 1,
        affinity: oldSelection.affinity,
        isDirectional: oldSelection.isDirectional);

    return TextEditingValue(
        text: '$before$char$content${PAIRED_CHARACTERS[char]}$after',
        selection: newSelection,
        composing: oldValue.composing);
  }
}

class KeyPressUtils {
  // ignore: constant_identifier_names
  static const String BACKSPACE = '\u0008';

  /// Gets the pressed key from the new and old values.
  /// Adapted from rich_editable_code's KeyboardUtilz.getPressedKey
  static String getPressedKey(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length == 1 && newValue.text == '\n') {
      return '\n';
    }

    final TextSelection newSelection = newValue.selection;
    final TextSelection currentSelection = oldValue.selection;

    if (currentSelection.baseOffset > newSelection.baseOffset) {
      //backspace was pressed
      return BACKSPACE;
    }

    return newValue.text
        .substring(currentSelection.baseOffset, newSelection.baseOffset);
  }
}
