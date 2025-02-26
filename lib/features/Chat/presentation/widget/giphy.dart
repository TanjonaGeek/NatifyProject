import 'package:natify/core/utils/enums/message_enum.dart';
import 'package:natify/core/utils/helpers.dart';
import 'package:natify/features/Chat/presentation/provider/chat_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class GifPicker extends ConsumerStatefulWidget {
  final String uid;
  const GifPicker({
    required this.uid,
    super.key,
  });

  @override
  _GifPickerState createState() => _GifPickerState();
}

class _GifPickerState extends ConsumerState<GifPicker> {
  String selectedCategory = 'funny';
  List<String> gifs = [];
  List<String> filteredGifs = [];
  bool isLoading = true;
  String? errorMessage;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchGifsByCategory(selectedCategory); // Initial fetch by category
    searchController.addListener(_filterGifs);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterGifs);
    searchController.dispose();
    super.dispose();
  }

  void _fetchGifsByCategory(String category) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final cachedGifs = GifCache.get(category);
      if (cachedGifs != null) {
        setState(() {
          gifs = cachedGifs;
          filteredGifs = gifs;
          isLoading = false;
        });
      } else {
        final fetchedGifs =
            await Helpers.fetchGifs(category); // Fetching by category
        setState(() {
          gifs = fetchedGifs;
          filteredGifs = gifs;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load GIFs. Please try again later.';
      });
    }
  }

  void _updateCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
    _fetchGifsByCategory(category);
  }

  void _filterGifs() {
    final query = searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      _searchGifs(query);
    } else {
      setState(() {
        filteredGifs =
            gifs; // Reset to the full list when the search is cleared
      });
    }
  }

  void _searchGifs(String query) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedGifs =
          await Helpers.fetchGifs(query); // Search by query text
      setState(() {
        filteredGifs = fetchedGifs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to search GIFs. Please try again later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(chatStateNotifier(widget.uid));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            FaIcon(
              FontAwesomeIcons.gift,
              size: 18,
            ),
            SizedBox(
              width: 6,
            ),
            Text(
              'Choisir Gif'.tr,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Rechercher un GIF...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 50, // Hauteur pour les chips
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildChip('Funny'),
              _buildChip('Animals'),
              _buildChip('Reaction'),
              _buildChip('Dance'),
              _buildChip('Love'),
              _buildChip('Sports'),
              _buildChip('Music'),
              _buildChip('Movies'),
              _buildChip('Meme'),
              _buildChip('Art'),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        isLoading
            ? Center(child: CupertinoActivityIndicator())
            : errorMessage != null
                ? Center(child: Text(errorMessage!))
                : filteredGifs.isEmpty
                    ? Center(
                        child: Text(
                        'No GIFs found'.tr,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ))
                    : Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 2.0,
                            mainAxisSpacing: 2.0,
                            mainAxisExtent: 100,
                          ),
                          itemCount: filteredGifs.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                if (filteredGifs[index] != "") {
                                  if (mounted) {
                                    ref
                                        .read(chatStateNotifier(widget.uid)
                                            .notifier)
                                        .sendMessage(
                                            context,
                                            '',
                                            widget.uid,
                                            notifier.messageReply,
                                            MessageEnum.gif,
                                            [],
                                            filteredGifs[index]);
                                    if (notifier.messageReply.isNotEmpty) {
                                      ref
                                          .read(chatStateNotifier(widget.uid)
                                              .notifier)
                                          .cancelReply();
                                    }
                                  }
                                  Navigator.pop(context);
                                }
                              },
                              child: CachedNetworkImage(
                                key: ValueKey(index),
                                imageUrl: filteredGifs[index],
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  height: 100.0,
                                  width: 100.0,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                    shape: BoxShape.rectangle,
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                ),
                                placeholder: (context, url) => Container(
                                  height: 90.0,
                                  width: 90.0,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    shape: BoxShape.rectangle,
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Center(
                                      child: CupertinoActivityIndicator()),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 90.0,
                                  width: 90.0,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    image: DecorationImage(
                                      image: AssetImage('assets/noimage.png'),
                                      fit: BoxFit.cover,
                                    ),
                                    shape: BoxShape.rectangle,
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ],
    );
  }

  Widget _buildChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: ChoiceChip(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        selectedColor: Colors.grey.shade400,
        selectedShadowColor: Colors.transparent,
        side: BorderSide(style: BorderStyle.none),
        backgroundColor: Colors.grey.shade400,
        label: Text(
          label,
          style: TextStyle(color: Colors.white),
        ),
        selected: selectedCategory == label.toLowerCase(),
        onSelected: (selected) {
          if (selected) {
            searchController.clear();
            _updateCategory(label.toLowerCase());
          }
        },
      ),
    );
  }
}
