import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/sample_products.dart';
import '../models/product.dart';

final productsProvider = Provider<List<Product>>((ref) {
  return sampleProducts;
});

final productByIdProvider = Provider.family<Product?, String>((ref, id) {
  final products = ref.watch(productsProvider);
  try {
    return products.firstWhere((product) => product.id == id);
  } catch (e) {
    return null;
  }
});
