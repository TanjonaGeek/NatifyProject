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
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchGifs();
  }

  void _fetchGifs() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final cachedGifs = GifCache.get(selectedCategory);
      if (cachedGifs != null) {
        setState(() {
          gifs = cachedGifs;
          isLoading = false;
        });
      } else {
        final fetchedGifs = await Helpers.fetchGifs(selectedCategory);
        setState(() {
          gifs = fetchedGifs;
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
    _fetchGifs();
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
              // Ajoute d'autres catégories ici
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
                : gifs.isEmpty
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
                          itemCount: gifs.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                if (gifs[index] != "") {
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
                                            gifs[index]);
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
                                imageUrl: gifs[index],
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
            _updateCategory(label.toLowerCase());
          }
        },
      ),
    );
  }
}
