import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'widgets/search_body.dart';
import 'widgets/search_field.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceBase,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SearchField(
              controller: _controller,
              onChanged: (String value) => setState(() => _query = value),
              onClear: () {
                _controller.clear();
                setState(() => _query = '');
              },
            ),
            Expanded(
              child: SearchBody(
                query: _query.trim(),
                onSelectQuery: _selectQuery,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectQuery(String query) {
    _controller.text = query;
    setState(() => _query = query);
  }
}
