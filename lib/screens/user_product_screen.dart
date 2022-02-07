import 'package:daraz/provider/product_provider.dart';
import 'package:daraz/screens/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widget/user_product_item.dart';
import 'edit_product_screen.dart';

class UserProductsScreen extends StatefulWidget {
  static const routeName = '/User-Products';

  const UserProductsScreen({Key? key}) : super(key: key);

  @override
  State<UserProductsScreen> createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  Future? _fetchFuture;
  Future _refreshProducts() async {
    return  Provider.of<Products>(context, listen: false).fetchAndSetProducts();
  }
  @override
  void initState() {
    _fetchFuture = _refreshProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('rebuilding..');
    final productData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(EditProductScreen.routeName, arguments: null);
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _fetchFuture,
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(),
                    child: Consumer<Products>(
                      builder: (ctx, productsData, _) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: productData.items.length,
                          itemBuilder: (ctx, i) => UserProductItem(
                            title: productData.items[i].title,
                            imageUrl: productData.items[i].imageUrl,
                            id: productData.items[i].id,
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
      drawer: const AppDrawer(),
    );
  }
}
