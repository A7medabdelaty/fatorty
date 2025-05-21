import 'package:flutter/material.dart';

import '../../constants/widgets.dart';

class CommunityScreen extends StatelessWidget {
  // قائمة للمشاركات (في المستقبل هنجيبها من قاعدة بيانات أو API)
  final List<String> posts = [
    'أحمد علي: أهلاً بالجميع،عندي مشكلة يا أستاذ عماد فيه عميل عمل حادثة بالعجلة',
    'مريم سعيد: أنا حابة أضيف اقتراح في التطبيق',
    'محمد عبد الله: فيه مشكلة بتقابلني دايما لما باجي ادخل التطبيق'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:CustomAppBar(
        title: ('المحادثة مع الأدمن مباشرة'),
      ),
      body: Column(
        children: [
          // عرض المشاركات
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(posts[index]),
                    subtitle: Text('منذ 3 دقائق'),
                  ),
                );
              },
            ),
          ),
          // زر إضافة مشاركة جديدة
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // هنا هنضيف شاشة لكتابة المشاركة
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AddPostDialog();
                  },
                );
              },
              child: Text('أضف مشاركة جديدة'),
            ),
          ),
        ],
      ),
    );
  }
}

class AddPostDialog extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('أضف مشاركة'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(hintText: 'اكتب مشاركتك هنا...'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('إلغاء'),
        ),
        TextButton(
          onPressed: () {
            // هنا هنضيف المشاركة الجديدة للقائمة أو قاعدة البيانات
            String newPost = _controller.text;
            if (newPost.isNotEmpty) {
              // إضافة المشاركة (في المستقبل هنربطها بقاعدة بيانات)
              print('تم إضافة مشاركة جديدة: $newPost');
              Navigator.pop(context);
            }
          },
          child: Text('إرسال'),
        ),
      ],
    );
  }
}
