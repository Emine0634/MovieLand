// lib/filter_screen.dart
import 'package:flutter/material.dart';
import 'constants.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String? _selectedGenre;
  double _selectedRating = 0.0; // ✅ FIXED: 7.0 yerine 0.0'dan başlıyor
  int? _selectedYear;

  final List<Map<String, dynamic>> _genres = [
    {'name': 'Action', 'icon': Icons.flash_on, 'color': Colors.orange},
    {'name': 'Drama', 'icon': Icons.theater_comedy, 'color': Colors.purple},
    {'name': 'Comedy', 'icon': Icons.mood, 'color': Colors.yellow},
    {'name': 'Horror', 'icon': Icons.nightlight, 'color': Colors.red},
    {'name': 'Sci-Fi', 'icon': Icons.rocket_launch, 'color': Colors.blue},
    {'name': 'Fantasy', 'icon': Icons.auto_awesome, 'color': Colors.pink},
    {'name': 'Romance', 'icon': Icons.favorite, 'color': Colors.redAccent},
    {'name': 'Thriller', 'icon': Icons.warning, 'color': Colors.deepOrange},
    {'name': 'Animation', 'icon': Icons.emoji_emotions, 'color': Colors.green},
  ];

  final List<int> _years =
  List.generate(15, (index) => DateTime.now().year - index);

  bool get _hasActiveFilters =>
      _selectedGenre != null ||
          _selectedRating > 0 ||
          _selectedYear != null;

  Widget _buildStarRatingBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rating: ${_selectedRating > 0 ? _selectedRating.toStringAsFixed(1) : "Any"}',
              style: const TextStyle(
                color: AppColors.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_selectedRating > 0)
              TextButton(
                onPressed: () {
                  setState(() => _selectedRating = 0.0);
                },
                child: Text(
                  'Clear',
                  style: TextStyle(
                    color: AppColors.logInButtonColor,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(10, (index) {
            final double starValue = index + 1.0;
            final bool isSelected = starValue <= _selectedRating;
            final bool isHovered = starValue <= _selectedRating;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRating = starValue;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Icon(
                    isSelected ? Icons.star : Icons.star_border,
                    color: isSelected
                        ? Colors.amber
                        : AppColors.subtitleColor.withOpacity(0.3),
                    size: 28,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedRating > 0
              ? 'Movies with ${_selectedRating.toStringAsFixed(1)}+ rating'
              : 'Select minimum rating',
          style: TextStyle(
            color: AppColors.subtitleColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterCard({
    required String title,
    required Widget content,
    Widget? action,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.textFieldFillColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.textFieldBorderColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.tune,
                      color: AppColors.logInButtonColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (action != null) action,
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedGenre = null;
      _selectedRating = 0.0;
      _selectedYear = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All filters cleared'),
        backgroundColor: AppColors.logInButtonColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _applyFilters() {
    Navigator.pop(context, {
      'genre': _selectedGenre,
      'rating': _selectedRating,
      'year': _selectedYear,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.filter_list,
              color: AppColors.logInButtonColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Filters',
              style: TextStyle(
                color: AppColors.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.mainBackgroundColor,
        iconTheme: const IconThemeData(color: AppColors.textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Active filters indicator
            if (_hasActiveFilters)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.logInButtonColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.logInButtonColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.logInButtonColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You have active filters',
                        style: TextStyle(
                          color: AppColors.logInButtonColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              ),

            // GENRE FILTER
            _buildFilterCard(
              title: 'Genre',
              content: Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: _genres.map((genre) {
                  final isSelected = _selectedGenre == genre['name'];
                  return FilterChip(
                    avatar: Icon(
                      genre['icon'],
                      size: 18,
                      color: isSelected ? Colors.white : genre['color'],
                    ),
                    label: Text(genre['name']),
                    selected: isSelected,
                    selectedColor: genre['color'],
                    backgroundColor: AppColors.primaryDarkColor,
                    labelStyle: TextStyle(
                      color:
                      isSelected ? Colors.white : AppColors.subtitleColor,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? genre['color']
                            : AppColors.textFieldBorderColor,
                        width: 1.5,
                      ),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedGenre = selected ? genre['name'] : null;
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            // RATING FILTER
            _buildFilterCard(
              title: 'Minimum Rating',
              content: _buildStarRatingBar(),
            ),

            // RELEASE YEAR FILTER
            _buildFilterCard(
              title: 'Release Year',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.mainBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.textFieldBorderColor.withOpacity(0.3),
                      ),
                    ),
                    child: DropdownButtonFormField<int>(
                      value: _selectedYear,
                      hint: const Text(
                        'Select Year',
                        style: TextStyle(color: AppColors.subtitleColor),
                      ),
                      dropdownColor: AppColors.primaryDarkColor,
                      style: const TextStyle(color: AppColors.textColor),
                      icon: const Icon(Icons.arrow_drop_down,
                          color: AppColors.subtitleColor),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text(
                            'All Years',
                            style: TextStyle(color: AppColors.textColor),
                          ),
                        ),
                        ..._years.map((year) {
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text(
                              year.toString(),
                              style:
                              const TextStyle(color: AppColors.textColor),
                            ),
                          );
                        }),
                      ],
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedYear = newValue;
                        });
                      },
                    ),
                  ),
                  if (_selectedYear != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Showing movies from $_selectedYear',
                      style: TextStyle(
                        color: AppColors.subtitleColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.mainBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _clearFilters,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'CLEAR ALL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.logInButtonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 4,
                ),
                child: const Text(
                  'APPLY FILTERS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}