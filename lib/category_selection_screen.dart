// lib/category_selection_screen.dart
import 'package:flutter/material.dart';
import 'constants.dart';
import 'home_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
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

  final Set<String> selectedCategories = {};

  void _continue() {
    if (selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one category'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(
          initialFavoriteCategories: selectedCategories,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _skip() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        const HomeScreen(initialFavoriteCategories: {}),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(
                    Icons.movie_filter,
                    color: AppColors.logInButtonColor,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Choose Your Favorites',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.titleColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select categories you love to personalize your experience',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.subtitleColor,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Selected count with animation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selectedCategories.isEmpty
                          ? AppColors.subtitleColor.withOpacity(0.1)
                          : AppColors.logInButtonColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selectedCategories.isEmpty
                            ? AppColors.subtitleColor.withOpacity(0.3)
                            : AppColors.logInButtonColor.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selectedCategories.isEmpty
                              ? Icons.info_outline
                              : Icons.check_circle,
                          color: selectedCategories.isEmpty
                              ? AppColors.subtitleColor
                              : AppColors.logInButtonColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          selectedCategories.isEmpty
                              ? 'No categories selected'
                              : '${selectedCategories.length} ${selectedCategories.length == 1 ? "category" : "categories"} selected',
                          style: TextStyle(
                            color: selectedCategories.isEmpty
                                ? AppColors.subtitleColor
                                : AppColors.logInButtonColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Categories as Compact Buttons
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
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

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.logInButtonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.logInButtonColor.withOpacity(0.4),
                      ),
                      child: const Text(
                        'CONTINUE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _skip,
                    child: Text(
                      'Skip for now',
                      style: TextStyle(
                        color: AppColors.subtitleColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.category.color
                : AppColors.textFieldFillColor,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: widget.isSelected
                  ? widget.category.color
                  : AppColors.textFieldBorderColor.withOpacity(0.3),
              width: widget.isSelected ? 2 : 1.5,
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
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.category.icon,
                color: widget.isSelected
                    ? Colors.white
                    : widget.category.color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                widget.category.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: widget.isSelected
                      ? Colors.white
                      : AppColors.textColor,
                  letterSpacing: 0.5,
                ),
              ),
              if (widget.isSelected) ...[
                const SizedBox(width: 8),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 300),
                  turns: widget.isSelected ? 1 : 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: widget.category.color,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}