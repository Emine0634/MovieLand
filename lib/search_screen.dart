// lib/search_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Required file imports
import 'constants.dart';
import 'home_screen.dart';
import 'movie_detail_screen.dart';
import 'profile_screen.dart';
import 'category_screen.dart';
import 'filter_screen.dart';

// MARK: - API Constants
const String TMDB_API_KEY = "d673c3c583c49a1a90c1041702321797";
const String SEARCH_URL = "https://api.themoviedb.org/3/search/movie";
const String DISCOVER_URL = "https://api.themoviedb.org/3/discover/movie";
const String IMAGE_BASE_URL = "https://image.tmdb.org/t/p/w500";

// MARK: - Search Screen
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Movie> searchResults = [];
  bool isLoading = false;
  String? searchError;
  String currentQuery = '';
  int _selectedNavIndex = 1;

  // Active Filters
  String? activeGenreFilter;
  double? activeRatingFilter;
  int? activeYearFilter;
  bool hasActiveFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});

    if (_searchController.text.length > 2 && _searchController.text != currentQuery) {
      _searchMovies(_searchController.text);
    } else if (_searchController.text.isEmpty) {
      setState(() {
        currentQuery = '';
        searchResults = [];
        searchError = null;
      });
      if (hasActiveFilters) {
        _searchMoviesFiltered();
      }
    }
  }

  Future<void> _searchMovies(String query) async {
    if (hasActiveFilters) {
      _searchMoviesFiltered(query: query);
      return;
    }

    if (query.trim().isEmpty) return;

    setState(() {
      isLoading = true;
      searchError = null;
      currentQuery = query;
    });

    try {
      final response = await http.get(Uri.parse(
          '$SEARCH_URL?api_key=$TMDB_API_KEY&language=en-US&query=${Uri.encodeQueryComponent(query)}&page=1'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];

        final movies = results
            .map((json) => Movie.fromJson(json))
            .where((movie) => movie.posterPath.isNotEmpty)
            .toList();

        setState(() {
          searchResults = movies;
          if (movies.isEmpty) {
            searchError = 'No movies found matching "$query".';
          }
        });
      } else {
        throw Exception('Failed to fetch search results');
      }
    } catch (e) {
      setState(() {
        searchError = 'An error occurred during search';
        searchResults = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _searchMoviesFiltered({String? query}) async {
    if (query == null && !hasActiveFilters) {
      setState(() {
        searchResults = [];
        searchError = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      searchError = null;
      currentQuery = query ?? '';
    });

    try {
      var uri = Uri.parse('$DISCOVER_URL?api_key=$TMDB_API_KEY&language=en-US&sort_by=popularity.desc');

      if (activeRatingFilter != null && activeRatingFilter! > 0) {
        uri = uri.replace(queryParameters: {
          ...uri.queryParameters,
          'vote_average.gte': activeRatingFilter!.toStringAsFixed(1),
          'vote_count.gte': '100',
        });
      }

      if (activeYearFilter != null) {
        uri = uri.replace(queryParameters: {
          ...uri.queryParameters,
          'primary_release_year': activeYearFilter.toString(),
        });
      }

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];

        var movies = results
            .map((json) => Movie.fromJson(json))
            .where((movie) => movie.posterPath.isNotEmpty)
            .toList();

        if (query != null && query.isNotEmpty) {
          movies = movies.where((m) => m.title.toLowerCase().contains(query.toLowerCase())).toList();
        }

        setState(() {
          searchResults = movies;
          if (movies.isEmpty) {
            searchError = 'No movies found matching the applied filters.';
          }
        });
      } else {
        throw Exception('Failed to fetch filtered results');
      }
    } catch (e) {
      setState(() {
        searchError = 'An error occurred during filtered search';
        searchResults = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      activeGenreFilter = null;
      activeRatingFilter = null;
      activeYearFilter = null;
      hasActiveFilters = false;
    });
    if (_searchController.text.isNotEmpty) {
      _searchMovies(_searchController.text);
    } else {
      setState(() {
        searchResults = [];
        searchError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.mainBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(
              Icons.search,
              color: AppColors.logInButtonColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Search Movies',
              style: TextStyle(
                color: AppColors.titleColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.textFieldFillColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.textFieldBorderColor.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryDarkColor.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          cursorColor: AppColors.logInButtonColor,
                          style: const TextStyle(
                            color: AppColors.textColor,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search movies...',
                            hintStyle: TextStyle(
                              color: AppColors.subtitleColor.withOpacity(0.5),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.subtitleColor,
                              size: 20,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: AppColors.subtitleColor,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged();
                              },
                            )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onSubmitted: (value) => _searchMovies(value),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filter Button
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: hasActiveFilters
                            ? AppColors.logInButtonColor
                            : AppColors.textFieldFillColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hasActiveFilters
                              ? AppColors.logInButtonColor
                              : AppColors.textFieldBorderColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: hasActiveFilters
                            ? [
                          BoxShadow(
                            color: AppColors.logInButtonColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                            : null,
                      ),
                      child: Stack(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.tune,
                              color: hasActiveFilters
                                  ? Colors.white
                                  : AppColors.textColor,
                              size: 24,
                            ),
                            onPressed: () async {
                              final Map<String, dynamic>? filters =
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const FilterScreen(),
                                ),
                              );

                              if (filters != null) {
                                setState(() {
                                  activeGenreFilter = filters['genre'] as String?;
                                  activeRatingFilter = filters['rating'] as double?;
                                  activeYearFilter = filters['year'] as int?;
                                  hasActiveFilters = activeGenreFilter != null ||
                                      (activeRatingFilter != null && activeRatingFilter! > 0) ||
                                      activeYearFilter != null;
                                });

                                if (_searchController.text.isNotEmpty) {
                                  _searchMoviesFiltered(query: _searchController.text);
                                } else {
                                  _searchMoviesFiltered();
                                }
                              }
                            },
                          ),
                          if (hasActiveFilters)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Active Filters Display
                if (hasActiveFilters) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.logInButtonColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.logInButtonColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_alt,
                          color: AppColors.logInButtonColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (activeRatingFilter != null && activeRatingFilter! > 0)
                                _FilterChip(
                                  label: '⭐ ${activeRatingFilter!.toStringAsFixed(1)}+',
                                ),
                              if (activeYearFilter != null)
                                _FilterChip(
                                  label: '📅 ${activeYearFilter}',
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: AppColors.logInButtonColor,
                            size: 18,
                          ),
                          onPressed: _clearFilters,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Search Info Bar
          if (searchResults.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${searchResults.length} results found',
                    style: TextStyle(
                      color: AppColors.subtitleColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (currentQuery.isNotEmpty)
                    Text(
                      'for "$currentQuery"',
                      style: TextStyle(
                        color: AppColors.logInButtonColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Result Area
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() => _selectedNavIndex = index);
        },
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.logInButtonColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Searching...',
              style: TextStyle(
                color: AppColors.subtitleColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (searchError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                color: AppColors.subtitleColor.withOpacity(0.5),
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                searchError!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  if (_searchController.text.isNotEmpty) {
                    _searchMovies(_searchController.text);
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.logInButtonColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (searchResults.isEmpty && currentQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_filter_outlined,
              color: AppColors.subtitleColor.withOpacity(0.5),
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              'Search for movies',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Type a movie name to start searching',
              style: TextStyle(
                color: AppColors.subtitleColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Grid with improved sizing
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.58,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return _SearchMovieCard(movie: searchResults[index]);
      },
    );
  }
}

// MARK: - Filter Chip Widget
class _FilterChip extends StatelessWidget {
  final String label;

  const _FilterChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.logInButtonColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.logInButtonColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// MARK: - Search Movie Card
class _SearchMovieCard extends StatelessWidget {
  final Movie movie;

  const _SearchMovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MovieDetailScreen(
                movieId: movie.id,
                onAddToList: (Movie movie, String listKey) {},
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.logInButtonColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.logInButtonColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.5),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        '$IMAGE_BASE_URL${movie.posterPath}',
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: AppColors.textFieldFillColor,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.logInButtonColor,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.textFieldFillColor,
                          child: Center(
                            child: Icon(
                              Icons.movie_creation,
                              color: AppColors.textColor.withOpacity(0.5),
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                      // Gradient overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                movie.title,
                textAlign: TextAlign.left,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: - Bottom Navigation Bar
class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _BottomNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Map<String, List<Movie>> emptyUserLists = {
      'watched': [],
      'favorite': [],
      'toWatch': [],
    };

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.bottomNavColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarItem(
            icon: Icons.home,
            label: 'Home',
            isSelected: selectedIndex == 0,
            onTap: () {
              onTap(0);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
          _NavBarItem(
            icon: Icons.search,
            label: 'Search',
            isSelected: selectedIndex == 1,
            onTap: () => onTap(1),
          ),
          _NavBarItem(
            icon: Icons.favorite,
            label: 'Favorites',
            isSelected: selectedIndex == 2,
            onTap: () {
              onTap(2);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Favorites page coming soon!')),
              );
            },
          ),
          _NavBarItem(
            icon: Icons.person,
            label: 'Profile',
            isSelected: selectedIndex == 3,
            onTap: () {
              onTap(3);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(userLists: emptyUserLists),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.logInButtonColor : Colors.white70,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.logInButtonColor : Colors.white70,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}