import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reread/seller/pages/edit_profile_page.dart';
import 'package:reread/seller/pages/messages_page.dart';
import 'package:reread/seller/pages/notifications_page.dart';
import 'package:reread/seller/pages/order_tracking_page.dart';
import 'package:reread/seller/pages/sell_a_book_page.dart';
import 'package:reread/seller/pages/seller_catalog_page.dart';
import 'package:reread/seller/pages/seller_dashboard.dart';
import 'package:reread/seller/pages/transaction_history_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:reread/pages/main_pages/login.dart';
import 'package:reread/pages/main_pages/register.dart';
import 'package:reread/pages/main_pages/about_us_page.dart';
import 'package:reread/pages/main_pages/faqs_page.dart';

import 'package:reread/pages/buyer_pages/home_page.dart';
import 'package:reread/pages/buyer_pages/profile_page.dart';
import 'package:reread/pages/buyer_pages/cart_page.dart';
import 'package:reread/pages/buyer_pages/categories_page.dart';
import 'package:reread/pages/buyer_pages/new_arrivals_page.dart';
import 'package:reread/pages/buyer_pages/sell_book_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final session = supabase.auth.currentSession;

    return MaterialApp(
      title: 'Re:Read',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFECE6DF),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE05627)),
        useMaterial3: true,
      ),

      // initialRoute: session != null ? '/home' : '/login',
      initialRoute: '/profile_page',
      
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/cart': (context) => const CartPage(),
        '/categories': (context) => const CategoriesPage(),
        '/newArrivals': (context) => const NewArrivalsPage(),
        '/sellBook': (context) => const SellBookPage(),
        '/aboutUs': (context) => const AboutUsPage(),
        '/faqs': (context) => const FaqsPage(),
        
      },

      // Bagian Seller 
      onGenerateRoute: (settings) {
        Widget? page;
        
        switch (settings.name) {
          case '/seller_dashboard':
            page = const SellerDashboard();
            break;
          case '/seller_catalog_page':
            page = SellerCatalogPage();
            break;
          case '/sell_a_book_page':
            page = const SellABookPage();
            break;
          case '/transaction_history_page':
            page = const TransactionHistoryPage();
            break;
          case '/notifications_page':
            page = const NotificationsPage();
            break;
          case '/profile_page':
            page = const ProfilePage();
            break;
          case '/edit_profile_page':
            page = EditProfilePage();
            break;
          case '/order_tracking_page':
            page = const OrderTrackingPage();
            break;
          case '/messages_page':
            page = const MessagesPage();
            break;
        }

        if (page != null) {
          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) => page!,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          );
        }
 
        return null; 
      },
    );
  }
}