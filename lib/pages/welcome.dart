import 'package:bunny/widgets/backdrop.dart';
import 'package:flutter/material.dart';
import 'package:sharebox/widgets/image.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Backdrop(
      child: Container(
        width: 300,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3), // 半透明背景色
          // borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2), // 边框颜色
          ),
        ),
        child: Center(
          child: const Text(
            'Blurred Card',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    // ),
  }

  Widget buildCard(String title, List<Widget> children) {
    return Container(
      width: 300,
      height: 450,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget buildListTile(String imageUrl, String text) {
    return ListTile(
      leading: Img.image("logo.png", size: const Size(40, 40)),
      title: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget buildPdfTile(String imageUrl, String title, String description) {
    return Column(
      children: [
        ListTile(
          leading: Img.image("logo.png", size: const Size(40, 40)),
          title: Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget buildImageGrid(List<String> imageUrls) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: imageUrls.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        return Img.image("logo.png", size: const Size(10, 10));
      },
    );
  }
}
