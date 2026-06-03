import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:toasty_box/toast_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@terarare.com',
      queryParameters: {
        'subject': 'NearVendor Support Request',
      },
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'Could not launch email';
      }
    } catch (_) {
      if (context.mounted) {
        ToastService.showErrorToast(
          context,
          message: 'Could not open mail client. Please copy the email address instead.',
        );
      }
    }
  }

  Future<void> _launchPhone(BuildContext context) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '05133456784',
    );
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        throw 'Could not launch phone';
      }
    } catch (_) {
      if (context.mounted) {
        ToastService.showErrorToast(
          context,
          message: 'Could not launch dialer. Please copy the phone number instead.',
        );
      }
    }
  }

  Future<void> _launchWebsite(BuildContext context) async {
    final Uri webUri = Uri.parse('https://www.nearvendor.com');
    try {
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch website';
      }
    } catch (_) {
      if (context.mounted) {
        ToastService.showErrorToast(
          context,
          message: 'Could not open browser. Please copy the website address instead.',
        );
      }
    }
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ToastService.showSuccessToast(
      context,
      message: '✨ $label copied to clipboard!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      bgColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Help & Support',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: theme.iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Support Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(28),

                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColorName.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.support_agent_sharp,
                        color: ColorName.primary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'How can we help?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Our support team is online and ready to assist you. Select any option below to connect with us.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        height: 1.5,
                        fontFamily: 'Poppins',
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Section Title
              Text(
                'CONTACT CHANNELS',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: isDark ? Colors.white38 : Colors.black45,
                ),
              ),
              const SizedBox(height: 12),

              // Contact cards
              _buildContactCard(
                context,
                icon: Icons.mail_outline_outlined,
                title: 'Email Us',
                value: 'support@antilineartech.com',
                color: Colors.amber,
                isDark: isDark,
                theme: theme,
                onTap: () => _launchEmail(context),
                onCopy: () => _copyToClipboard(
                  context,
                  'support@antilineartech.com',
                  'Email address',
                ),
              ),
              const SizedBox(height: 14),

              _buildContactCard(
                context,
                icon: Icons.phone_in_talk_rounded,
                title: 'Call Us',
                value: '0321-5383175',
                color: Colors.green,
                isDark: isDark,
                theme: theme,
                onTap: () => _launchPhone(context),
                onCopy: () => _copyToClipboard(
                  context,
                  '0321-5383175',
                  'Phone number',
                ),
              ),
              const SizedBox(height: 14),

              _buildContactCard(
                context,
                icon: Icons.language_rounded,
                title: 'Visit Website',
                value: 'https://nearvendor.vercel.app/',
                color: Colors.blue,
                isDark: isDark,
                theme: theme,
                onTap: () => _launchWebsite(context),
                onCopy: () => _copyToClipboard(
                  context,
                  'https://nearvendor.vercel.app/',
                  'Website URL',
                ),
              ),
              const SizedBox(height: 36),

              // FAQ Section
              Text(
                'FREQUENTLY ASKED QUESTIONS',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: isDark ? Colors.white38 : Colors.black45,
                ),
              ),
              const SizedBox(height: 16),

              _buildFAQItem(
                context,
                question: 'How do I find vendors near me?',
                answer:
                    'Enable location services in the app or device settings, and use the distance slider in your profile preferences to adjust your search radius.',
                isDark: isDark,
                theme: theme,
              ),
              const SizedBox(height: 12),

              _buildFAQItem(
                context,
                question: 'Can I request unavailable items?',
                answer:
                    'Yes! Navigate to the Search or Wishes tab and click "Make a Wish". Local shops registered in that category will be notified instantly when they stock it.',
                isDark: isDark,
                theme: theme,
              ),
              const SizedBox(height: 12),

              _buildFAQItem(
                context,
                question: 'How do I update my profile details?',
                answer:
                    'Head to your Profile tab, click the camera icon on your avatar image, or click edit icon next to your credentials to update your account.',
                isDark: isDark,
                theme: theme,
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDark,
    required ThemeData theme,
    required VoidCallback onTap,
    required VoidCallback onCopy,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.08 : 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),

                    child: Icon(
                      icon,
                      color: ColorName.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.copy_rounded,
                      size: 20,
                      color: isDark ? Colors.white30 : Colors.grey.shade400,
                    ),
                    onPressed: onCopy,
                    tooltip: 'Copy details',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context, {
    required String question,
    required String answer,
    required bool isDark,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.08 : 0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.question_mark,
                size: 16,
                color: ColorName.primary.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    fontFamily: 'Poppins',
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              answer,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12.5,
                height: 1.5,
                fontFamily: 'Poppins',
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
