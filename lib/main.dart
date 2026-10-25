import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String tmdbApiKey = String.fromEnvironment('TMDB_API_KEY');

void main() {
  runApp(const MovieExplorerApp());
}

class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String releaseDate;
  final double rating;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.rating,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int? ?? 0,
      title: (json['title'] ?? json['original_title'] ?? 'Tanpa judul')
          .toString(),
      overview: (json['overview'] ?? '').toString(),
      posterPath: json['poster_path']?.toString(),
      releaseDate: (json['release_date'] ?? '').toString(),
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get year => releaseDate.length >= 4
      ? releaseDate.substring(0, 4)
      : 'Tahun tidak tersedia';
}

class TmdbService {
  Future<List<Movie>> getMovies({String query = ''}) async {
    if (tmdbApiKey.isEmpty) {
      throw Exception(
        'API Key belum diatur. Jalankan aplikasi dengan '
        '--dart-define=TMDB_API_KEY=API_KEY_KAMU.',
      );
    }

    final bool searching = query.trim().isNotEmpty;
    final String path = searching ? '/3/search/movie' : '/3/movie/popular';

    final uri = Uri.https('api.themoviedb.org', path, {
      'api_key': tmdbApiKey,
      'language': 'en-US',
      'page': '1',
      if (searching) 'query': query.trim(),
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil data film. HTTP ${response.statusCode}. '
        'Periksa API Key dan koneksi internet.',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>? ?? [];

    return results
        .map((item) => Movie.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

class MovieExplorerApp extends StatelessWidget {
  const MovieExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie Explorer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F7FC),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();
  final TmdbService tmdbService = TmdbService();

  late Future<List<Movie>> moviesFuture;

  @override
  void initState() {
    super.initState();
    moviesFuture = tmdbService.getMovies();
  }

  void loadMovies([String query = '']) {
    FocusScope.of(context).unfocus();
    setState(() {
      moviesFuture = tmdbService.getMovies(query: query);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Movie Explorer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: loadMovies,
              decoration: InputDecoration(
                hintText: 'Cari judul film...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Cari film',
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => loadMovies(searchController.text),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Jelajahi Film',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: moviesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Memuat daftar film...'),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tidak dapat memuat film',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () =>
                                loadMovies(searchController.text.trim()),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final movies = snapshot.data ?? [];

                if (movies.isEmpty) {
                  return const Center(child: Text('Film tidak ditemukan.'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  itemCount: movies.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.57,
                  ),
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return MovieCard(
                      movie: movie,
                      onTap: () => showMovieDetails(context, movie),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const MovieCard({super.key, required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: movie.posterPath != null && movie.posterPath!.isNotEmpty
                    ? Image.network(
                        'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const PosterPlaceholder();
                        },
                      )
                    : const PosterPlaceholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    movie.year,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(movie.rating.toStringAsFixed(1)),
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
}

class PosterPlaceholder extends StatelessWidget {
  const PosterPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepPurple.shade50,
      alignment: Alignment.center,
      child: Icon(
        Icons.movie_outlined,
        size: 54,
        color: Colors.deepPurple.shade200,
      ),
    );
  }
}

void showMovieDetails(BuildContext context, Movie movie) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                movie.title,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('${movie.year}  •  ⭐ ${movie.rating.toStringAsFixed(1)}'),
              const SizedBox(height: 18),
              const Text(
                'Sinopsis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                movie.overview.isEmpty
                    ? 'Sinopsis belum tersedia.'
                    : movie.overview,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ],
          ),
        ),
      );
    },
  );
}
