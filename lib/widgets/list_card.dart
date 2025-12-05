import 'dart:io';

import 'package:flutter/material.dart';

import '../pages/cow_profile_page.dart';
import '../utils/Utilities.dart';

class ListCard extends StatefulWidget {
  final String docId;
  final String title;
  final String date;
  final String? imageUri;
  final String? imagePath;

  const ListCard({
    super.key,
    required this.title,
    required this.date,
    required this.docId,
    this.imageUri,
    this.imagePath,
  });

  @override
  State<ListCard> createState() => _ListCardState();
}

class _ListCardState extends State<ListCard> {
  @override
  void initState() {
    chechDate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: IntrinsicHeight(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0x333E9249),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
            color: const Color(0xFFFFFFFF),
          ),
          padding: const EdgeInsets.all(2),
          margin: const EdgeInsets.only(bottom: 8),
          width: double.infinity,
          child: Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(2),
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                    bottomLeft: Radius.circular(2),
                  ),
                ),
                margin: const EdgeInsets.only(right: 14),
                width: 93,
                height: 98,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(2),
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                    bottomLeft: Radius.circular(2),
                  ),
                  child: _buildImage(),
                ),
              ),
              IntrinsicHeight(
                child: Container(
                  margin: const EdgeInsets.only(right: 39),
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 12, left: 2),
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: Color(0xFF262626),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IntrinsicHeight(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 9),
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: Image.asset(
                                  'assets/icons/weightorange.png',
                                  fit: BoxFit.fill,
                                ),
                              ),
                              const Text(
                                'New Cow',
                                style: TextStyle(
                                  color: Color(0xFF737373),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Date added part
                      IntrinsicHeight(
                        child: SizedBox(
                          width: double.infinity,
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 4),
                                width: 10,
                                height: 24,
                                child: Image.asset(
                                  'assets/icons/calorange.png',
                                  fit: BoxFit.fill,
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    widget.date != '' ?  Utilities.formatShortDateTime(widget.date): 'NA',

                                    style: const TextStyle(
                                      color: Color(0x333E9249),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 18, right: 18),
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/icons/weightorange.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CowProfilePage(docId: widget.docId)),
        );
      },
    );
  }

  Widget _buildImage() {
    // Priority: Use local image if available and file exists
    if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
      final file = File(widget.imagePath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildNetworkImageOrPlaceholder(),
        );
      }
    }

    // Fallback to network image
    return _buildNetworkImageOrPlaceholder();
  }


  Widget _buildNetworkImageOrPlaceholder() {
    if (widget.imageUri != null && widget.imageUri!.isNotEmpty) {
      return Image.network(
        widget.imageUri!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.pets,
        color: Colors.grey,
        size: 40,
      ),
    );
  }

  void chechDate() {
    // print(widget.date);
    // print('Image URI: ${widget.imageUri}');
    // print('Image Path: ${widget.imagePath}');
  }
}