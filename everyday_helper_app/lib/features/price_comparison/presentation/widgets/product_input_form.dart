import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/product.dart';
import '../../../../shared/constants/app_constants.dart';
import 'pack_size_selector.dart';

class ProductInputForm extends StatefulWidget {
  final Product? initialProduct;
  final Function(Product) onProductCreated;
  final VoidCallback? onCancel;
  final bool isEditing;

  const ProductInputForm({
    super.key,
    this.initialProduct,
    required this.onProductCreated,
    this.onCancel,
    this.isEditing = false,
  });

  @override
  State<ProductInputForm> createState() => _ProductInputFormState();
}

class _ProductInputFormState extends State<ProductInputForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _individualQuantityController = TextEditingController();

  String _selectedUnit = '';
  final Map<String, String> _errors = {};
  int _packSize = 1;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.initialProduct != null) {
      final product = widget.initialProduct!;
      _nameController.text = product.name;
      _priceController.text = product.price > 0 ? product.price.toString() : '';
      _selectedUnit = product.unit;
      _packSize = product.packSize;

      // Only populate individual quantity (always pack mode now)
      _individualQuantityController.text = product.individualQuantity > 0
          ? product.individualQuantity.toString()
          : '';
    } else {
      _selectedUnit = AppConstants.defaultUnit;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _individualQuantityController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    setState(() {
      _errors.clear();
    });

    // Validate name
    if (_nameController.text.trim().isEmpty) {
      _errors['name'] = 'Product name is required';
    } else if (_nameController.text.trim().length >
        AppConstants.maxProductNameLength) {
      _errors['name'] =
          'Name too long (max ${AppConstants.maxProductNameLength} characters)';
    }

    // Validate price
    final priceText = _priceController.text.trim();
    if (priceText.isEmpty) {
      _errors['price'] = 'Price is required';
    } else {
      final price = double.tryParse(priceText);
      if (price == null) {
        _errors['price'] = 'Invalid price format';
      } else if (price <= 0) {
        _errors['price'] = 'Price must be greater than 0';
      } else if (price > AppConstants.maxPrice) {
        _errors['price'] = 'Price too high (max ${AppConstants.maxPrice})';
      }
    }

    // Validate pack-specific fields
    if (_packSize <= 0) {
      _errors['packSize'] = 'Pack size must be greater than 0';
    }

    final individualQuantityText = _individualQuantityController.text.trim();
    if (individualQuantityText.isEmpty) {
      _errors['individualQuantity'] = 'Individual quantity is required';
    } else {
      final individualQuantity = double.tryParse(individualQuantityText);
      if (individualQuantity == null) {
        _errors['individualQuantity'] = 'Invalid individual quantity format';
      } else if (individualQuantity <= 0) {
        _errors['individualQuantity'] =
            'Individual quantity must be greater than 0';
      } else if (individualQuantity > AppConstants.maxQuantity) {
        _errors['individualQuantity'] =
            'Individual quantity too high (max ${AppConstants.maxQuantity})';
      }
    }

    // Validate unit
    if (_selectedUnit.isEmpty) {
      _errors['unit'] = 'Unit is required';
    }

    setState(() {});

    if (_errors.isEmpty) {
      // Calculate total quantity for pack mode
      final totalQuantity =
          _packSize * double.parse(_individualQuantityController.text.trim());

      final product = Product(
        id:
            widget.initialProduct?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        quantity: totalQuantity,
        unit: _selectedUnit,
        packSize: _packSize,
        individualQuantity: double.parse(
          _individualQuantityController.text.trim(),
        ),
      );
      widget.onProductCreated(product);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.add_shopping_cart, color: theme.primaryColor),
                  const SizedBox(width: AppConstants.defaultMargin),
                  Text(
                    widget.isEditing ? 'Edit Product' : 'Add Product',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.defaultPadding),

              // Product Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Product Name *',
                  hintText: 'e.g., Organic Apples',
                  errorText: _errors['name'],
                  prefixIcon: const Icon(Icons.label_outline),
                ),
                textCapitalization: TextCapitalization.words,
                maxLength: AppConstants.maxProductNameLength,
              ),
              const SizedBox(height: AppConstants.defaultPadding),

              // Price field
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Total Price *',
                  hintText: 'Total price for the entire pack',
                  errorText: _errors['price'],
                  prefixIcon: const Icon(Icons.attach_money),
                  prefixText: '\$',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
              ),
              const SizedBox(height: AppConstants.defaultPadding),

              // Pack-specific fields
              // Pack Size Selector
              PackSizeSelector(
                value: _packSize,
                onChanged: (value) {
                  setState(() {
                    _packSize = value;
                    _errors.remove('packSize');
                  });
                },
                errorText: _errors['packSize'],
              ),
              const SizedBox(height: AppConstants.defaultPadding),

              // Individual Quantity - much clearer label
              TextFormField(
                controller: _individualQuantityController,
                decoration: InputDecoration(
                  labelText: 'Size of each item *',
                  hintText: 'e.g., 200 (if each bottle is 200ml)',
                  errorText: _errors['individualQuantity'],
                  prefixIcon: const Icon(Icons.straighten),
                  helperText: 'How much is in each individual piece?',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
                ],
                onChanged: (value) {
                  setState(() {
                    // Trigger rebuild to update the pack total display
                  });
                },
              ),
              const SizedBox(height: AppConstants.defaultPadding),

              // Pack Total Information - Auto-calculated total
              if (_packSize > 1 &&
                  _individualQuantityController.text.isNotEmpty) ...[
                Card(
                  color: Colors.green.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calculate,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: AppConstants.defaultMargin),
                            Text(
                              'Auto-calculated Total',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Builder(
                          builder: (context) {
                            final individualQty = double.tryParse(
                              _individualQuantityController.text.trim(),
                            );
                            if (individualQty != null) {
                              final total = _packSize * individualQty;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pack breakdown: $_packSize items × ${individualQty.toStringAsFixed(individualQty.truncateToDouble() == individualQty ? 0 : 1)} $_selectedUnit each',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Total quantity: ${total.toStringAsFixed(total.truncateToDouble() == total ? 0 : 1)} $_selectedUnit',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Text(
                              'Enter size of each item to see total',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
              ],

              // Unit Dropdown
              DropdownButtonFormField<String>(
                value: _selectedUnit.isEmpty ? null : _selectedUnit,
                decoration: InputDecoration(
                  labelText: 'Unit (per piece) *',
                  errorText: _errors['unit'],
                  prefixIcon: const Icon(Icons.straighten),
                  helperText: 'Unit for individual pieces',
                ),
                items: AppConstants.commonUnits.map((unit) {
                  return DropdownMenuItem(value: unit, child: Text(unit));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUnit = value ?? '';
                    _errors.remove('unit');
                  });
                },
              ),
              const SizedBox(height: AppConstants.defaultPadding * 1.5),

              // Buttons
              Row(
                children: [
                  if (widget.onCancel != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onCancel,
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppConstants.defaultPadding),
                  ],
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _validateAndSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(widget.isEditing ? 'Update' : 'Add Product'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
