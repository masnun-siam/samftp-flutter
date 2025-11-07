import 'package:flutter/material.dart';
import 'package:string_similarity/string_similarity.dart';
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

    // Use string_similarity to find best matches
    final scoredResults = list.map((item) {
      final itemTitle = item.title.split('(').first;
      final similarity = query.similarityTo(itemTitle);
      return MapEntry(item, similarity);
    }).toList();

    // Sort by similarity score (highest first)
    scoredResults.sort((a, b) => b.value.compareTo(a.value));

    final results = scoredResults.map((e) => e.key).toList();

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
