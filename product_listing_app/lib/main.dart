import 'package:flutter/material.dart';
import 'package:product_listing_app/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:product_listing_app/presentation/providers/product_provider.dart';
import 'package:product_listing_app/presentation/providers/theme_provider.dart';
import 'package:product_listing_app/repositories/api_product_repository.dart';
import 'package:product_listing_app/presentation/screens/product_list_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (context) =>
              ProductProvider(repository: ApiProductRepository()),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Product Listing App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const ProductListScreen(),
          );
        },
      ),
    );
  }
}
