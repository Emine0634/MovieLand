// lib/movie_detail_screen.dart (GERİ DÖNÜŞ BUTONU EKLENMİŞ VERSİYON)

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'category_screen.dart';
import 'actor_detail_screen.dart';

// MARK: - API Sabitleri
const String TMDB_API_KEY = "d673c3c583c49a1a90c1041702321797";
const String BASE_URL = "https://api.themoviedb.org/3/movie";
const String IMAGE_BASE_URL_W500 = "https://image.tmdb.org/t/p/w500";
const String CAST_IMAGE_BASE_URL = "https://image.tmdb.org/t/p/w185";
const String YOUTUBE_BASE_URL = "https://www.youtube.com/watch?v=";

// MARK: - API Modelleri
class CastMember {
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  CastMember({required this.id, required this.name, required this.character, this.profilePath});

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      character: json['character'] ?? 'No Role',
      profilePath: json['profile_path'],
    );
  }
}

typedef MovieListCallback = void Function(Movie movie, String listKey);

// MARK: - Film Detay Ekranı
class MovieDetailScreen extends StatefulWidget {
  final int movieId;
  final MovieListCallback onAddToList;

  const MovieDetailScreen({
    super.key,
    required this.movieId,
    required this.onAddToList,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Map<String, dynamic>? movieDetail;
  List<CastMember> cast = [];
  String? trailerKey;
  bool isLoading = true;
  String? errorMessage;

  // Örnek yorumlar
  List<Map<String, String>> comments = [
    {'username': 'movie_fan', 'comment': 'A very nice movie', 'rating': '5'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchDetailData();
  }

  // Film İzleme Fonksiyonu
  Future<void> _launchMovie(int id) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening Movie Player for ID: $id...')),
    );
  }

  // Fragman URL'sini açan fonksiyon
  Future<void> _launchTrailer(String? key) async {
    if (key == null || key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No trailer found for this movie.')),
      );
      return;
    }

    final Uri url = Uri.parse('$YOUTUBE_BASE_URL$key');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch trailer.')),
        );
      }
    }
  }

  // Film detaylarını, kadrosunu ve fragmanını çeken fonksiyon
  Future<void> _fetchDetailData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      await _fetchMovieDetails();
      await _fetchMovieCast();
      await _fetchMovieTrailer();
    } catch (e) {
      errorMessage = 'Failed to load details.';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Film Detaylarını Çek
  Future<void> _fetchMovieDetails() async {
    final response = await http.get(Uri.parse('$BASE_URL/${widget.movieId}?api_key=$TMDB_API_KEY&language=en-US'));
    if (response.statusCode == 200) {
      movieDetail = json.decode(response.body);
    } else {
      throw Exception('Failed to fetch movie details');
    }
  }

  // Film Fragmanını Çek
  Future<void> _fetchMovieTrailer() async {
    final response = await http.get(Uri.parse('$BASE_URL/${widget.movieId}/videos?api_key=$TMDB_API_KEY'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];

      final trailer = results.firstWhere(
              (video) => video['site'] == 'YouTube' && (video['type'] == 'Trailer' || video['type'] == 'Teaser'),
          orElse: () => null);

      if (trailer != null) {
        setState(() {
          trailerKey = trailer['key'];
        });
      }
    }
  }

  // Film Kadrosunu Çek
  Future<void> _fetchMovieCast() async {
    final response = await http.get(Uri.parse('$BASE_URL/${widget.movieId}/credits?api_key=$TMDB_API_KEY'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> castResults = data['cast'];
      cast = castResults.map((json) => CastMember.fromJson(json)).toList().take(6).toList();
    } else {
      throw Exception('Failed to fetch cast');
    }
  }

  // Aksiyon Fonksiyonları
  void _addCurrentMovieToList(BuildContext context, String listKey) {
    if (movieDetail == null) return;

    final currentMovie = Movie(
      id: movieDetail!['id'],
      title: movieDetail!['title'],
      posterPath: movieDetail!['poster_path'] ?? '',
    );

    widget.onAddToList(currentMovie, listKey);

    String listName = listKey == 'toWatch' ? '"Movies To Watch"' : '"Favorite List"';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${currentMovie.title} added to $listName!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.mainBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: AppColors.logInButtonColor)),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.mainBackgroundColor,
        body: Center(
            child: Text(errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.logInButtonColor))),
      );
    }

    final String posterUrl = movieDetail?['poster_path'] != null
        ? '$IMAGE_BASE_URL_W500${movieDetail!['poster_path']}'
        : 'https://via.placeholder.com/500x750?text=No+Poster';

    final String title = movieDetail?['title'] ?? 'Unknown Movie';
    final String overview = movieDetail?['overview'] ?? 'No summary found.';
    final String releaseDate = movieDetail?['release_date'] ?? 'Unknown';
    final double voteAverage = movieDetail?['vote_average']?.toDouble() ?? 0.0;
    String genres = (movieDetail?['genres'] as List?)?.map((g) => g['name']).join(', ') ?? 'Unknown';

    return Scaffold(
      backgroundColor: AppColors.mainBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 0, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // MARK: - Header with Back Button
            _DetailHeader(
              posterUrl: posterUrl,
              title: title,
              onBackPressed: () => Navigator.of(context).pop(),
            ),

            // MARK: - Detay Bilgileri
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 5),
                      Text(
                        voteAverage.toStringAsFixed(1),
                        style: TextStyle(color: AppColors.textColor.withOpacity(0.9), fontSize: 16),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        releaseDate.split('-').first,
                        style: TextStyle(color: AppColors.textColor.withOpacity(0.7), fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    genres,
                    style: TextStyle(color: AppColors.textColor.withOpacity(0.7), fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    overview,
                    style: const TextStyle(
                      color: AppColors.textColor,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 15),
                  TextButton.icon(
                    onPressed: () => _launchTrailer(trailerKey),
                    icon: const Icon(Icons.play_circle_fill, color: AppColors.logInButtonColor, size: 28),
                    label: const Text(
                      "Watch Trailer",
                      style: TextStyle(
                        color: AppColors.logInButtonColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // MARK: - Butonlar
                  Row(
                    children: [
                      Expanded(
                        child: _WatchNowButton(
                          onPressed: () => _launchMovie(widget.movieId),
                        ),
                      ),
                      const SizedBox(width: 15),
                      _ActionIcon(
                        icon: Icons.add,
                        onPressed: () => _addCurrentMovieToList(context, 'toWatch'),
                      ),
                      const SizedBox(width: 15),
                      _ActionIcon(
                        icon: Icons.favorite_border,
                        onPressed: () => _addCurrentMovieToList(context, 'favorite'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // MARK: - Cast & Crew Başlığı
                  const Text(
                    'Cast & Crew',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // MARK: - Cast Listesi
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      itemCount: cast.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: _CastCard(member: cast[index]),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  // MARK: - Yorumlar Başlığı
                  const Text(
                    'Comments',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // MARK: - Yorum Listesi
                  ...comments.map((comment) => _CommentBox(
                    username: comment['username']!,
                    text: comment['comment']!,
                    rating: int.parse(comment['rating']!),
                  )).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _CommentInputBar(),
    );
  }
}

// ***************************************************************
// MARK: - ALT WIDGET TANIMLARI
// ***************************************************************

// MARK: - _DetailHeader (GERİ BUTONU EKLENDİ)
class _DetailHeader extends StatelessWidget {
  final String posterUrl;
  final String title;
  final VoidCallback onBackPressed;

  const _DetailHeader({
    required this.posterUrl,
    required this.title,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    const double POSTER_HEIGHT = 200.0;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: SizedBox(
                height: POSTER_HEIGHT,
                width: double.infinity,
                child: Image.network(
                  posterUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(color: AppColors.mainBackgroundColor);
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.mainBackgroundColor,
                    child: Center(
                      child: Icon(Icons.movie_creation, size: 50, color: AppColors.textColor.withOpacity(0.5)),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        // GERİ DÖNÜŞ BUTONU
        Positioned(
          top: 40,
          left: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              onPressed: onBackPressed,
            ),
          ),
        ),
      ],
    );
  }
}

// MARK: - _WatchNowButton
class _WatchNowButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _WatchNowButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.logInButtonColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      child: const Text(
        'Watch Now',
        style: TextStyle(
          color: AppColors.buttonTextColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// MARK: - _ActionIcon
class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _ActionIcon({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textFieldFillColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.textColor, size: 28),
        onPressed: onPressed,
      ),
    );
  }
}

// MARK: - _CastCard
class _CastCard extends StatelessWidget {
  final CastMember member;

  const _CastCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final String imageUrl = member.profilePath != null
        ? '$CAST_IMAGE_BASE_URL${member.profilePath}'
        : 'https://via.placeholder.com/185x278?text=No+Photo';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ActorDetailScreen(
                personId: member.id,
                personName: member.name,
              ),
            ),
          );
        },
        child: SizedBox(
          width: 80,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.network(
                  imageUrl,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.textFieldFillColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Icon(Icons.person, color: AppColors.textColor.withOpacity(0.5))),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                member.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textColor, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// MARK: - _CommentBox
class _CommentBox extends StatelessWidget {
  final String username;
  final String text;
  final int rating;

  const _CommentBox({required this.username, required this.text, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$username :',
                style: const TextStyle(
                  color: AppColors.logInButtonColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 18,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// MARK: - _CommentInputBar
class _CommentInputBar extends StatelessWidget {
  const _CommentInputBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: AppColors.bottomNavColor,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                hintStyle: TextStyle(color: AppColors.textColor.withOpacity(0.6)),
                filled: true,
                fillColor: AppColors.mainBackgroundColor.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
              style: const TextStyle(color: AppColors.textColor),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Comment sent!')));
            },
            child: const Icon(
              Icons.send,
              color: AppColors.logInButtonColor,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}