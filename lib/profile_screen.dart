// lib/profile_screen.dart
import 'package:flutter/material.dart';
import 'constants.dart';
import 'home_screen.dart'; // Movie modeli ve IMAGE_BASE_URL için
import 'search_screen.dart'; // Navigasyon için
import 'category_screen.dart'; // Navigasyon için

// TMDB API'dan afiş çekmek için gerekli sabit (home_screen.dart'tan alınmıştır)
const String IMAGE_BASE_URL = "https://image.tmdb.org/t/p/w500";

// MARK: - Profil Ekranı (GÜNCELLENDİ)
class ProfileScreen extends StatelessWidget {
  // ✅ Dışarıdan gelen listeler ve hangi listenin en üstte gösterileceği
  final Map<String, List<Movie>> userLists;
  final String? initialListKey;

  const ProfileScreen({
    super.key,
    required this.userLists,
    this.initialListKey,
  });

  @override
  Widget build(BuildContext context) {
    // Kategori butonundan gelindiyse, sadece o listeyi göster.
    final bool isSingleListMode = initialListKey != null;

    // Göz atılacak listeler - Sıralama: Favoriler, İzlenecekler, İzlenenler
    final List<Map<String, dynamic>> sections = [
      {'key': 'favorite', 'title': 'My Favorite List', 'movies': userLists['favorite']!},
      {'key': 'toWatch', 'title': 'Movies To Watch', 'movies': userLists['toWatch']!},
      {'key': 'watched', 'title': 'Watched Movies', 'movies': userLists['watched']!},
    ];

    // Eğer tek liste modundaysak, sadece o listeyi filtrele
    final displaySections = isSingleListMode
        ? sections.where((s) => s['key'] == initialListKey).toList()
        : sections;

    // Eğer tek liste modu ve o liste boşsa
    if (isSingleListMode && displaySections.isEmpty) {
      final listTitle = sections.firstWhere((s) => s['key'] == initialListKey)['title'];
      return Scaffold(
        backgroundColor: AppColors.mainBackgroundColor,
        appBar: AppBar(
          title: Text(listTitle, style: const TextStyle(color: AppColors.textColor)),
          backgroundColor: AppColors.mainBackgroundColor,
        ),
        body: Center(
          child: Text(
            '$listTitle listeniz henüz boş.',
            style: const TextStyle(fontSize: 18, color: AppColors.textColor),
          ),
        ),
        bottomNavigationBar: _BottomNavBar(userLists: userLists),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.mainBackgroundColor,
      // Eğer tek liste modundaysak, başlığı AppBar'da göster
      appBar: isSingleListMode
          ? AppBar(
        title: Text(displaySections.first['title'], style: const TextStyle(color: AppColors.textColor)),
        backgroundColor: AppColors.mainBackgroundColor,
      )
          : null, // Değilse AppBar'ı kullanma

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 10, bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Sadece tüm listeler gösteriliyorsa Profil Bilgisi gösterilir.
            if (!isSingleListMode) ...[
              Center(child: _ProfileInfo()),
            ],

            // Dinamik olarak listeleri göster
            ...displaySections.map((section) => Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: _UserMovieSection(
                title: section['title'],
                movies: section['movies'],
              ),
            )).toList(),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(userLists: userLists),
    );
  }
}

// MARK: - Alt Widget: Profil Bilgileri (Aynı kalır)
class _ProfileInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // MovieLand Başlığı
        Text(
          'MovieLand',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: AppColors.textColor,
            letterSpacing: -1.5,
          ),
        ),
        Text(
          "Discover, Watch, Enjoy",
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 20),

        // Profil İkonu
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.purple.shade500, width: 4), // Mor çerçeve
            color: AppColors.textFieldFillColor,
          ),
          child: const Center(
            child: Icon(
              Icons.person,
              size: 80,
              color: AppColors.textColor,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Kullanıcı Adı
        Text(
          'Movie_fan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

// MARK: - Alt Widget: Kullanıcı Film Bölümü (Aynı kalır)
class _UserMovieSection extends StatelessWidget {
  final String title;
  final List<Movie> movies;

  const _UserMovieSection({required this.title, required this.movies});

  @override
  Widget build(BuildContext context) {
    // Listede film yoksa yer tutucu göster
    if (movies.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              color: AppColors.primaryDarkColor.withOpacity(0.5),
              width: double.infinity,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: Text(
                'Bu liste boş.',
                style: TextStyle(color: AppColors.textColor.withOpacity(0.7)),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bölüm Başlığı
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            color: AppColors.primaryDarkColor.withOpacity(0.5),
            width: double.infinity,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Film Listesi
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: movies.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < movies.length - 1 ? 15.0 : 0,
                  ),
                  child: _ProfileMovieCard(movie: movies[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// MARK: - Alt Widget: Profil Film Kartı (GÜNCELLENDİ - Afiş yok yazısı kaldırıldı)
class _ProfileMovieCard extends StatelessWidget {
  final Movie movie;

  const _ProfileMovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    // Eğer posterPath boşsa, bu filmi gösterme
    if (movie.posterPath.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: 100, // Afiş genişliği
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Film Afişi
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                // TMDB API'den afiş çekme
                '$IMAGE_BASE_URL${movie.posterPath}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// MARK: - Alt Widget: Bottom Navigation Bar (GÜNCELLENDİ)
class _BottomNavBar extends StatelessWidget {
  final Map<String, List<Movie>> userLists; // ✅ userLists kabul edildi

  const _BottomNavBar({required this.userLists});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: const BoxDecoration(
        color: AppColors.bottomNavColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // HOME
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white70, size: 30),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
          // SEARCH
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white70, size: 30),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
          ),
          // FAVORITE
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white70, size: 30),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Favoriler')),
              );
            },
          ),
          // PROFILE - Aktif İkon
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white, size: 30), // İçi dolu (Aktif)
            onPressed: () {}, // Zaten bu sayfadayız
          ),
        ],
      ),
    );
  }
}