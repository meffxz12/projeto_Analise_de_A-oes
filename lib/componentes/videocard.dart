import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoCard extends StatelessWidget {
  final String title;
  final String videoId;
  final String duration;

  const VideoCard({
    super.key,
    required this.title,
    required this.videoId,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnail = "https://img.youtube.com/vi/$videoId/0.jpg";

    return GestureDetector(
      onTap: () async {
        final url =
            Uri.parse("https://www.youtube.com/watch?v=$videoId");

        if (await canLaunchUrl(url)) {
          await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                  child: Image.network(
                    thumbnail,
                    width: 140,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 140,
                        height: 80,
                        color: Colors.grey,
                        child: const Icon(
                          Icons.play_circle_fill,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}