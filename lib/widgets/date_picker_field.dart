import 'package:flutter/material.dart';


class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;


  const DatePickerField({super.key, required this.label, this.value, required this.onChanged});


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          initialDate: value ?? DateTime.now(),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        child: Text(value == null ? 'Select date' : value!.toIso8601String().substring(0, 10)),
      ),
    );
  }
}