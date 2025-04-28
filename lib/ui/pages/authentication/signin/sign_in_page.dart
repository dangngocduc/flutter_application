import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late final AlwaysShowPrefixTextEditingController _controller;
  final String _prefix = "https://";

  @override
  initState() {
    super.initState();
    _controller = AlwaysShowPrefixTextEditingController(
        prefixText: _prefix, text: _prefix);
    // Ensure the initial text has the prefix and the cursor is at the end
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}

class AlwaysShowPrefixTextEditingController extends TextEditingController {
  final String prefixText;

  AlwaysShowPrefixTextEditingController(
      {String? text, required this.prefixText})
      : super(text: text ?? '');

  @override
  set value(TextEditingValue newValue) {
    // If the new text doesn't start with the prefix, prepend it.
    if (!newValue.text.startsWith(prefixText)) {
      // Adjust the selection to account for the added prefix
      final int newSelectionBaseOffset =
          newValue.selection.baseOffset + prefixText.length;
      final int newSelectionExtentOffset =
          newValue.selection.extentOffset + prefixText.length;
      final TextSelection newSelection = TextSelection(
        baseOffset: newSelectionBaseOffset.clamp(
            0, newValue.text.length + prefixText.length),
        extentOffset: newSelectionExtentOffset.clamp(
            0, newValue.text.length + prefixText.length),
        affinity: newValue.selection.affinity,
        isDirectional: newValue.selection.isDirectional,
      );

      super.value = TextEditingValue(
        text: prefixText + newValue.text,
        selection: newSelection,
      );
    } else {
      // If the new text already starts with the prefix, just set the value.
      super.value = newValue;
    }
  }

  // Optionally, you can override the text setter as well for consistency,
  // though setting value is the primary way the TextField updates the controller.
  @override
  set text(String newText) {
    if (!newText.startsWith(prefixText)) {
      super.text = prefixText + newText;
    } else {
      super.text = newText;
    }
  }
}
