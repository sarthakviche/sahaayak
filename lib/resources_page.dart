import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // No longer needed for hardcoded data
import 'package:cached_network_image/cached_network_image.dart';
import 'video_player_screen.dart';
// import 'main.dart'; // No longer needed for global 'supabase' client with hardcoded data

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<Map<String, dynamic>?> _featuredVideoFuture;
  late Future<List<Map<String, dynamic>>> _allResourcesFuture;

  String _selectedFilter = 'All';
  String _selectedMediaType = 'video';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _availableCategories = const [
    'All',
    'Anxiety',
    'Sleep',
    'CBT',
    'Meditation',
    'Study',
    'mental_health',
    'tips',
    'resilience',
    'grief',
    'stress',
    'awareness',
    'social',
    'positivity',
    'therapy',
    'work',
    'self_help',
    'wellness',
    'youth',
    'breathing',
    'cognitive_therapy',
    'self_care',
    'depression',
    'trauma',
    'education',
    // Added categories for hardcoded resources
    'motivation',
    'mindfulness',
    'productivity',
  ];

  // Hardcoded resources
  final List<Map<String, dynamic>> _hardcodedResources = [
    // Featured Video
    {
      'id': '1',
      'title': 'The Power of Vulnerability',
      'description':
          'Brené Brown studies human connection -- our ability to empathize, belong, love. In a poignant, funny talk, she shares a deep insight from her research, one that sent her on a personal quest to know herself as well as to understand humanity. A must-see talk.',
      'url': 'https://www.youtube.com/watch?v=iCvmsMzlF7o',
      'type': 'video',
      'category': ['mental_health', 'self_help'],
      'language': 'English',
      'rating': 4.9,
      'is_featured': true,
    },
    // Videos
    {
      'id': '2',
      'title': 'How to Practice Emotional First Aid',
      'description':
          'We\'ll go to the doctor when we feel physically ill, but what about when we feel emotionally ill -- loneliness, failure, rejection, heartbreak? Guy Winch makes a powerful case for practicing emotional hygiene.',
      'url': 'https://www.youtube.com/watch?v=F2COP4yF_lM',
      'type': 'video',
      'category': ['mental_health', 'self_help'],
      'language': 'English',
      'rating': 4.8,
      'is_featured': false,
    },
    {
      'id': '3',
      'title': 'The Antidote to Stress',
      'description':
          'Stress is an inevitable part of modern life. Learn how to reframe your perception of stress to make it work for you, not against you.',
      'url': 'https://www.youtube.com/watch?v=hnpC7W_z0rM',
      'type': 'video',
      'category': ['stress', 'mindfulness'],
      'language': 'English',
      'rating': 4.7,
      'is_featured': false,
    },
    {
      'id': '4',
      'title': 'A Simple Way to Break a Bad Habit',
      'description':
          'Want to break a bad habit? Charles Duhigg offers a simple, powerful strategy based on understanding your habit loops.',
      'url': 'https://www.youtube.com/watch?v=Y4bWn9vj81Q',
      'type': 'video',
      'category': ['self_help', 'tips'],
      'language': 'English',
      'rating': 4.6,
      'is_featured': false,
    },
    // Audios
    {
      'id': '5',
      'title': '5-Minute Mindfulness Meditation',
      'description':
          'A quick guided meditation to bring calm and focus to your day.',
      'url':
          'https://www.youtube.com/watch?v=inpGa6JzK-U', // Using a YouTube link for demonstration, ideally it would be an audio file URL
      'type': 'audio',
      'category': ['Meditation', 'mindfulness'],
      'language': 'English',
      'rating': 4.9,
      'is_featured': false,
    },
    {
      'id': '6',
      'title': 'Deep Sleep Aid with Relaxing Music',
      'description':
          'Calming music designed to help you fall asleep faster and get deeper rest.',
      'url':
          'https://www.youtube.com/watch?v=rC7xQxH3W_U', // Using a YouTube link for demonstration
      'type': 'audio',
      'category': ['Sleep', 'wellness'],
      'language': 'English',
      'rating': 4.8,
      'is_featured': false,
    },
    // Articles
    {
      'id': '7',
      'title': '10 Tips for Managing Anxiety',
      'description':
          'Practical strategies to help you cope with feelings of anxiety in your daily life.',
      'url': 'https://example.com/article-anxiety-tips', // Placeholder URL
      'type': 'article',
      'category': ['Anxiety', 'tips'],
      'language': 'English',
      'rating': 4.7,
      'is_featured': false,
    },
    {
      'id': '8',
      'title': 'The Importance of Self-Care for Mental Health',
      'description':
          'Understand why self-care is crucial for maintaining your psychological well-being.',
      'url': 'https://example.com/article-self-care', // Placeholder URL
      'type': 'article',
      'category': ['self_care', 'mental_health'],
      'language': 'English',
      'rating': 4.5,
      'is_featured': false,
    },
    {
      'id': '9',
      'title': 'Boosting Your Productivity with Mindfulness',
      'description':
          'Combine mindfulness techniques with productivity hacks to achieve more with less stress.',
      'url':
          'https://example.com/article-productivity-mindfulness', // Placeholder URL
      'type': 'article',
      'category': ['mindfulness', 'productivity'],
      'language': 'English',
      'rating': 4.6,
      'is_featured': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _tabController.addListener(_handleTabSelection);

    _featuredVideoFuture = _fetchFeaturedVideo();
    _allResourcesFuture = _fetchResources(type: _selectedMediaType);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        if (_tabController.index == 0) {
          _selectedMediaType = 'article';
        } else if (_tabController.index == 1) {
          _selectedMediaType = 'video';
        } else {
          _selectedMediaType = 'audio';
        }
        _applyFilters();
      });
    }
  }

  String? _getYouTubeVideoId(String url) {
    if (url.isEmpty) return null;
    final regExp = RegExp(
      r'.*(?:youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=)([^#\&\?]*).*',
    );
    final match = regExp.firstMatch(url);
    return (match != null && match.group(1) != null) ? match.group(1) : null;
  }

  String _getYouTubeThumbnail(String youtubeUrl) {
    final videoId = _getYouTubeVideoId(youtubeUrl);
    if (videoId != null) {
      return 'https://img.youtube.com/vi/$videoId/0.jpg';
    }
    return 'https://via.placeholder.com/150';
  }

  // Modified to return hardcoded resources
  Future<List<Map<String, dynamic>>> _fetchResources({
    String? type,
    String? category,
    String? searchTerm,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate network delay
    List<Map<String, dynamic>> filteredResources = _hardcodedResources.where((
      resource,
    ) {
      bool matchesType = true;
      if (type != null && type != 'All') {
        matchesType = resource['type'] == type;
      }

      bool matchesCategory = true;
      if (category != null && category != 'All') {
        matchesCategory = (resource['category'] as List<String>).contains(
          category,
        );
      }

      bool matchesSearchTerm = true;
      if (searchTerm != null && searchTerm.isNotEmpty) {
        matchesSearchTerm = resource['title'].toLowerCase().contains(
          searchTerm.toLowerCase(),
        );
      }
      return matchesType && matchesCategory && matchesSearchTerm;
    }).toList();

    return filteredResources;
  }

  // Modified to return a hardcoded featured video
  Future<Map<String, dynamic>?> _fetchFeaturedVideo() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate network delay
    return _hardcodedResources.firstWhere(
      (resource) =>
          resource['is_featured'] == true && resource['type'] == 'video',
      orElse: () => {}, // Return an empty map if no featured video is found
    );
  }

  void _applyFilters() {
    setState(() {
      _allResourcesFuture = _fetchResources(
        type: _selectedMediaType,
        category: _selectedFilter == 'All' ? null : _selectedFilter,
        searchTerm: _searchController.text.isEmpty
            ? null
            : _searchController.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0, // Total space for title + search bar
            floating: true,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            automaticallyImplyLeading:
                false, // Remove extra back button if needed
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(
                bottom: 80,
              ), // pushes title up
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Wellness Resources',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    'वेलनेस संसाधन',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              background: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search resources... (संसाधन खोजें...)',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  onSubmitted: (value) => _applyFilters(),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16.0,
                    40.0,
                    16.0,
                    8.0,
                  ), // top padding increased
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _availableCategories.map((category) {
                        return _buildFilterChip(category);
                      }).toList(),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Text(
                    'Featured Today',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                FutureBuilder<Map<String, dynamic>?>(
                  future: _featuredVideoFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data!.isNotEmpty) {
                      final featuredVideo = snapshot.data!;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoPlayerScreen(
                                youtubeUrl: featuredVideo['url'],
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: CachedNetworkImage(
                                    imageUrl: _getYouTubeThumbnail(
                                      featuredVideo['url'],
                                    ),
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                          Icons.videocam_off,
                                          size: 50,
                                        ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Featured Today',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      featuredVideo['title'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      featuredVideo['description'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  VideoPlayerScreen(
                                                    youtubeUrl:
                                                        featuredVideo['url'],
                                                  ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.play_arrow),
                                        label: const Text('Watch Now'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF5A8E3F,
                                          ),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
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
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
                const SizedBox(height: 20),
                TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF5A8E3F),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF5A8E3F),
                  tabs: const [
                    Tab(icon: Icon(Icons.article), text: 'Articles'),
                    Tab(icon: Icon(Icons.video_library), text: 'Videos'),
                    Tab(icon: Icon(Icons.headset), text: 'Audio'),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildResourceList(),
                      _buildResourceList(),
                      _buildResourceList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF5A8E3F).withOpacity(0.8),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
        ),
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? label : 'All';
            _applyFilters();
          });
        },
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildResourceList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _allResourcesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error loading resources: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No resources found.'));
        } else {
          final resources = snapshot.data!;
          return ListView.builder(
            itemCount: resources.length,
            itemBuilder: (context, index) {
              final resource = resources[index];
              return _buildResourceListItem(resource);
            },
          );
        }
      },
    );
  }

  Widget _buildResourceListItem(Map<String, dynamic> resource) {
    IconData icon;
    if (resource['type'] == 'article') {
      icon = Icons.article;
    } else if (resource['type'] == 'video') {
      icon = Icons.video_library;
    } else {
      icon = Icons.headset;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: (resource['type'] == 'video' && resource['url'] != null)
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  imageUrl: _getYouTubeThumbnail(resource['url']),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(icon, size: 40),
                ),
              )
            : Icon(icon, size: 40, color: const Color(0xFF5A8E3F)),
        title: Text(
          resource['title'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${resource['type']} • ${resource['language']} • ⭐ ${resource['rating'] ?? 'N/A'}',
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (resource['type'] == 'video' && resource['url'] != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    VideoPlayerScreen(youtubeUrl: resource['url']),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Opening ${resource['type']}: ${resource['title']}',
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
