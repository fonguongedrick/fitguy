import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';



class Meal {
  final String id;
  final String name;
  final String category;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final List<String> ingredients;
  final List<String> instructions;
  final String? imageUrl;
  final String region;

  Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
    required this.instructions,
    this.imageUrl,
    this.region = 'cameroon',
  });

  factory Meal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Meal(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? 'Uncategorized',
      calories: data['calories']?.toInt() ?? 0,
      protein: data['protein']?.toInt() ?? 0,
      carbs: data['carbs']?.toInt() ?? 0,
      fat: data['fat']?.toInt() ?? 0,
      ingredients: List<String>.from(data['ingredients'] ?? []),
      instructions: List<String>.from(data['instructions'] ?? []),
      imageUrl: data['imageUrl'],
      region: data['region'] ?? 'cameroon',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'ingredients': ingredients,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'region': region,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Meal copyWith({
    String? id,
    String? name,
    String? category,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    List<String>? ingredients,
    List<String>? instructions,
    String? imageUrl,
    String? region,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      region: region ?? this.region,
    );
  }
}

class MealService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get all meals
  Stream<List<Meal>> getMealsStream() {
    return _firestore.collection('meals').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Meal.fromFirestore(doc)).toList();
    });
  }

  // Get meals by category
  Stream<List<Meal>> getMealsByCategory(String category) {
    return _firestore
        .collection('meals')
        .where('category', isEqualTo: category)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Meal.fromFirestore(doc)).toList();
    });
  }

  // Get popular meals
  Stream<List<Meal>> getPopularMeals() {
    return _firestore
        .collection('meals')
        .orderBy('popularity', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Meal.fromFirestore(doc)).toList();
    });
  }

  // Add a new meal
  Future<void> addMeal(Meal meal) async {
    await _firestore.collection('meals').doc(meal.id).set(meal.toFirestore());
  }

  // Update a meal
  Future<void> updateMeal(Meal meal) async {
    await _firestore.collection('meals').doc(meal.id).update(meal.toFirestore());
  }

  // Delete a meal
  Future<void> deleteMeal(String mealId) async {
    await _firestore.collection('meals').doc(mealId).delete();
  }

  // Upload image to Firebase Storage
  Future<String?> uploadImage(File image, String mealId) async {
    try {
      final ref = _storage.ref().child('meal_images/$mealId.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }
}

class MealManagementScreen extends StatefulWidget {
  const MealManagementScreen({super.key});

  @override
  State<MealManagementScreen> createState() => _MealManagementScreenState();
}

class _MealManagementScreenState extends State<MealManagementScreen> {
  final MealService _mealService = MealService();
  final TextEditingController _searchController = TextEditingController();
  String _filterCategory = 'All';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMealDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search meals...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _filterCategory,
                  items: ['All', 'Breakfast', 'Lunch', 'Dinner', 'Snacks']
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _filterCategory = value!),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Meal>>(
              stream: _mealService.getMealsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final meals = snapshot.data ?? [];
                final filteredMeals = meals.where((meal) {
                  final matchesSearch = meal.name
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase());
                  final matchesCategory = _filterCategory == 'All' ||
                      meal.category == _filterCategory;
                  return matchesSearch && matchesCategory;
                }).toList();

                if (filteredMeals.isEmpty) {
                  return const Center(child: Text('No meals found'));
                }

                return ListView.builder(
                  itemCount: filteredMeals.length,
                  itemBuilder: (context, index) {
                    final meal = filteredMeals[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: meal.imageUrl != null 
                            ? Image.network(
                                meal.imageUrl!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => 
                                    const Icon(Icons.restaurant, size: 36),
                              )
                            : const Icon(Icons.restaurant, size: 36),
                        title: Text(meal.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(meal.category),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildNutritionChip('${meal.calories} cal'),
                                  _buildNutritionChip('${meal.protein}g protein'),
                                  _buildNutritionChip('${meal.carbs}g carbs'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditMealDialog(meal),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteConfirmation(meal.id, meal.name),
                            ),
                          ],
                        ),
                        onTap: () => _showMealDetails(meal),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionChip(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  void _showAddMealDialog() {
    showDialog(
      context: context,
      builder: (context) => MealFormDialog(
        onSave: (meal, image) async {
          try {
            if (image != null) {
              final imageUrl = await _mealService.uploadImage(image, meal.id);
              if (imageUrl != null) {
                meal = meal.copyWith(imageUrl: imageUrl);
              }
            }
            await _mealService.addMeal(meal);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${meal.name} added successfully')),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to add meal: $e')),
            );
          }
        },
      ),
    );
  }

  void _showEditMealDialog(Meal meal) {
    showDialog(
      context: context,
      builder: (context) => MealFormDialog(
        meal: meal,
        onSave: (updatedMeal, image) async {
          try {
            if (image != null) {
              final imageUrl = await _mealService.uploadImage(image, updatedMeal.id);
              if (imageUrl != null) {
                updatedMeal = updatedMeal.copyWith(imageUrl: imageUrl);
              }
            }
            await _mealService.updateMeal(updatedMeal);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${updatedMeal.name} updated successfully')),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update meal: $e')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(String mealId, String mealName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: Text('Are you sure you want to delete $mealName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _mealService.deleteMeal(mealId);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$mealName deleted successfully')),
                );
                Navigator.pop(context);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete meal: $e')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showMealDetails(Meal meal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(meal.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (meal.imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      meal.imageUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: const Icon(Icons.fastfood),
                      ),
                    ),
                  ),
                ),
              Text('Category: ${meal.category}'),
              const SizedBox(height: 8),
              Text('Calories: ${meal.calories}'),
              Text('Protein: ${meal.protein}g'),
              Text('Carbs: ${meal.carbs}g'),
              Text('Fat: ${meal.fat}g'),
              const SizedBox(height: 16),
              const Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...meal.ingredients.map((ingredient) => Text('- $ingredient')).toList(),
              const SizedBox(height: 16),
              const Text('Instructions:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...meal.instructions
                  .asMap()
                  .entries
                  .map((entry) => Text('${entry.key + 1}. ${entry.value}'))
                  .toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class MealFormDialog extends StatefulWidget {
  final Meal? meal;
  final Function(Meal, File?) onSave;

  const MealFormDialog({
    super.key,
    this.meal,
    required this.onSave,
  });

  @override
  State<MealFormDialog> createState() => _MealFormDialogState();
}

class _MealFormDialogState extends State<MealFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _category;
  late int _calories;
  late int _protein;
  late int _carbs;
  late int _fat;
  late List<String> _ingredients;
  late List<String> _instructions;
  late String _region;
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _instructionController = TextEditingController();
  File? _imageFile;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _name = widget.meal?.name ?? '';
    _category = widget.meal?.category ?? 'Breakfast';
    _calories = widget.meal?.calories ?? 0;
    _protein = widget.meal?.protein ?? 0;
    _carbs = widget.meal?.carbs ?? 0;
    _fat = widget.meal?.fat ?? 0;
    _ingredients = widget.meal?.ingredients ?? [];
    _instructions = widget.meal?.instructions ?? [];
    _region = widget.meal?.region ?? 'cameroon';
    _imageUrl = widget.meal?.imageUrl;
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    _instructionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.meal == null ? 'Add Meal' : 'Edit Meal'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image upload section
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : _imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(child: Icon(Icons.add_a_photo)),
                              ),
                            )
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, size: 40),
                                  Text('Tap to add image'),
                                ],
                              ),
                            ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Meal Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a name' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                items: ['Breakfast', 'Lunch', 'Dinner', 'Snacks']
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _calories.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Calories'),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Please enter calories';
                        if (int.tryParse(value!) == null) return 'Must be a number';
                        return null;
                      },
                      onSaved: (value) => _calories = int.parse(value!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _protein.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Protein (g)'),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Please enter protein';
                        if (int.tryParse(value!) == null) return 'Must be a number';
                        return null;
                      },
                      onSaved: (value) => _protein = int.parse(value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _carbs.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Carbs (g)'),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Please enter carbs';
                        if (int.tryParse(value!) == null) return 'Must be a number';
                        return null;
                      },
                      onSaved: (value) => _carbs = int.parse(value!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _fat.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Fat (g)'),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Please enter fat';
                        if (int.tryParse(value!) == null) return 'Must be a number';
                        return null;
                      },
                      onSaved: (value) => _fat = int.parse(value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
              Column(
                children: _ingredients
                    .map((ingredient) => ListTile(
                          title: Text(ingredient),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () =>
                                setState(() => _ingredients.remove(ingredient)),
                          ),
                        ))
                    .toList(),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ingredientController,
                      decoration: const InputDecoration(labelText: 'Add Ingredient'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: () {
                      if (_ingredientController.text.isNotEmpty) {
                        setState(() {
                          _ingredients.add(_ingredientController.text);
                          _ingredientController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Instructions', style: TextStyle(fontWeight: FontWeight.bold)),
              Column(
                children: _instructions
                    .map((instruction) => ListTile(
                          title: Text(instruction),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () =>
                                setState(() => _instructions.remove(instruction)),
                          ),
                        ))
                    .toList(),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _instructionController,
                      decoration: const InputDecoration(labelText: 'Add Instruction'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: () {
                      if (_instructionController.text.isNotEmpty) {
                        setState(() {
                          _instructions.add(_instructionController.text);
                          _instructionController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final meal = Meal(
                id: widget.meal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: _name,
                category: _category,
                calories: _calories,
                protein: _protein,
                carbs: _carbs,
                fat: _fat,
                ingredients: _ingredients,
                instructions: _instructions,
                imageUrl: _imageUrl,
                region: _region,
              );
              widget.onSave(meal, _imageFile);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// UserMealScreen remains the same as in your original code
class UserMealScreen extends StatefulWidget {
  const UserMealScreen({super.key});

  @override
  State<UserMealScreen> createState() => _UserMealScreenState();
}

class _UserMealScreenState extends State<UserMealScreen> {
  final MealService _mealService = MealService();
  String _selectedCategory = 'Breakfast';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meal Plans'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Breakfast'),
              Tab(text: 'Lunch'),
              Tab(text: 'Dinner'),
              Tab(text: 'Snacks'),
            ],
            onTap: (index) {
              setState(() {
                _selectedCategory = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'][index];
              });
            },
          ),
        ),
        body: TabBarView(
          children: [
            _buildMealCategoryView('Breakfast'),
            _buildMealCategoryView('Lunch'),
            _buildMealCategoryView('Dinner'),
            _buildMealCategoryView('Snacks'),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCategoryView(String category) {
    return StreamBuilder<List<Meal>>(
      stream: _mealService.getMealsByCategory(category),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final meals = snapshot.data ?? [];

        if (meals.isEmpty) {
          return const Center(child: Text('No meals available in this category'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: meals.length,
          itemBuilder: (context, index) {
            final meal = meals[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () => _showMealDetails(meal),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (meal.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            meal.imageUrl!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 150,
                              color: Colors.grey[200],
                              child: const Icon(Icons.fastfood),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        meal.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        meal.category,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildNutritionChip('${meal.calories} cal'),
                          const SizedBox(width: 8),
                          _buildNutritionChip('${meal.protein}g protein'),
                          const SizedBox(width: 8),
                          _buildNutritionChip('${meal.carbs}g carbs'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNutritionChip(String text) {
    return Chip(
      label: Text(text),
      backgroundColor: Colors.blue[50],
      labelStyle: const TextStyle(fontSize: 12),
    );
  }

  void _showMealDetails(Meal meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (meal.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    meal.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.fastfood, size: 50)),
                    ),
                  )),
              const SizedBox(height: 16),
              Text(
                meal.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Category: ${meal.category}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNutritionInfo('Calories', '${meal.calories}'),
                  _buildNutritionInfo('Protein', '${meal.protein}g'),
                  _buildNutritionInfo('Carbs', '${meal.carbs}g'),
                  _buildNutritionInfo('Fat', '${meal.fat}g'),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: meal.ingredients
                    .map((ingredient) => Text('- $ingredient'))
                    .toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Instructions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: meal.instructions
                    .asMap()
                    .entries
                    .map((entry) => Text('${entry.key + 1}. ${entry.value}'))
                    .toList(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}