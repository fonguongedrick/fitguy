import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class MealPlansScreen extends StatefulWidget {
  const MealPlansScreen({super.key});

  @override
  State<MealPlansScreen> createState() => _MealPlansScreenState();
}

class _MealPlansScreenState extends State<MealPlansScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DefaultCacheManager _cacheManager = DefaultCacheManager();
  final Connectivity _connectivity = Connectivity();
  
  late Stream<QuerySnapshot> _mealsStream;
  late Stream<DocumentSnapshot> _userNutritionStream;
  
  Map<String, dynamic>? _userNutritionData;
  bool _isLoading = true;
  bool _isConnected = true;
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Breakfast', 'Lunch', 'Dinner', 'Snacks'];

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _initializeStreams();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  void _initializeStreams() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _mealsStream = _firestore
        .collection('meals')
        .where('region', isEqualTo: 'cameroon')
        
        .snapshots();

    _userNutritionStream = _firestore
        .collection('user_nutrition')
        .doc('2Js4tC9JZ4rdPKDxe8wh')
        .snapshots();

    _connectivity.onConnectivityChanged.listen((result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    });
  }

  Stream<QuerySnapshot> _getFilteredMealsStream() {
    if (_selectedCategory == 'All') {
      return _firestore
          .collection('meals')
          .where('region', isEqualTo: 'cameroon')
          
          .snapshots();
    } else {
      return _firestore
          .collection('meals')
          .where('region', isEqualTo: 'cameroon')
          .where('category', isEqualTo: _selectedCategory)
          
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Meal Plans',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: OfflineBuilder(
        connectivityBuilder: (context, connectivity, child) {
          final isConnected = connectivity != ConnectivityResult.none;
          if (isConnected != _isConnected) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() => _isConnected = isConnected);
            });
          }
          return child;
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isConnected) _buildOfflineBanner(),
                _buildNutritionCard(),
                const SizedBox(height: 24),
                Text(
                  'Categories',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCategoryTabs(),
                const SizedBox(height: 24),
                Text(
                  'Cameroonian Meals',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildMealsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.amber[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, size: 20, color: Colors.amber),
          const SizedBox(width: 12),
          Text(
            'Offline Mode - Using cached data',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.amber[800],
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _checkConnectivity,
            child: Text(
              'Retry',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userNutritionStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorCard('Failed to load nutrition data');
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildNutritionPlaceholder();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        _userNutritionData = data;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E8B57), Color(0xFF228B22)], // Cameroonian green colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E8B57).withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.food_bank, color: Colors.white, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Nutrition',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildNutritionProgress(
                      'Calories',
                      data['calories']?.toDouble() ?? 0,
                      data['caloriesTarget']?.toDouble() ?? 2200,
                      Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    _buildNutritionProgress(
                      'Protein',
                      data['proteins']?.toDouble() ?? 0,
                      data['proteinTarget']?.toDouble() ?? 150,
                      Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    _buildNutritionProgress(
                      'Carbs',
                      data['fats']?.toDouble() ?? 0,
                      data['carbsTarget']?.toDouble() ?? 300,
                      Colors.amber,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNutritionPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.food_bank, color: Colors.grey, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Nutrition',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                _buildNutritionProgress('Calories', 0, 2200, Colors.grey),
                const SizedBox(height: 8),
                _buildNutritionProgress('Protein', 0, 150, Colors.grey),
                const SizedBox(height: 8),
                _buildNutritionProgress('Carbs', 0, 300, Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionProgress(String label, double current, double target, Color color) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final formattedCurrent = NumberFormat.decimalPattern().format(current);
    final formattedTarget = NumberFormat.decimalPattern().format(target);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            Text(
              '$formattedCurrent / $formattedTarget',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white.withOpacity(0.3),
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2E8B57) : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? const Color(0xFF2E8B57) : Colors.grey.withOpacity(0.3),
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: const Color(0xFF2E8B57).withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Text(
                category,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMealsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getFilteredMealsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget('Failed to load meals');
        }

        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return _buildLoadingList(5);
        }

        final meals = snapshot.data?.docs ?? [];

        if (meals.isEmpty) {
          return _buildNoMealsWidget();
        }

        return Column(
          children: meals.map((doc) {
            final meal = doc.data() as Map<String, dynamic>;
            meal['id'] = doc.id; // Add document ID
            return _buildMealCard(meal);
          }).toList(),
        );
      },
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal) {
    return GestureDetector(
      onTap: () => _navigateToMealDetails(meal['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  colors: [
                    _getCategoryColor(meal['category']).withOpacity(0.1),
                    _getCategoryColor(meal['category']).withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: meal['imageUrl'] != null
                        ? CachedNetworkImage(
                            imageUrl: meal['imageUrl'],
                            placeholder: (context, url) => Icon(
                              _getCategoryIcon(meal['category']),
                              size: 60,
                              color: _getCategoryColor(meal['category']),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              _getCategoryIcon(meal['category']),
                              size: 60,
                              color: _getCategoryColor(meal['category']),
                            ),
                            cacheManager: _cacheManager,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            _getCategoryIcon(meal['category']),
                            size: 60,
                            color: _getCategoryColor(meal['category']),
                          ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(meal['category']),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        meal['category'] ?? 'General',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal['name'] ?? 'Meal',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Traditional Cameroonian cuisine',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildNutritionInfo(
                        Icons.local_fire_department,
                        '${meal['calories'] ?? 0} cal',
                        Colors.orange,
                      ),
                      const SizedBox(width: 20),
                      _buildNutritionInfo(
                        Icons.fitness_center,
                        '${meal['protein'] ?? 0}g protein',
                        Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildNutritionInfo(
                        Icons.grain,
                        '${meal['carbs'] ?? 0}g carbs',
                        Colors.amber,
                      ),
                      const SizedBox(width: 20),
                      _buildNutritionInfo(
                        Icons.water_drop,
                        '${meal['fat'] ?? 0}g fat',
                        Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(meal['ingredients'] as List?)?.length ?? 0} ingredients',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Cameroon',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2E8B57),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionInfo(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.blue;
      case 'dinner':
        return Colors.purple;
      case 'snacks':
        return Colors.green;
      default:
        return const Color(0xFF2E8B57); // Cameroonian green
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'breakfast':
        return Icons.breakfast_dining;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snacks':
        return Icons.local_cafe;
      default:
        return Icons.restaurant;
    }
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingList(int count) {
    return Column(
      children: List.generate(count, (index) {
        return Container(
          height: 220,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2E8B57),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNoMealsWidget() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No meals available',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different category',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _initializeStreams(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E8B57),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Refresh',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToMealDetails(String? mealId) {
    if (mealId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealDetailsScreen(mealId: mealId),
      ),
    );
  }
 
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Search Meals',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            decoration: InputDecoration(
              hintText: 'Search Cameroonian dishes...',
              hintStyle: GoogleFonts.poppins(),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            style: GoogleFonts.poppins(),
            onChanged: (query) {
              // Implement search functionality
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement search
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E8B57),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Search',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

 class MealDetailsScreen extends StatelessWidget {
    final String mealId;

    const MealDetailsScreen({super.key, required this.mealId});

    @override
    Widget build(BuildContext context) {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Meal Details',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: firestore.collection('meals').doc(mealId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading meal details',
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2E8B57)),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Text(
                  'Meal not found',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              );
            }

            final meal = snapshot.data!.data() as Map<String, dynamic>;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedNetworkImage(
                    imageUrl: meal['imageUrl'] ?? '',
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: Color(0xFF2E8B57)),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.error,
                      size: 100,
                      color: Colors.red,
                    ),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    meal['name'] ?? 'Meal Name',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meal['description'] ?? 'No description available',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nutrition Information',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildNutritionRow('Calories', '${meal['calories'] ?? 0} cal'),
                  _buildNutritionRow('Protein', '${meal['protein'] ?? 0}g'),
                  _buildNutritionRow('Carbs', '${meal['carbs'] ?? 0}g'),
                  _buildNutritionRow('Fat', '${meal['fat'] ?? 0}g'),
                  const SizedBox(height: 16),
                  Text(
                    'Ingredients',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._buildIngredientsList(meal['ingredients'] as List?),
                ],
              ),
            );
          },
        ),
      );
    }

    Widget _buildNutritionRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      );
    }

    List<Widget> _buildIngredientsList(List? ingredients) {
      if (ingredients == null || ingredients.isEmpty) {
        return [
          Text(
            'No ingredients available',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ];
      }

      return ingredients.map((ingredient) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            '- $ingredient',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        );
      }).toList();
    }
  }