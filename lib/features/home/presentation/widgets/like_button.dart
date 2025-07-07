import 'package:flutter/material.dart';

class LikeButton extends StatefulWidget {
  final int likes;

  const LikeButton({super.key, required this.likes});

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool isLiked = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    likeCount = widget.likes;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.grey,
          ),
          onPressed: () {
            setState(() {
              isLiked = !isLiked;
              likeCount += isLiked ? 1 : -1;
            });
          },
        ),
        Text(
          likeCount.toString(),
          style: TextStyle(
            color: isLiked ? Colors.red : Colors.grey,
          ),
        ),
      ],
    );
  }
}