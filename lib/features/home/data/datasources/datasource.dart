
import 'package:injectable/injectable.dart';

import '../../../../core/helper/http_helper.dart';

import 'package:html/dom.dart' as dom;

abstract class DataSource {
  Future<List<({String? title, String? url})>> getWebsiteFiles(String url);
  Future<String?> getBaseUrl(String url);
}

@LazySingleton(as: DataSource)
class DataSourceImpl implements DataSource {
  @override
  Future<List<({String? title, String? url})>> getWebsiteFiles(
      String url) async {
    final List<({String? title, String? url})> folders = [];

    final response = await HttpHelper.get(url);
    final document = dom.Document.html(response);

    final links = document
        .getElementsByClassName('fb-n')
        // .querySelectorAll('td > a')
        .map((e) {
      return e.querySelector('a')?.attributes['href']?.trim();
    })
        // .map((e) => e.querySelector('a > span')?.innerHtml.trim())
        .toList();
    final titles = document
        .getElementsByClassName('fb-n')
        // .querySelectorAll('td > a')
        .map((e) {
      return e.querySelector('a')?.innerHtml.trim();
    }).toList();

    for (var i = 2; i < titles.length; i++) {
      final title = titles[i];
      final link = links[i];
      folders.add((title: title, url: link?.toString()));
    }
    return folders;
  }

  @override
  Future<String?> getBaseUrl(String url) async {
    final response = await HttpHelper.get(url);
    final document = dom.Document.html(response);
    final links = document
        .getElementsByClassName('fb-n')
        // .querySelectorAll('td > a')
        .map((e) {
      return e
          .querySelector('a')
          ?.attributes['href']
          ?.trim()
          .replaceAll('..', '');
    }).toList();
    return links[1];
  }
}
