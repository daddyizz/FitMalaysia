import 'package:flutter/material.dart';

import 'article_detail_screen.dart';
import 'data/article_data.dart';
import 'models/article.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  List<Article> filteredArticles = articleData;

  void searchArticle(String value) {
    setState(() {
      filteredArticles = articleData.where((article) {
        return article.title
            .toLowerCase()
            .contains(value.toLowerCase());
      }).toList();
    });
  }

  Color categoryColor(String category) {
    switch (category) {
      case "Hidrasi":
        return Colors.blue;
      case "Workout":
        return Colors.orange;
      case "Pemakanan":
        return Colors.green;
      case "Kesihatan":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Artikel Kesihatan"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: searchArticle,
              decoration: const InputDecoration(
                hintText: "Cari artikel...",
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredArticles.length,
              itemBuilder: (context, index) {
                final article = filteredArticles[index];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),

                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(
                        Icons.article,
                        color: Colors.green,
                      ),
                    ),

                    title: Text(
                      article.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Chip(
                            label: Text(article.category),
                            backgroundColor:
                            categoryColor(article.category)
                                .withOpacity(0.15),
                            labelStyle: TextStyle(
                              color: categoryColor(article.category),
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Chip(
                            avatar: const Icon(
                              Icons.schedule,
                              size: 18,
                            ),
                            label: Text(
                              "${article.readingTime} min",
                            ),
                          ),

                          if (article.popular)
                            const Chip(
                              avatar: Icon(
                                Icons.local_fire_department,
                                color: Colors.red,
                                size: 18,
                              ),
                              label: Text("Popular"),
                            ),
                        ],
                      ),
                    ),

                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ArticleDetailScreen(article: article),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}