import 'package:flutter/material.dart';
import 'package:inkombe_flutter/services/cattle_record.dart';
import 'package:inkombe_flutter/services/cattle_repository.dart';
import 'package:inkombe_flutter/widgets/list_card.dart';

class SearchCattlePage extends StatefulWidget {
  const SearchCattlePage({super.key});

  @override
  State<SearchCattlePage> createState() => _SearchCattlePageState();
}

class _SearchCattlePageState extends State<SearchCattlePage> {
  final TextEditingController _searchController = TextEditingController();
  List<CattleRecord> _searchResults = [];
  bool _isLoading = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Initial empty search or load all
    _performSearch('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _query = query;
    });

    try {
      final results = await CattleRepository().searchCattle(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error searching: $e');
      setState(() {
        _isLoading = false;
        _searchResults = [];
      });
    }
  }

  String? _getFirstImagePath(CattleRecord doc) {
    if (doc.localImagePaths != null && doc.localImagePaths!.isNotEmpty) {
      return doc.localImagePaths![0];
    }
    if (doc.imageUrls != null && doc.imageUrls!.isNotEmpty) {
      return doc.imageUrls![0];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Search Cattle',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search by name, breed, or age...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.black, fontSize: 18),
              onChanged: (value) {
                _performSearch(value);
              },
            ),
          ),
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Found ${_searchResults.length} result(s)',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              _query.isEmpty
                                  ? 'Start typing to search'
                                  : 'No matches found',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final cattle = _searchResults[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ListCard(
                              title: cattle.name,
                              date: cattle.date,
                              imagePath: _getFirstImagePath(cattle),
                              imageUri: cattle.imageUrls?.isNotEmpty == true
                                  ? cattle.imageUrls![0]
                                  : (cattle.image != null &&
                                          cattle.image!.isNotEmpty)
                                      ? cattle.image!
                                      : null,
                              docId: cattle.id,
                              onUpdate: () {
                                _performSearch(_query);
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
