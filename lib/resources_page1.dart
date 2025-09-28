import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'main.dart';
import 'video_player_screen.dart';

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

  // Available categories from your database
  final List<String> _availableCategories = [
    'All',
    'mental_health',
    'anxiety',
    'tips',
    'resilience',
    'grief',
    'stress',
    'awareness',
    'social',
    'positivity',
    'therapy',
    'work',
    'meditation',
    'self_help',
    'wellness',
    'youth',
    'breathing',
    'cognitive_therapy',
    'self_care',
    'sleep',
    'depression',
    'trauma',
    'education',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _tabController.addListener(_handleTabSelection);
    _featuredVideoFuture = _fetchFeaturedVideo();
    _allResourcesFuture = _fetchResources(type: _selectedMediaType);
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
        _allResourcesFuture = _fetchResources(
          type: _selectedMediaType,
          category: _selectedFilter == 'All' ? null : _selectedFilter,
          searchTerm: _searchController.text.isEmpty
              ? null
              : _searchController.text,
        );
      });
    }
  }

  String? _getYouTubeVideoId(String url) {
    if (url.isEmpty) return null;
    final regExp = RegExp(
      r'.*(?:youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=)([^#\&\?]*).*',
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

  Future<List<Map<String, dynamic>>> _fetchResources({
    String? type,
    String? category,
    String? searchTerm,
  }) async {
    try {
      var query = supabase.from('wellness_resources').select();

      // Apply type filter
      if (type != null && type != 'All') {
        query = query.eq('type', type);
      }

      // Apply category filter - FIXED: Proper array containment check
      if (category != null && category != 'All') {
        query = query.filter('category', 'cs', '{$category}');
      }

      // Apply search filter
      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.ilike('title', '%$searchTerm%');
      }

      final data = await query.order('created_at', ascending: false);
      print('Fetched ${data.length} resources'); // Debug log
      return (data as List).cast<Map<String, dynamic>>();
    } catch (error) {
      print('Error fetching resources: $error');
      return [];
    }
  }

  Future<Map<String, dynamic>?> _fetchFeaturedVideo() async {
    try {
      final data = await supabase
          .from('wellness_resources')
          .select()
          .eq('type', 'video')
          .eq('is_featured', true)
          .limit(1)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> result = (data as List)
          .cast<Map<String, dynamic>>();
      print('Featured video found: ${result.isNotEmpty}'); // Debug log
      return result.isNotEmpty ? result.first : null;
    } catch (error) {
      print('Error fetching featured video: $error');
      return null;
    }
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
            expandedHeight: 220.0,
            floating: true,
            pinned: true,
            snap: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 70),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Wellness Resources',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  const SizedBox(height: 4),
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
              preferredSize: const Size.fromHeight(100.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    TextField(
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
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Chips
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _availableCategories
                          .map((category) => _buildFilterChip(category))
                          .toList(),
                    ),
                  ),
                ),

                // Featured Section
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: Text(
                    'Featured Today',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // Featured Video Card
                FutureBuilder<Map<String, dynamic>?>(
                  future: _featuredVideoFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'Error loading featured content: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    } else if (snapshot.hasData && snapshot.data != null) {
                      final featuredVideo = snapshot.data!;
                      return _buildFeaturedCard(featuredVideo);
                    } else {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'No featured content available',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }
                  },
                ),

                const SizedBox(height: 24),

                // Tab Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF5A8E3F),
                    unselectedLabelColor: Colors.grey[600],
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    tabs: const [
                      Tab(icon: Icon(Icons.article), text: 'Articles'),
                      Tab(icon: Icon(Icons.video_library), text: 'Videos'),
                      Tab(icon: Icon(Icons.headset), text: 'Audio'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Resource List
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
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

  Widget _buildFeaturedCard(Map<String, dynamic> featuredVideo) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VideoPlayerScreen(youtubeUrl: featuredVideo['url']),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        shadowColor: Colors.black26,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: _getYouTubeThumbnail(featuredVideo['url']),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.videocam_off,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5A8E3F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Featured Today',
                      style: TextStyle(
                        color: Color(0xFF5A8E3F),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    featuredVideo['title'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    featuredVideo['description'] ?? 'No description available',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerScreen(
                              youtubeUrl: featuredVideo['url'],
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow, size: 20),
                      label: const Text('Watch Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5A8E3F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
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
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(
          label == 'mental_health'
              ? 'Mental Health'
              : label == 'self_help'
              ? 'Self Help'
              : label == 'cognitive_therapy'
              ? 'Cognitive Therapy'
              : label.replaceAll('_', ' ').titleCase(),
        ),
        selected: isSelected,
        selectedColor: const Color(0xFF5A8E3F),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error loading resources: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No resources found.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          );
        } else {
          final resources = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
    Color iconColor = const Color(0xFF5A8E3F);

    if (resource['type'] == 'article') {
      icon = Icons.article;
    } else if (resource['type'] == 'video') {
      icon = Icons.video_library;
    } else {
      icon = Icons.headset;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: (resource['type'] == 'video' && resource['url'] != null)
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  imageUrl: _getYouTubeThumbnail(resource['url']),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: Icon(icon, size: 30, color: iconColor),
                  ),
                ),
              )
            : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(icon, size: 30, color: iconColor),
              ),
        title: Text(
          resource['title'] ?? 'Untitled',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${resource['type']?.toString().toUpperCase() ?? 'Unknown'} • '
              '${resource['language'] ?? 'Unknown'} • '
              '⭐ ${resource['rating'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (resource['description'] != null) ...[
              const SizedBox(height: 4),
              Text(
                resource['description'],
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
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
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

// Extension for title case formatting
extension StringCasingExtension on String {
  String titleCase() {
    return toLowerCase()
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }
}
