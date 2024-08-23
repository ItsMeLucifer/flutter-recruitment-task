import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_recruitment_task/entities/filters.dart';
import 'package:flutter_recruitment_task/presentation/pages/home_page/home_cubit.dart';

class PriceFilterDialog extends StatefulWidget {
  final Loaded state;
  final void Function({required List<Filter> filters}) setProductFilters;

  const PriceFilterDialog({
    required this.state,
    required this.setProductFilters,
    super.key,
  });

  @override
  State<PriceFilterDialog> createState() => _PriceFilterDialogState();

  void show(BuildContext context) =>
      showDialog(context: context, builder: (ctx) => this);
}

class _PriceFilterDialogState extends State<PriceFilterDialog> {
  late final TextEditingController minController;
  late final TextEditingController maxController;

  PriceFilter? get priceFilter =>
      widget.state.filters.whereType<PriceFilter>().firstOrNull;

  @override
  void initState() {
    minController = TextEditingController(text: priceFilter?.min?.toString());
    maxController = TextEditingController(text: priceFilter?.max?.toString());
    super.initState();
  }

  void setPriceFilter(BuildContext context) {
    final double? min = double.tryParse(minController.text);
    final double? max = double.tryParse(maxController.text);
    final List<Filter> newFilters = [...widget.state.filters];

    if (priceFilter != null) {
      newFilters.remove(priceFilter);
    }
    // Add new PriceFilter only if at least one field is not empty
    if (min != null || max != null) {
      newFilters.add(PriceFilter(min: min, max: max));
    }

    widget.setProductFilters(filters: newFilters);
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Set price filter'),
      contentPadding: const EdgeInsets.all(16.0),
      children: [
        _buildPriceElement(prefix: 'Min', controller: minController),
        _buildPriceElement(prefix: 'Max', controller: maxController),
        const Divider(),
        OutlinedButton(
          onPressed: () {
            setPriceFilter(context);
            Navigator.of(context).pop();
          },
          child: const Text('Set'),
        ),
      ],
    );
  }

  /// This function returns a list of input field formatters for handling
  /// floating-point numbers input in text fields. It restricts allowed input to
  /// digits, a single dot or comma (as a decimal separator) and up to two decimal places.
  static List<TextInputFormatter> get positivefloatInputFieldFormatters => [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\,?\d{0,2}')),
      ];

  Widget _buildPriceElement({
    String? prefix,
    required TextEditingController controller,
  }) {
    return Row(
      children: [
        if (prefix != null)
          Expanded(
            flex: 1,
            child: Text('$prefix:'),
          ),
        Expanded(
          flex: 3,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: positivefloatInputFieldFormatters,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    minController.dispose();
    maxController.dispose();
    super.dispose();
  }
}
