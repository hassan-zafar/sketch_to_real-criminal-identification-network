import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sketch_to_real/tools/loading.dart';

Widget cachedNetworkImage(String mediaUrl) {
  return Container(
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
    child: CachedNetworkImage(
      errorWidget: (context, url, error) => const Icon(Icons.error),
      imageUrl: mediaUrl != null ? mediaUrl : "",
      fit: BoxFit.cover,
      placeholder: (context, url) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: LoadingIndicator(),
      ),
    ),
  );
}
