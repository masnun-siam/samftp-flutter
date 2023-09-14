// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    Key? key,
    required this.title,
    required this.onPressed,
    required this.url,
  }) : super(key: key);

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
          debugPrint(cleanUrl);
          debugPrint(snapshot.data?.response?.time.toString());
          debugPrint(snapshot.data?.error?.message);
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
          });
        });
  }
}
