import 'package:flutter/material.dart';
import 'package:nearvendorapp/models/data_models/shop_model.dart';

class ShopCard extends StatelessWidget {
  final Shop shop;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const ShopCard({
    super.key,
    required this.shop,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: theme.primaryColor.withOpacity(isDark ? 0.1 : 0.02),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
          border: Border.all(color: theme.dividerColor.withOpacity(0.1), width: 1.5),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'shop_logo_${shop.id}',
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(24),
                          image: shop.storeLogoUrl != null && shop.storeLogoUrl!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(shop.storeLogoUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: shop.storeLogoUrl == null || shop.storeLogoUrl!.isEmpty
                            ? Icon(Icons.store_rounded, color: theme.primaryColor, size: 36)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            shop.shopName,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 19,
                              color: theme.textTheme.titleLarge?.color,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: shop.isActive ? const Color(0xFF34C759) : Colors.red,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (shop.isActive ? const Color(0xFF34C759) : Colors.red).withOpacity(0.4),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                shop.businessCategory.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildMoreButton(context),
                  ],
                ),
                const SizedBox(height: 28),
                _buildActionTile(context, Icons.location_on_rounded, shop.shopAddress),
                const SizedBox(height: 14),
                _buildActionTile(context, Icons.phone_android_rounded, shop.shopContactPhone),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusPill(context, shop.isActive),
                    _buildTimeBadge(context, shop.operatingHours.length),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: PopupMenuButton<String>(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.more_horiz_rounded, color: Colors.grey),
        ),
        onSelected: (value) {
          if (value == 'edit') onEdit();
          if (value == 'delete') onDelete();
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_note_rounded, size: 22, color: Colors.blue.shade600),
                const SizedBox(width: 12),
                Text('Manage Shop', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, color: theme.textTheme.bodyMedium?.color)),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_sweep_rounded, size: 22, color: Colors.red.shade600),
                const SizedBox(width: 12),
                const Text('Remove Shop', style: TextStyle(fontFamily: 'Poppins', color: Colors.red, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.iconTheme.color?.withOpacity(0.3)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill(BuildContext context, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF34C759).withOpacity(0.12) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        isActive ? 'OPEN NOW' : 'CLOSED',
        style: TextStyle(
          fontFamily: 'Poppins',
          color: isActive ? const Color(0xFF34C759) : Colors.red,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildTimeBadge(BuildContext context, int days) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_rounded, size: 12, color: theme.primaryColor.withOpacity(0.6)),
          const SizedBox(width: 8),
          Text(
            '$days Days Active',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
