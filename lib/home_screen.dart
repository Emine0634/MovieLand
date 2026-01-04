// lib/home_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'login_screen.dart';
import 'category_screen.dart';
import 'movie_detail_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

// API Sabitleri ve Movie Modeli
const String TMDB_API_KEY = "d673c3c583c49a1a90c1041702321797";
const String BASE_URL = "https://api.themoviedb.org/3/movie";
const String IMAGE_BASE_URL = "https://image.tmdb.org/t/p/w500";

class Movie {
  final int id;
  final String title;
  final String posterPath;
  Movie({required this.id, required this.title, required this.posterPath});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown Title',
      posterPath: json['poster_path'] ?? '',
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Set<String> initialFavoriteCategories;

  const HomeScreen({
    super.key,
    this.initialFavoriteCategories = const {},
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<Movie> popularMovies = [];
  List<Movie> topRatedMovies = [];
  Map<String, List<Movie>> categoryMovieMap = {};
  Set<String> favoriteCategories = {};
  List<Movie> watchedMovies = [];
  List<Movie> favoriteMovies = [];
  List<Movie> toWatchMovies = [];

  bool isLoading = true;
  String? errorMessage;
  int _selectedNavIndex = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    favoriteCategories = widget.initialFavoriteCategories;

    // Fade animasyonu için
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Test verileri
    watchedMovies = [
      Movie(id: 1000, title: "Eden", posterPath: "/tXqN8mJk60S8j3V9uS0S6R0b7Y.jpg"),
    ];
    favoriteMovies = [
      Movie(id: 1001, title: "Burn", posterPath: "/j4P5vj4y5f4y5f4y5f4y5f4y5f.jpg"),
    ];
    toWatchMovies = [
      Movie(id: 1002, title: "It 2", posterPath: "/9z0kU1g2g1g1g1g1g1g1g1g1g1g.jpg"),
    ];

    _fetchMovieData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void addMovieToUserList(Movie movie, String listKey) {
    setState(() {
      List<Movie> targetList;
      if (listKey == 'toWatch') {
        targetList = toWatchMovies;
      } else if (listKey == 'favorite') {
        targetList = favoriteMovies;
      } else {
        return;
      }
      if (!targetList.any((m) => m.id == movie.id)) {
        targetList.add(movie);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${movie.title} added to ${listKey == "toWatch" ? "Watchlist" : "Favorites"}'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  int? _resolveGenreId(String categoryName) {
    if (TMDB_GENRES.containsKey(categoryName)) return TMDB_GENRES[categoryName];

    final normalized = categoryName.toLowerCase().replaceAll(RegExp(r'[\s\-_]'), '');
    for (final entry in TMDB_GENRES.entries) {
      final keyNorm = entry.key.toLowerCase().replaceAll(RegExp(r'[\s\-_]'), '');
      if (keyNorm == normalized) return entry.value;
    }

    final altMap = <String, String>{
      'sci-fi': 'Science Fiction',
      'scifi': 'Science Fiction',
      'sciencefiction': 'Science Fiction',
      'animation': 'Animation',
      'romance': 'Romance',
      'thriller': 'Thriller',
      'fantasy': 'Fantasy',
      'action': 'Action',
      'comedy': 'Comedy',
      'drama': 'Drama',
      'horror': 'Horror',
    };

    final altKey = altMap[normalized];
    if (altKey != null && TMDB_GENRES.containsKey(altKey)) {
      return TMDB_GENRES[altKey];
    }
    return null;
  }

  Future<void> _fetchCategoryMovies() async {
    if (favoriteCategories.isEmpty || TMDB_GENRES.isEmpty) return;

    categoryMovieMap = {};

    for (var categoryName in favoriteCategories) {
      final genreId = _resolveGenreId(categoryName);
      if (genreId == null) continue;

      const String languageCode = 'en-US';
      final url = 'https://api.themoviedb.org/3/discover/movie?api_key=$TMDB_API_KEY&language=$languageCode&sort_by=popularity.desc&with_genres=$genreId';

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List<dynamic> results = data['results'] ?? [];
          final movies = results.map((json) => Movie.fromJson(json)).toList();
          categoryMovieMap[categoryName] = movies;
        }
      } catch (e) {
        categoryMovieMap[categoryName] = [];
      }
    }
  }

  Future<void> _fetchMovieData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await _fetchMovies('popular', (movies) => popularMovies = movies);
      await _fetchMovies('top_rated', (movies) => topRatedMovies = movies);
      await _fetchCategoryMovies();

      _animationController.forward();
    } catch (e) {
      errorMessage = 'Failed to fetch data: $e';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchMovies(String category, Function(List<Movie>) onFetched) async {
    final response = await http.get(
        Uri.parse('$BASE_URL/$category?api_key=$TMDB_API_KEY&language=en-US&page=1')
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'] ?? [];
      final movies = results.map((json) => Movie.fromJson(json)).toList();
      onFetched(movies);
    } else {
      throw Exception('Failed to fetch $category movies');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userLists = {
      'watched': watchedMovies,
      'favorite': favoriteMovies,
      'toWatch': toWatchMovies,
    };

    return Scaffold(
      backgroundColor: AppColors.mainBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.mainBackgroundColor,
        elevation: 0,
        title: Row(
          children: [
            Icon(
              Icons.movie_creation_outlined,
              color: AppColors.logInButtonColor,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'MovieLand',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.titleColor,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.category_outlined,
              color: AppColors.textColor,
              size: 26,
            ),
            tooltip: 'Categories',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CategoryScreen(userLists: userLists),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.logInButtonColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading movies...',
              style: TextStyle(
                color: AppColors.subtitleColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      )
          : errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.logInButtonColor,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchMovieData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.logInButtonColor,
                ),
              ),
            ],
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchMovieData,
        color: AppColors.logInButtonColor,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Center(child: _MovieLandTitleSection()),
                const SizedBox(height: 10),

                _MovieSection(
                  title: 'Popular Now',
                  movies: popularMovies,
                  icon: Icons.trending_up,
                ),
                const SizedBox(height: 30),

                _MovieSection(
                  title: 'Top Rated',
                  movies: topRatedMovies,
                  icon: Icons.star,
                ),
                const SizedBox(height: 30),

                ...categoryMovieMap.entries.map((entry) {
                  if (entry.value.isEmpty) return const SizedBox.shrink();
                  return Column(
                    children: [
                      _MovieSection(
                        title: entry.key,
                        movies: entry.value,
                        icon: Icons.favorite,
                        isFavorite: true,
                      ),
                      const SizedBox(height: 30),
                    ],
                  );
                }),

                if (categoryMovieMap.isEmpty && favoriteCategories.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 64,
                            color: AppColors.subtitleColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No favorite categories selected',
                            style: TextStyle(
                              color: AppColors.subtitleColor,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CategoryScreen(userLists: userLists),
                                ),
                              );
                            },
                            child: const Text('Browse Categories'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        userLists: userLists,
        selectedIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() => _selectedNavIndex = index);
        },
      ),
    );
  }
}

