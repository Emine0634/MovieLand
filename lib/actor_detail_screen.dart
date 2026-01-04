// lib/actor_detail_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Gerekli API sabitleri ve renkler için import
import 'constants.dart';

// MARK: - API Sabitleri (Movie Detail'den Tekrar Tanımlandı)
const String TMDB_API_KEY = "d673c3c583c49a1a90c1041702321797"; // API Key
const String PERSON_IMAGE_BASE_URL = "https://image.tmdb.org/t/p/w500";
// Oyuncu detay fotoğrafı için

// MARK: - PersonDetail Modeli (movie_detail_screen'den taşındı)
class PersonDetail {
  final int id;
  final String name;
  final String? birthday;
  final String? biography;
  final String? placeOfBirth;
  final String? profilePath;

  PersonDetail({
    required this.id,
    required this.name,
    this.birthday,
    this.biography,
    this.placeOfBirth,
    this.profilePath,
  });

  factory PersonDetail.fromJson(Map<String, dynamic> json) {
    return PersonDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      birthday: json['birthday'],
      biography: json['biography'] ?? 'Biography not available.',
      placeOfBirth: json['place_of_birth'] ?? 'Unknown',
      profilePath: json['profile_path'],
    );
  }
}


// ***************************************************************
// MARK: - OYUNCU DETAY EKRANI (ActorDetailScreen)
// ***************************************************************

class ActorDetailScreen extends StatefulWidget {
  final int personId;
  final String personName;

  const ActorDetailScreen({super.key, required this.personId, required this.personName});

  @override
  State<ActorDetailScreen> createState() => _ActorDetailScreenState();
}

class _ActorDetailScreenState extends State<ActorDetailScreen> {
  PersonDetail? personDetail;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchActorDetails();
  }

  // MARK: - Oyuncu Detaylarını Çekme
  Future<void> _fetchActorDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // TMDB person API endpoint'i
    final url = 'https://api.themoviedb.org/3/person/${widget.personId}?api_key=$TMDB_API_KEY&language=en-US';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        personDetail = PersonDetail.fromJson(data);
      } else {
        throw Exception('Failed to fetch actor details: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage = 'Failed to load actor data: $e';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = personDetail?.profilePath != null
        ? '$PERSON_IMAGE_BASE_URL${personDetail!.profilePath}'
        : 'https://via.placeholder.com/500x750?text=No+Photo';

    return Scaffold(
      backgroundColor: AppColors.mainBackgroundColor,
      appBar: AppBar(
        title: Text(
          personDetail?.name ?? widget.personName,
          style: const TextStyle(color: AppColors.titleColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.mainBackgroundColor,
        iconTheme: const IconThemeData(color: AppColors.textColor),
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.logInButtonColor))
          : errorMessage != null
          ? Center(child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)),
      ))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Oyuncu Fotoğrafı ve Bilgileri
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    width: 120,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 120,
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.textFieldFillColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Icon(Icons.person, size: 50, color: AppColors.textColor.withOpacity(0.5))),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailInfoRow(label: 'Born', value: personDetail!.birthday ?? 'N/A'),
                      const SizedBox(height: 10),
                      _DetailInfoRow(label: 'Birthplace', value: personDetail!.placeOfBirth ?? 'N/A'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Biyografi Başlık
            const Text(
              'Biography',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Biyografi Metni
            Text(
              personDetail!.biography ?? 'Biography not available.',
              style: const TextStyle(
                color: AppColors.subtitleColor,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: - Alt Widget: Detay Bilgi Satırı
class _DetailInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AppColors.subtitleColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}