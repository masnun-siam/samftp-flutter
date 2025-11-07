// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.title,
    required this.onPressed,
    required this.url,
  });

  final String title;
  final VoidCallback onPressed;
  final String url;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Color> _getGradientColors(String title, bool isSuccess, bool isDark) {
    if (!isSuccess) {
      return isDark
          ? [
              const Color(0xFF991B1B).withOpacity(0.3),
              const Color(0xFF7F1D1D).withOpacity(0.2),
            ]
          : [
              const Color(0xFFFECDD3).withOpacity(0.8),
              const Color(0xFFFDA4AF).withOpacity(0.6),
            ];
    }

    final gradients = {
      'English Movies': isDark
          ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
          : [const Color(0xFF818CF8), const Color(0xFFA78BFA)],
      'Foreign Movies': isDark
          ? [const Color(0xFFEC4899), const Color(0xFFF43F5E)]
          : [const Color(0xFFF472B6), const Color(0xFFFB7185)],
      'Hindi Movies': isDark
          ? [const Color(0xFFF59E0B), const Color(0xFFF97316)]
          : [const Color(0xFFFBBF24), const Color(0xFFFB923C)],
      'Animation Movies': isDark
          ? [const Color(0xFF10B981), const Color(0xFF14B8A6)]
          : [const Color(0xFF34D399), const Color(0xFF2DD4BF)],
      'South Indian Movies': isDark
          ? [const Color(0xFF8B5CF6), const Color(0xFFD946EF)]
          : [const Color(0xFFA78BFA), const Color(0xFFE879F9)],
      'Hindi Dubbed Movies': isDark
          ? [const Color(0xFFEF4444), const Color(0xFFF59E0B)]
          : [const Color(0xFFF87171), const Color(0xFFFBBF24)],
      'Bangla Movies': isDark
          ? [const Color(0xFF06B6D4), const Color(0xFF3B82F6)]
          : [const Color(0xFF22D3EE), const Color(0xFF60A5FA)],
      'Series': isDark
          ? [const Color(0xFFF43F5E), const Color(0xFFEC4899)]
          : [const Color(0xFFFB7185), const Color(0xFFF472B6)],
      'KDrama': isDark
          ? [const Color(0xFFD946EF), const Color(0xFFA855F7)]
          : [const Color(0xFFE879F9), const Color(0xFFC084FC)],
      'Anime': isDark
          ? [const Color(0xFF6366F1), const Color(0xFF06B6D4)]
          : [const Color(0xFF818CF8), const Color(0xFF22D3EE)],
    };

    return gradients[title] ??
        (isDark
            ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
            : [const Color(0xFF818CF8), const Color(0xFFA78BFA)]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cleanUrl = widget.url.replaceAll('http://', '').replaceAll('/', '');

    return StreamBuilder<PingData>(
        stream: switch (kIsWeb) {
          false => Ping(cleanUrl).stream,
          _ => Stream.value(
              const PingData(
                response: PingResponse(time: Duration.zero),
              ),
            ),
        },
        builder: (context, snapshot) {
          final isSuccess = snapshot.data?.response?.time != null;
          return ResponsiveBuilder(builder: (context, sizingInformation) {
            return InkWell(
              onTap: onPressed,
              child: Card(
                color: isSuccess ? Colors.green.shade300 : Colors.red.shade300,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      title.split(' ').join('\n'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: switch (sizingInformation.deviceScreenType) {
                          DeviceScreenType.desktop => 20,
                          DeviceScreenType.tablet => 16,
                          _ => 12,
                        },
                      )
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
