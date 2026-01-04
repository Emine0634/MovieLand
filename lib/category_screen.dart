// lib/category_screen.dart
import 'package:flutter/material.dart';
import 'constants.dart';
import 'home_screen.dart';

class CategoryScreen extends StatefulWidget {
  final Map<String, List<Movie>> userLists;

  const CategoryScreen({
    super.key,
    required this.userLists,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final Set<String> selectedCategories = {};

  final List<CategoryItem> categories = [
    CategoryItem(
      name: 'Action',
      icon: Icons.flash_on,
      color: Colors.orange,
    ),
    CategoryItem(
      name: 'Drama',
      icon: Icons.theater_comedy,
      color: Colors.purple,
    ),
    CategoryItem(
      name: 'Comedy',
      icon: Icons.mood,
      color: Colors.yellow,
    ),
    CategoryItem(
      name: 'Horror',
      icon: Icons.nightlight,
      color: Colors.red,
    ),
    CategoryItem(
      name: 'Sci-Fi',
      icon: Icons.rocket_launch,
      color: Colors.blue,
    ),
    CategoryItem(
      name: 'Fantasy',
      icon: Icons.auto_awesome,
      color: Colors.pink,
    ),
    CategoryItem(
      name: 'Romance',
      icon: Icons.favorite,
      color: Colors.redAccent,
    ),
    CategoryItem(
      name: 'Thriller',
      icon: Icons.warning,
      color: Colors.deepOrange,
    ),
    CategoryItem(
      name: 'Animation',
      icon: Icons.emoji_emotions,
      color: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.mainBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Categories',
          style: TextStyle(
            color: AppColors.titleColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Seçim sayacı
          if (selectedCategories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.logInButtonColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.logInButtonColor.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.logInButtonColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${selectedCategories.length} ${selectedCategories.length == 1 ? "category" : "categories"} selected',
                      style: TextStyle(
                        color: AppColors.logInButtonColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Kategori butonları
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: categories.map((category) {
                  final isSelected = selectedCategories.contains(category.name);
                  return _CategoryButton(
                    category: category,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedCategories.remove(category.name);
                        } else {
                          selectedCategories.add(category.name);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryItem {
  final String name;
  final IconData icon;
  final Color color;

  CategoryItem({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class _CategoryButton extends StatefulWidget {
  final CategoryItem category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<_CategoryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.category.color
                : AppColors.textFieldFillColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected
                  ? widget.category.color
                  : widget.category.color.withOpacity(0.3),
              width: widget.isSelected ? 2.5 : 1.5,
            ),
            boxShadow: widget.isSelected
                ? [
              BoxShadow(
                color: widget.category.color.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Ana içerik
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.category.icon,
                    color: widget.isSelected
                        ? Colors.white
                        : widget.category.color,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.category.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.isSelected
                          ? Colors.white
                          : AppColors.textColor,
                    ),
                  ),
                ],
              ),

              // Tik işareti
              if (widget.isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 300),
                    scale: widget.isSelected ? 1.0 : 0.0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check,
                        color: widget.category.color,
                        size: 16,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}