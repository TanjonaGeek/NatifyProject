import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:natify/features/User/presentation/widget/list/shimmer/shimmerLoading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loadmore_listview/loadmore_listview.dart';

class PaysListPage extends ConsumerStatefulWidget {
  final List<Map<String, String>> listPays;
  const PaysListPage({required this.listPays, super.key});
  @override
  _PaysListPageState createState() => _PaysListPageState();
}

class _PaysListPageState extends ConsumerState<PaysListPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> _displayedList = [];
  List<Map<String, String>> _filteredList = [];
  final int pageSize = 20;
  int currentPage = 0;
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadMorePays();
  }

  Future<void> loadMorePays() async {
    List<Map<String, String>> allPays = widget.listPays;
    await Future.delayed(Duration(seconds: 1));
    int start = currentPage * pageSize;
    int end = start + pageSize;

    if (start < allPays.length) {
      setState(() {
        _displayedList.addAll(allPays.sublist(
            start, end > allPays.length ? allPays.length : end));
        _filteredList = _displayedList;
        currentPage++;
        isLoading = false;
      });
    }
  }

  void filterPays(String query) {
    List<Map<String, String>> allPays = widget.listPays;
    List<Map<String, String>> results = [];
    if (query.isEmpty) {
      results = _displayedList;
    } else {
      results = allPays
          .where((nationalite) => nationalite['country']!
              .toLowerCase()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredList = results;
      searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Liste pays'.tr,
              style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: Center(
                    child: FaIcon(FontAwesomeIcons.chevronLeft, size: 20))),
            onPressed: () {
              // Action for the back button
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNationaliteSearchInput(),
              Expanded(
                child: isLoading
                    ? Shimmerloading(
                        length: 10,
                        horz: 1.0,
                        vert: 8.0,
                      )
                    : LoadMoreListView.builder(
                        hasMoreItem: true,
                        onLoadMore: () async {
                          await loadMorePays();
                        },
                        refreshBackgroundColor: Colors.blueAccent,
                        loadMoreWidget: ShimmerListTile(
                          horz: 1,
                          vert: 8.0,
                        ),
                        itemCount: _filteredList.length,
                        itemBuilder: (context, index) {
                          final item = _filteredList[index];
                          return GestureDetector(
                            onTap: () => Navigator.pop(context, item),
                            child: _buildOption(
                              icon: Text(
                                '${item['flagCode']}',
                                style: TextStyle(fontSize: 20),
                              ),
                              title: "${item['country']}",
                              value: index,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNationaliteSearchInput() {
    return TextFormField(
      controller: _searchController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0), // Bordure arrondie
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color:
                Colors.black54, // Couleur de la bordure lorsqu'il est en focus
            width: 2.0, // Épaisseur de la bordure
          ),
          borderRadius:
              BorderRadius.circular(20.0), // Garder le même border radius
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red, // Couleur de la bordure lorsqu'il est en focus
            width: 2.0, // Épaisseur de la bordure
          ),
          borderRadius:
              BorderRadius.circular(20.0), // Garder le même border radius
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        hintText: 'Rechercher'.tr,
      ),
      onChanged: (query) => filterPays(query),
    );
  }

  Widget _buildOption({
    required Widget icon,
    required String title,
    required int value,
  }) {
    return ListTile(
      leading: icon,
      title: Text(title),
      trailing: Icon(Icons.arrow_right_sharp),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 1.0, horizontal: 7.0),
    );
  }
}
