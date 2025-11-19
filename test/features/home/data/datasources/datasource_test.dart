import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samftp/features/home/data/datasources/datasource.dart';

void main() {
  late String uri;
  setUp(() {
    uri =
        'http://172.16.50.12/SAM-FTP-1/TV-WEB-Series/TV%20Series%20%E2%98%85%20%200%20%20%E2%80%94%20%209/2%20Broke%20Girls%20%28TV%20Series%202011%E2%80%93%20%29%20720p/Season%201/';
  });
  test('should get a list of titles', () async {
    // arrange
    final result = await DataSourceImpl().getWebsiteFiles(uri);
    debugPrint(result.map((e) => e.url).toString());
    expect(result, isA<List<({String? title, String? url})>>());
  });
}
