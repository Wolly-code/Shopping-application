import 'package:daraz/screens/cart_screen.dart';
import 'package:daraz/screens/product_detail_screen.dart';
import 'package:daraz/screens/products_overview.dart';
import 'package:daraz/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/orders_screen.dart';
import './provider/cart.dart';
import 'provider/orders.dart';
import 'provider/product_provider.dart';
import 'screens/user_product_screen.dart';
import 'screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './provider/auth.dart';
import 'helpers/custom_route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (ctx) => Products('', [], ''),
            update: (BuildContext context, auth, previousProducts) => Products(
                auth.token.toString(),
                previousProducts == null ? [] : previousProducts.items,
                auth.userId.toString()),
          ),
          ChangeNotifierProvider(
            create: (context) => Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (ctx) => Orders('', [], ''),
            update: (BuildContext context, auth, previousProducts) => Orders(
                auth.token.toString(),
                previousProducts == null ? [] : previousProducts.orders,
                auth.userId.toString()),
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, child) => MaterialApp(
            title: 'Daraz',
            theme: ThemeData(
                primarySwatch: Colors.cyan,
                accentColor: Colors.deepOrange,
                fontFamily: 'Lato',
                pageTransitionsTheme: PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: CustomPageTransitionBuilder(),
                  },
                )),
            home: auth.isAuth
                ? ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen()),
            routes: {
              ProductDetailScreen.routeName: (ctx) =>
                  const ProductDetailScreen(),
              CartScreen.routeName: (ctx) => const CartScreen(),
              OrdersScreen.routeName: (ctx) => const OrdersScreen(),
              UserProductsScreen.routeName: (ctx) => const UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => const EditProductScreen(),
            },
          ),
        ));
  }
}
