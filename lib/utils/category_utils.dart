import 'package:flutter/material.dart';

class CategoryUtils {
  static String? getCategoryIconPath(String categoryName) {
    final normalized = categoryName.toLowerCase().trim();
    
    if (normalized == 'fashion' || normalized == 'clothing' || normalized == 'apparel') {
      return 'assets/icons/fashion_icon.svg';
    }
    
    if (normalized == 'grocery' || normalized == 'groceries' || normalized == 'supermarket' || normalized == 'mart') {
      return 'assets/icons/grocery.svg';
    }

    if (normalized == 'electronics' || normalized == 'tech' || normalized == 'appliances' || normalized == 'gadgets') {
      return 'assets/icons/electronics.svg';
    }

    if (normalized == 'health' || normalized == 'medical' || normalized == 'wellness' || normalized == 'pharmacy') {
      return 'assets/icons/health.svg';
    }

    if (normalized == 'furniture' || normalized == 'decor' || normalized == 'home_decor' || normalized == 'home decor') {
      return 'assets/icons/furniture.svg';
    }
    
    // Add more mappings here as needed
    return null;
  }

  static IconData getDefaultIcon(String categoryName) {
    final normalized = categoryName.toLowerCase().trim();
    
    if (normalized == 'fashion' || normalized == 'clothing' || normalized == 'apparel') {
      return Icons.checkroom_rounded; // Fallback if SVG fails or in some contexts
    }
    
    if (normalized == 'grocery' || normalized == 'groceries' || normalized == 'supermarket' || normalized == 'mart') {
      return Icons.shopping_basket_rounded;
    }

    if (normalized == 'electronics' || normalized == 'tech' || normalized == 'appliances' || normalized == 'gadgets') {
      return Icons.electrical_services_rounded;
    }

    if (normalized == 'health' || normalized == 'medical' || normalized == 'wellness' || normalized == 'pharmacy') {
      return Icons.health_and_safety_rounded;
    }

    if (normalized == 'furniture' || normalized == 'decor' || normalized == 'home_decor' || normalized == 'home decor') {
      return Icons.chair_rounded;
    }
    
    return Icons.category_rounded;
  }
}