class _MovieLandTitleSection extends StatelessWidget {
  const _MovieLandTitleSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      child: Column(
        children: [
          Text(
            '"Discover, Watch, Enjoy"',
            style: TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: AppColors.logInButtonColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieSection extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final IconData? icon;
  final bool isFavorite;

  const _MovieSection({
    required this.title,
    required this.movies,
    this.icon,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayMovies = movies.take(15).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header - See All butonu kaldırıldı
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: isFavorite
                      ? AppColors.logInButtonColor
                      : AppColors.textColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              // Film sayısı göstergesi
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.logInButtonColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${displayMovies.length}',
                  style: TextStyle(
                    color: AppColors.logInButtonColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),

        // Movie List with Ribbon Background
        Container(
          height: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.mainBackgroundColor,
                AppColors.logInButtonColor.withOpacity(0.08),
                AppColors.logInButtonColor.withOpacity(0.12),
                AppColors.logInButtonColor.withOpacity(0.08),
                AppColors.mainBackgroundColor,
              ],
              stops: const [0.0, 0.15, 0.5, 0.85, 1.0],
            ),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
            itemCount: displayMovies.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: SizedBox(
                  width: 130,
                  child: _MovieCard(movie: displayMovies[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MovieCard extends StatelessWidget {
  final Movie movie;

  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    final _HomeScreenState? homeState =
    context.findAncestorStateOfType<_HomeScreenState>();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (homeState != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MovieDetailScreen(
                  movieId: movie.id,
                  onAddToList: homeState.addMovieToUserList,
                ),
              ),
            );
          }
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
                      color: AppColors.logInButtonColor.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.5),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      movie.posterPath.isNotEmpty
                          ? Image.network(
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
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                              color: AppColors.textFieldFillColor,
                              child: Center(
                                child: Icon(
                                  Icons.movie_creation,
                                  color: AppColors.textColor.withOpacity(0.5),
                                  size: 40,
                                ),
                              ),
                            ),
                      )
                          : Container(
                        color: AppColors.textFieldFillColor,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.movie_creation,
                                color: AppColors.textColor.withOpacity(0.5),
                                size: 40,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No Poster',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textColor.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Gradient overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 60,
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
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                movie.title,
                textAlign: TextAlign.left,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
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

class _BottomNavBar extends StatelessWidget {
  final Map<String, List<Movie>> userLists;
  final int selectedIndex;
  final Function(int) onTap;

  const _BottomNavBar({
    required this.userLists,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
            onTap: () => onTap(0),
          ),
          _NavBarItem(
            icon: Icons.search,
            label: 'Search',
            isSelected: selectedIndex == 1,
            onTap: () {
              onTap(1);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
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
                  builder: (context) => ProfileScreen(userLists: userLists),
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