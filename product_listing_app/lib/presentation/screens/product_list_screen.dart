import 'package:flutter/material.dart';
import 'package:product_listing_app/presentation/screens/product_form_screen.dart';
import 'package:product_listing_app/presentation/widgets/product_tile.dart';
import 'package:provider/provider.dart';
import 'package:product_listing_app/presentation/providers/product_provider.dart';
import 'package:product_listing_app/presentation/providers/theme_provider.dart';
import 'package:product_listing_app/models/product.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'none';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshProducts() async {
    await context.read<ProductProvider>().fetchProducts();
  }

  void _showProductOptions(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Product'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductFormScreen(product: product),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Delete Product',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, product.id, product.productName);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDelete(int productId) async {
    try {
      await context.read<ProductProvider>().deleteProduct(productId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
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
    }
  }

  void _confirmDelete(BuildContext context, int productId, String productName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to delete "$productName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _handleDelete(productId); 
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          title: const Text('Products'),
          leading: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              IconData iconData;
              if (themeProvider.isDarkMode) {
                iconData = Icons.dark_mode;
              } else {
                iconData = Icons.light_mode;
              }

              return IconButton(
                icon: Icon(iconData),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
                tooltip: themeProvider.isDarkMode
                    ? 'Switch to light mode'
                    : 'Switch to dark mode',
              );
            },
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort_outlined),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                setState(() {
                  _sortBy = value;
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'none', child: Text('No Sort')),
                const PopupMenuItem(
                  value: 'price_asc',
                  child: Text('Price: Low to High'),
                ),
                const PopupMenuItem(
                  value: 'price_desc',
                  child: Text('Price: High to Low'),
                ),
                const PopupMenuItem(
                  value: 'stock_asc',
                  child: Text('Stock: Low to High'),
                ),
                const PopupMenuItem(
                  value: 'stock_desc',
                  child: Text('Stock: High to Low'),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search_outlined),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            Expanded(
              child: Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  return provider.products.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error) => _buildErrorState(error.toString()),
                    success: (products) {
                      var filteredProducts = products.where((product) {
                        return product.productName.toLowerCase().contains(
                          _searchQuery,
                        );
                      }).toList();

                      switch (_sortBy) {
                        case 'price_asc':
                          filteredProducts.sort(
                            (a, b) => a.price.compareTo(b.price),
                          );
                          break;
                        case 'price_desc':
                          filteredProducts.sort(
                            (a, b) => b.price.compareTo(a.price),
                          );
                          break;
                        case 'stock_asc':
                          filteredProducts.sort(
                            (a, b) => a.stock.compareTo(b.stock),
                          );
                          break;
                        case 'stock_desc':
                          filteredProducts.sort(
                            (a, b) => b.stock.compareTo(a.stock),
                          );
                          break;
                      }

                      if (filteredProducts.isEmpty) {
                        return _buildEmptyState();
                      }

                      return RefreshIndicator(
                        onRefresh: _refreshProducts,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return ProductTile(
                              key: ValueKey(product.id),
                              product: product,
                              onTap: () =>
                                  _showProductOptions(context, product),
                              onDelete: () => _handleDelete(product.id),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => const ProductFormScreen()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Product'),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Error: $error',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _refreshProducts,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No products found',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
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
