import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class ReactionEmoji extends ConsumerStatefulWidget {
  final List<String> emojiAssets; // Liste de chemins d'assets des emojis
  final Function(String) onReactionSelected;
  final Function(String) onPress;

  const ReactionEmoji(
      {super.key, required this.emojiAssets,
      required this.onReactionSelected,
      required this.onPress});

  @override
  _ReactionEmojiState createState() => _ReactionEmojiState();
}

class _ReactionEmojiState extends ConsumerState<ReactionEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isVisible = false;
  final TextEditingController _repondreStoryController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  void _toggleReactions() {
    setState(() {
      _isVisible = !_isVisible;
      if (_isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isVisible)
          Positioned(
            bottom: 70, // Ajustez cette valeur selon l'espace requis
            left: 7,
            right: 7,
            child: FadeTransition(
              opacity: _animation,
              child: ScaleTransition(
                scale: _animation,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.emojiAssets.map((emojiAsset) {
                        return GestureDetector(
                          onTap: () {
                            widget.onReactionSelected(emojiAsset);
                            _toggleReactions();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              emojiAsset,
                              width: 40, // Ajustez la taille selon vos besoins
                              height: 40,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 0, // Position du bouton pour ouvrir la liste des réactions
          left: 0,
          child: Container(
            width: MediaQuery.of(context).size.width - 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              color: Colors.black.withOpacity(0.3),
            ),
            child: TextField(
              controller: _repondreStoryController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                suffixIcon: Container(
                  child: IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.solidPaperPlane,
                        size: 24,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        widget
                            .onPress(_repondreStoryController.text.toString());
                        _repondreStoryController.clear();
                      }),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 2.0,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                contentPadding: EdgeInsets.all(10),
                hintText: 'Ecrivez votre commentaire'.tr,
                hintStyle: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0, // Position du bouton pour ouvrir la liste des réactions
          right: 0,
          child: RawMaterialButton(
            onPressed: _toggleReactions,
            shape: CircleBorder(),
            fillColor: Colors.transparent, // Supprimer l'arrière-plan
            elevation: 0, // Supprimer l'ombre
            child: Image.asset(
              'assets/1.gif', // Remplacez par le chemin de votre image d'emoji
              width: 40, // Ajustez la taille de l'emoji selon vos besoins
              height: 40,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
