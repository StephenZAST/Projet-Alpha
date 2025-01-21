import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controllers/article_controller.dart';
import '../../../models/article.dart';
import 'package:dotted_border/dotted_border.dart';
import 'category_dropdown.dart';

class ArticleFormScreen extends StatelessWidget {
  final Article? article;
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  ArticleFormScreen({this.article}) {
    if (article != null) {
      nameController.text = article!.name;
      descriptionController.text = article!.description;
      priceController.text = article!.price.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article == null ? 'New Article' : 'Edit Article'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              DottedBorder(
                borderType: BorderType.RRect,
                radius: Radius.circular(12),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload, size: 40),
                      SizedBox(height: defaultPadding),
                      Text('Click to upload image'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: defaultPadding),
              CategoryDropdown(),
              SizedBox(height: defaultPadding),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Name is required' : null,
              ),
              SizedBox(height: defaultPadding),
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: defaultPadding),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Price is required' : null,
              ),
              SizedBox(height: defaultPadding * 2),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Save Article'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final articleData = {
        'id': article?.id ?? '',
        'name': nameController.text,
        'description': descriptionController.text,
        'price': double.parse(priceController.text),
        'categoryId': Get.find<ArticleController>().selectedCategory.value,
      };

      Get.find<ArticleController>().createArticle(articleData);
    }
  }
}
