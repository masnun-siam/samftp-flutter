// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final cleanUrl = url.replaceAll('http://', '').replaceAll('/', '');
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
          return LayoutBuilder(builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final fontSize = screenWidth > 1200 ? 20.0
                : screenWidth > 600 ? 16.0
                : 12.0;

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
                      style: TextStyle(fontSize: fontSize)
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }
}
