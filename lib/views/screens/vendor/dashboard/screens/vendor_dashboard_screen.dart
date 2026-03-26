import 'package:flutter/material.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';
import 'package:nearvendorapp/views/screens/vendor/add_product/screens/add_product_screen.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';

class VendorDashboardScreen extends StatelessWidget {
  final bool isShopCreated;
  const VendorDashboardScreen({super.key, this.isShopCreated = false});

  @override
  Widget build(BuildContext context) {
    if (!isShopCreated) {
      return _buildNoShopState(context);
    }

    return AppScaffold(
      bgColor: Colors.white,
      appBar: AppBar(
        title: const Text('Shop Profile View', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined, color: Colors.black)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShopHeader(context),
            SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
            _buildShopStats(context),
            SizedBox(height: AppSpacing.largeVerticalSpacing(context)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shop Ads',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text('0 ads', style: TextStyle(color: Colors.grey.shade400)),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Icon(Icons.ads_click, size: 64, color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  Text('No ads yet', style: TextStyle(color: Colors.grey.shade400)),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AppNavigator.push(context, const AddProductScreen()),
        backgroundColor: ColorName.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildNoShopState(BuildContext context) {
    return AppScaffold(
      bgColor: Colors.white,
      appBar: AppBar(
        title: const Text('Merchant Console', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.storefront, size: 80, color: ColorName.primary),
              const SizedBox(height: 24),
              Text(
                'No Shop Found',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'You haven\'t created any shops yet. Create your first shop to start selling on NearVendor.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to shop creation screen (to be implemented)
                    // Currently, we might go back to onboarding if that's the flow
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorName.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Create My First Shop', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopHeader(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1578916171728-46686eac8d58?auto=format&fit=crop&q=80&w=800'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, 40),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=vendor1'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 45),
        const Text(
          'karyana AZ',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Rana Faraz Asad',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildHeaderAction(Icons.share, 'Share'),
            const SizedBox(width: 8),
            _buildHeaderAction(Icons.qr_code, 'QR Code'),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderAction(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ColorName.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildShopStats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Shop Ratings', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (index) => Icon(Icons.star, size: 16, color: Colors.grey.shade300)),
                ),
              ],
            ),
          ),
          Container(height: 40, width: 1, color: Colors.grey.shade300),
          const Expanded(
            child: Column(
              children: [
                Text('0 Reviews', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(height: 40, width: 1, color: Colors.grey.shade300),
          const Expanded(
            child: Column(
              children: [
                Text('No Reviews', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
