import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/price_comparison_view_model.dart';
import '../widgets/product_input_form.dart';
import '../widgets/results_display.dart';
import '../widgets/help_dialog.dart';
import '../../domain/models/product.dart';
import '../../../../shared/constants/app_constants.dart';

class PriceComparisonScreen extends StatefulWidget {
  const PriceComparisonScreen({super.key});

  @override
  State<PriceComparisonScreen> createState() => _PriceComparisonScreenState();
}

class _PriceComparisonScreenState extends State<PriceComparisonScreen> {
  bool _showAddForm = false;
  Product? _editingProduct;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PriceComparisonViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Price Comparison'),
          actions: [
            IconButton(
              onPressed: () => HelpDialog.show(context),
              icon: const Icon(Icons.help_outline),
              tooltip: 'Help & Instructions',
            ),
            Consumer<PriceComparisonViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.hasProducts) {
                  return IconButton(
                    onPressed: () => _showClearAllDialog(context, viewModel),
                    icon: const Icon(Icons.clear_all),
                    tooltip: 'Clear All',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: Consumer<PriceComparisonViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                // Error message
                if (viewModel.errorMessage != null)
                  _buildErrorBanner(context, viewModel),

                // Main content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        _buildHeader(context, viewModel),
                        const SizedBox(height: AppConstants.defaultPadding),

                        // Add/Edit form
                        if (_showAddForm || _editingProduct != null)
                          _buildProductForm(context, viewModel),

                        // Add button
                        if (!_showAddForm && _editingProduct == null)
                          _buildAddButton(context, viewModel),

                        // Results
                        if (viewModel.hasProducts) ...[
                          const SizedBox(height: AppConstants.defaultPadding),
                          ResultsDisplay(
                            comparisonResult: viewModel.comparisonResult,
                            onEditProduct: (product) =>
                                _startEditingProduct(product),
                            onDeleteProduct: (product) =>
                                _deleteProduct(context, viewModel, product),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorBanner(
    BuildContext context,
    PriceComparisonViewModel viewModel,
  ) {
    return Container(
      width: double.infinity,
      color: Colors.red.withValues(alpha: 0.1),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: AppConstants.defaultMargin),
          Expanded(
            child: Text(
              viewModel.errorMessage!,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
          IconButton(
            onPressed: viewModel.clearError,
            icon: const Icon(Icons.close, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    PriceComparisonViewModel viewModel,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Compare Product Prices',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.defaultMargin),
        Text(
          'Add products to compare their price per unit and find the best value.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        if (viewModel.hasProducts) ...[
          const SizedBox(height: AppConstants.defaultMargin),
          Text(
            viewModel.getComparisonSummary(),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.primaryColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProductForm(
    BuildContext context,
    PriceComparisonViewModel viewModel,
  ) {
    return ProductInputForm(
      initialProduct: _editingProduct,
      isEditing: _editingProduct != null,
      onProductCreated: (product) {
        if (_editingProduct != null) {
          // Update existing product
          final index = viewModel.products.indexWhere(
            (p) => p.id == _editingProduct!.id,
          );
          if (index != -1) {
            viewModel.updateProduct(index, product);
          }
          _editingProduct = null;
        } else {
          // Add new product
          viewModel.addProduct(product);
          _showAddForm = false;
        }
        setState(() {});
      },
      onCancel: () {
        setState(() {
          _showAddForm = false;
          _editingProduct = null;
        });
      },
    );
  }

  Widget _buildAddButton(
    BuildContext context,
    PriceComparisonViewModel viewModel,
  ) {
    final canAddMore =
        viewModel.productCount < AppConstants.maxProductsPerComparison;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canAddMore
            ? () {
                setState(() {
                  _showAddForm = true;
                });
              }
            : null,
        icon: const Icon(Icons.add),
        label: Text(
          canAddMore
              ? 'Add Product'
              : 'Maximum ${AppConstants.maxProductsPerComparison} products reached',
        ),
      ),
    );
  }

  void _startEditingProduct(Product product) {
    setState(() {
      _editingProduct = product;
      _showAddForm = false;
    });
  }

  void _deleteProduct(
    BuildContext context,
    PriceComparisonViewModel viewModel,
    Product product,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${product.displayName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              viewModel.removeProductById(product.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.displayName} deleted'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(
    BuildContext context,
    PriceComparisonViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Products'),
        content: const Text(
          'Are you sure you want to remove all products? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              viewModel.clearAllProducts();
              Navigator.of(context).pop();
              setState(() {
                _showAddForm = false;
                _editingProduct = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All products cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
