import 'package:flutter/material.dart';

import 'models/article.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(
                Icons.article,
                size: 90,
                color: Colors.green,
              ),
            ),
          ),

          const SizedBox(height: 24),

          Chip(
            label: Text(article.category),
            backgroundColor: Colors.green.shade100,
          ),

          const SizedBox(height: 20),

          Text(
            article.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            article.content,
            style: const TextStyle(
              fontSize: 17,
              height: 1.7,
            ),
          ),

          const SizedBox(height: 30),

          Card(
            color: Colors.green.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: Colors.orange,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Amalkan gaya hidup sihat secara konsisten. Perubahan kecil yang dilakukan setiap hari akan memberi manfaat besar kepada kesihatan dalam jangka masa panjang.",
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}