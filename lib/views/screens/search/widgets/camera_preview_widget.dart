import 'package:flutter/material.dart';

class CameraControlsOverlay extends StatelessWidget {
  final VoidCallback onShutter;
  final VoidCallback onGallery;
  final VoidCallback onClose;
  final bool isFlashOn;
  final VoidCallback onToggleFlash;

  final Widget? bottomContent;

  const CameraControlsOverlay({
    super.key,
    required this.onShutter,
    required this.onGallery,
    required this.onClose,
    required this.isFlashOn,
    required this.onToggleFlash,
    this.bottomContent,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: onClose,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 24),
                      ),
                    ),
                    const Text(
                      'VISUAL SEARCH',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const Spacer(),
              // Bottom controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ControlButton(
                      icon: Icons.collections_outlined,
                      label: 'GALLERY',
                      onTap: onGallery,
                    ),
                    GestureDetector(
                      onTap: onShutter,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.search,
                              color: Colors.blue,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _ControlButton(
                      icon: isFlashOn ? Icons.flash_on : Icons.flash_off,
                      label: 'FLASH',
                      onTap: onToggleFlash,
                    ),
                  ],
                ),
              ),
              if (bottomContent != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: bottomContent,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.black38,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
