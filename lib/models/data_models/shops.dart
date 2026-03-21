
import 'package:nearvendorapp/models/ui_models/shop_model.dart';

enum ShopsCategory {
  hardware,
  groceries,
  books,
}

extension ShopsCategoryExtension on ShopsCategory {
  String get displayName {
    switch (this) {
      case ShopsCategory.hardware:
        return 'Hardware';
      case ShopsCategory.groceries:
        return 'Groceries';
      case ShopsCategory.books:
        return 'Books';
    }
  }

  // String get description {
  //   switch (this) {
  //     case DAppCategory.lending:
  //       return LocaleKeys.categoryLendingDescription.tr();
  //     case DAppCategory.dex:
  //       return LocaleKeys.categoryDexDescription.tr();
  //     case DAppCategory.staking:
  //       return LocaleKeys.categoryStakingDescription.tr();
  //     case DAppCategory.yield:
  //       return LocaleKeys.categoryYieldDescription.tr();
  //     case DAppCategory.nft:
  //       return LocaleKeys.nftMarketplaceDescription.tr();
  //   }
  // }
}

class ShopsData {
  ShopsData._();

  static List<ShopModel> dummyShops = [
    ShopModel(
      name: 'Product',
      image: 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=400',
      category: 'Food',
      location: '5 KMs Away',
      latitude: 33.667306,
      longitude: 73.075177,
    ),
    ShopModel(
      name: 'Product',
      image: 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=400',
      category: 'Food',
      location: '5 KMs Away',
      latitude: 33.667306,
      longitude: 73.075177,
    ),
    ShopModel(
      name: 'Product',
      image: 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=400',
      category: 'Food',
      location: '5 KMs Away',
      latitude: 33.667306,
      longitude: 73.075177,
    ),
    ShopModel(
      name: 'Product',
      image: 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=400',
      category: 'Food',
      location: '5 KMs Away',
      latitude: 33.667306,
      longitude: 73.075177,
    ),
  ];

  static Map<ShopsCategory, List<ShopModel>> get shopByCategory {
    final Map<ShopsCategory, List<ShopModel>> result = {};

    for (final category in ShopsCategory.values) {
      result[category] = dummyShops
          .where((dapp) => dapp.category == category)
          .toList();
    }

    return result;
  }

  static List<ShopModel> getShopByCategory(ShopsCategory category) {
    return dummyShops.where((shop) => shop.category == category).toList();
  }

  static List<ShopsCategory> get availableCategories {
    return ShopsCategory.values.where((category) {
      return shopByCategory[category]?.isNotEmpty ?? false;
    }).toList();
  }

}
