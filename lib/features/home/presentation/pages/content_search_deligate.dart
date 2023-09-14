import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:samftp/features/home/domain/entities/clickable_model/clickable_model.dart';

class ContentSearchDelegate extends SearchDelegate<ClickableModel?> {
  final List<ClickableModel> list;
  ContentSearchDelegate(this.list);
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.close),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _results();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _results();
  }

  Widget _results() {
    // String cleanQuery = query
    //     .split('')
    //     .where((element) => RegExp('[a-zA-Z0-9]').hasMatch(element))
    //     .join('')
    //     .toLowerCase();

    final results = extractAllSorted<ClickableModel>(
      query: query,
      choices: list,
      getter: (obj) => obj.title.split('(').first,
    ).map((e) => e.choice).toList();

    // final results = list.where((element) {
    //   final cleanTitle = element.title
    //       .split('')
    //       .where((element) => RegExp('[a-zA-Z0-9]').hasMatch(element))
    //       .join('')
    //       .toLowerCase();
    //   return cleanTitle.contains(cleanQuery);
    // }).toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final model = results[index];
        return ListTile(
          leading: Icon(model.isFile ? Icons.file_copy : Icons.folder),
          title: Text(
            (model.title.endsWith('/')
                    ? model.title.substring(0, model.title.length - 1)
                    : model.title)
                .split('/')
                .last,
          ),
          onTap: () {
            close(context, model);
          },
        );
      },
    );
  }
}
