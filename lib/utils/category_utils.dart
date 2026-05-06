import 'package:flutter/material.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';

class CategoryUtils {
  CategoryUtils._();
  static final CategoryUtils instance = CategoryUtils._();

  static SvgGenImage? getCategoryIcon(String categoryName) {
    final normalized = categoryName.toLowerCase().trim();

    switch (normalized) {
      case 'fashion' || 'clothing' || 'apparel':
        return Assets.icons.fashionIcon;
      case 'grocery' || 'groceries' || 'supermarket' || 'mart':
        return Assets.icons.grocery;
      case 'electronics' || 'tech' || 'appliances' || 'gadgets':
        return Assets.icons.electronics;
      case 'health' || 'medical' || 'wellness' || 'pharmacy':
        return Assets.icons.health;
      case 'furniture' || 'decor' || 'home_decor' || 'home decor':
        return Assets.icons.furniture;
      default:
        return null;
    }
  }

  static IconData getDefaultIcon(String categoryName) {
    final normalized = categoryName.toLowerCase().trim();

    switch (normalized) {
      case 'fashion' || 'clothing' || 'apparel':
        return Icons.checkroom_rounded;
      case 'grocery' || 'groceries' || 'supermarket' || 'mart':
        return Icons.shopping_basket_rounded;
      case 'electronics' || 'tech' || 'appliances' || 'gadgets':
        return Icons.electrical_services_rounded;
      case 'health' || 'medical' || 'wellness' || 'pharmacy':
        return Icons.health_and_safety_rounded;
      case 'furniture' || 'decor' || 'home_decor' || 'home decor':
        return Icons.chair_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
