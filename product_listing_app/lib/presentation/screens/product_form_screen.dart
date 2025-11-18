import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:product_listing_app/dtos/product_dto.dart';
import 'package:product_listing_app/models/product.dart';
import 'package:product_listing_app/presentation/providers/product_provider.dart';
import 'package:product_listing_app/presentation/widgets/custome_text_feild.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  bool _isLoading = false;

  bool get _isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.product?.productName ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stock.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Product name is required';
    }
    if (value.trim().length < 3) {
      return 'Product name must be at least 3 characters';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid number';
    }
    if (price <= 0) {
      return 'Price must be greater than 0';
    }
    return null;
  }

  String? _validateStock(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Stock is required';
    }
    final stock = int.tryParse(value);
    if (stock == null) {
      return 'Please enter a valid whole number';
    }
    if (stock < 0) {
      return 'Stock cannot be negative';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final productDto = ProductDto(
        id: widget.product?.id,
        productName: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        stock: int.parse(_stockController.text.trim()),
      );

      if (_isEditMode) {
        await context.read<ProductProvider>().updateProduct(productDto);
      } else {
        await context.read<ProductProvider>().addProduct(productDto);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Product updated' : 'Product added'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(_isEditMode ? 'Edit Product' : 'Add Product'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isEditMode) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: theme.primaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Editing: ${widget.product!.productName}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                CustomTextField(
                  controller: _nameController,
                  label: 'Product Name',
                  hint: 'Enter product name',
                  icon: Icons.shopping_bag_outlined,
                  validator: _validateName,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _priceController,
                  label: 'Price',
                  hint: 'Enter price',
                  icon: Icons.attach_money,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _validatePrice,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _stockController,
                  label: 'Stock',
                  hint: 'Enter stock quantity',
                  icon: Icons.inventory_2_outlined,
                  keyboardType: TextInputType.number,
                  validator: _validateStock,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _isEditMode ? 'Save Changes' : 'Add Product',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
