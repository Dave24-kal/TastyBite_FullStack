import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/food_provider.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';


  @override
  void initState(){
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_){
      if (!mounted) return;

      context.read<FoodProvider>().fetchFoods();
    });
  }
  @override
void dispose() {
  _searchController.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 24),

              _buildSearchBar(),

              const SizedBox(height: 24),

              _buildPromoBanner(),

              const SizedBox(height: 28),

              _buildSectionTitle('Categories'),

              const SizedBox(height: 16),

              _buildCategories(),

              const SizedBox(height: 28),

              _buildSectionTitle('Popular Meals'),

              const SizedBox(height: 16),

              _buildPopularMeals(),
            ],
          ),
        ),
      ),

        bottomNavigationBar: _buildBottomNavigation(context),    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, Food Lover!',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'What would you like to eat?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
          ),
          child: Icon(
            Icons.notifications_none_rounded,
            color: AppColors.textPrimary,
            size: 26,
          ),
        ),
      ],
    );
  }

   
  Widget _buildSearchBar() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    height: 54,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    ),
    child: Row(
      children: [
        Icon(
          Icons.search_rounded,
          color: AppColors.textSecondary,
          size: 25,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.trim().toLowerCase();
              });
            },
            decoration: const InputDecoration(
              hintText: 'Search meals or restaurants',
              border: InputBorder.none,
              isCollapsed: true,
            ),
          ),
        ),
        if (_searchQuery.isNotEmpty)
          GestureDetector(
            onTap: () {
              _searchController.clear();

              setState(() {
                _searchQuery = '';
              });
            },
            child: const Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
      ],
    ),
  );
}

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF6B00),
            Color(0xFFFF8A3D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SPECIAL OFFER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Delicious food,\nbetter prices!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Order Now',
                    style: TextStyle(
                      color: Color(0xFFFF6B00),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          const Icon(
            Icons.restaurant_rounded,
            size: 76,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        TextButton(
          onPressed: () {
          },
          child: const Text(
            'See all',
            style: TextStyle(
              color: Color(0xFFFF6B00),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'name': 'Burgers', 'icon': Icons.lunch_dining_rounded},
      {'name': 'Pizza', 'icon': Icons.local_pizza_rounded},
      {'name': 'Chicken', 'icon': Icons.set_meal_rounded},
      {'name': 'Ethiopian', 'icon': Icons.rice_bowl_rounded},
      {'name': 'Drinks', 'icon': Icons.local_cafe_rounded},
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 16);
        },
        itemBuilder: (context, index) {
          final category = categories[index];

          return GestureDetector(
  onTap: () {
    setState(() {
      _selectedCategory = category['name'] as String;
    });
  },
  child: Column(
    children: [
      Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: _selectedCategory == category['name']
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _selectedCategory == category['name']
                ? AppColors.primary
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Icon(
          category['icon'] as IconData,
          color: AppColors.primary,
          size: 30,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        category['name'] as String,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textPrimary,
          fontWeight: _selectedCategory == category['name']
              ? FontWeight.bold
              : FontWeight.w500,
        ),
      ),
    ],
  ),
);
        },
      ),
    );
  }

  Widget _buildPopularMeals() {
  final foodProvider = context.watch<FoodProvider>();

  if (foodProvider.isLoading && foodProvider.foods.isEmpty) {
    return const Padding(
      padding: EdgeInsets.all(30),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }

  if (foodProvider.errorMessage != null &&
      foodProvider.foods.isEmpty) {
    return Center(
      child: Column(
        children: [
          const Text('Unable to load meals.'),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              context.read<FoodProvider>().fetchFoods();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  if (foodProvider.foods.isEmpty) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text('No foods available right now.'),
      ),
    );
  }

  final searchFilteredFoods = foodProvider.foods.where((meal) {
  final name = meal['name']?.toString().toLowerCase() ?? '';
  final description =
      meal['description']?.toString().toLowerCase() ?? '';

  return name.contains(_searchQuery) ||
      description.contains(_searchQuery);
}).toList();

final meals = searchFilteredFoods.where((meal) {
  if (_selectedCategory == 'All') {
    return true;
  }

  final category = meal['category']?.toString().toLowerCase() ?? '';
  final selectedCategory = _selectedCategory.toLowerCase();

  if (selectedCategory == 'burgers') {
    return category == 'burger' || category == 'burgers';
  }

  if (selectedCategory == 'chicken') {
    return category == 'chicken';
  }

  return category == selectedCategory;
}).toList();

      if (meals.isEmpty) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(
            Icons.restaurant_menu_rounded,
            size: 48,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
  _searchQuery.isNotEmpty
      ? 'No meals found for "$_searchQuery".'
      : 'No meals available in $_selectedCategory yet.',
  textAlign: TextAlign.center,
  style: const TextStyle(
    fontSize: 15,
    color: AppColors.textSecondary,
  ),
),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {

              _searchController.clear();

              setState(() {
                _selectedCategory = 'All';
                _searchQuery = '';
              });
            },
            child: const Text('Show All Meals'),
          ),
        ],
      ),
    ),
  );
}

  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: meals.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      mainAxisExtent: 220,
    ),
    itemBuilder: (context, index) {
      final meal = meals[index];

      final name = meal['name']?.toString() ?? 'Unnamed food';
      final price = meal['price'];

      final priceText = price == null
          ? 'Price unavailable'
          : '$price ETB';

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
  height: 105,
  width: double.infinity,
  decoration: BoxDecoration(
    color: AppColors.primary.withValues(alpha: 0.10),
    borderRadius: BorderRadius.circular(12),
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: (meal['image_url'] != null &&
            meal['image_url'].toString().isNotEmpty)
        ? Image.network(
            meal['image_url'].toString(),
            width: double.infinity,
            height: 105,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }

              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.restaurant_rounded,
                size: 48,
                color: AppColors.primary,
              );
            },
          )
        : const Icon(
            Icons.restaurant_rounded,
            size: 48,
            color: AppColors.primary,
          ),
  ),
),
              const SizedBox(height: 10),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                priceText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
  Widget _buildBottomNavigation(BuildContext context) {
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    currentIndex: 0,
    backgroundColor: Colors.white,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textSecondary,
    selectedFontSize: 12,
    unselectedFontSize: 12,
    onTap: (index) {
      if (index == 4) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
        );
      }
    },
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.explore_outlined),
        label: 'Explore',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.shopping_bag_outlined),
        label: 'Cart',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.favorite_border_rounded),
        label: 'Favorites',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline_rounded),
        label: 'Profile',
      ),
    ],
  );
}
}
