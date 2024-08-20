import 'package:flutter/material.dart';

import '../bruiserpage.dart';


class ListCard extends StatefulWidget {
  final String title;
  final String date;
  final String imageUri;

  const ListCard({
    super.key,
    required this.title,
    required this.date,
    required this.imageUri
  });

  @override
  State<ListCard> createState() => _ListCardState();
}

class _ListCardState extends State<ListCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: IntrinsicHeight(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFF59E0B),
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
                widget.imageUri.isNotEmpty ?
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

                        child: Image.network(
                          widget.imageUri,
                          fit: BoxFit.fill,
                        )
                    )
                ) : const SizedBox(
                  width: 93,
                  height: 98,
                ),
                IntrinsicHeight(
                  child: Container(
                    margin: const EdgeInsets.only(right: 39),
                    width: 108,
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
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: Image.asset(
                                          'assets/icons/weightorange.png',
                                          fit: BoxFit.fill,
                                        )
                                    ),
                                    const Text(
                                      'Weight Update',
                                      style: TextStyle(
                                        color: Color(0xFF737373),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ]
                              ),
                            ),

                          ),
                          IntrinsicHeight(
                            child: SizedBox(
                              width: double.infinity,
                              child: Row(
                                  children: [
                                    Container(
                                        margin: const EdgeInsets.only(right: 4),
                                        width: 24,
                                        height: 24,
                                        child: Image.asset(
                                          'assets/icons/calorange.png',
                                          fit: BoxFit.fill,
                                        )
                                    ),
                                    const Expanded(
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          'Today',
                                          style: TextStyle(
                                            color: Color(0xFFF59E0B),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]
                              ),
                            ),
                          ),
                        ]
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
                        fit: BoxFit.cover
                    ),
                  ),

                ),
              ]
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Bruiserpage()),
        );
      },

    );
  }

}
