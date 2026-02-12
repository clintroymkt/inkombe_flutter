
import 'package:intl/intl.dart';

import '../services/cattle_record.dart';

class Utilities{

  static String formatLongDateTime(String date) {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate = DateFormat('EEEE, MMMM d, yyyy - hh:mm a').format(dateTime);
    return formattedDate;
  }

  static String formatShortDateTime(String date) {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate = DateFormat('d MMMM, yyyy - hh:mm a').format(dateTime);
    return formattedDate;
  }

  // Helper method to get the first available image
  String? getFirstImagePath(CattleRecord doc) {
    // First try local image paths
    if (doc.localImagePaths != null && doc.localImagePaths!.isNotEmpty) {
      return doc.localImagePaths![0];
    }
    // Then try image URLs
    if (doc.imageUrls != null && doc.imageUrls!.isNotEmpty) {
      return doc.imageUrls![0];
    }
    // Return null if no images available
    return null;
  }


}