import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'video_player_screen.dart';
import 'package:google_fonts/google_fonts.dart';

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
    'All', 'Anxiety', 'Sleep', 'CBT', 'Meditation', 'Study',
    'mental_health', 'tips', 'resilience', 'grief', 'stress',
    'awareness', 'social', 'positivity', 'therapy', 'work',
    'self_help', 'wellness', 'youth', 'breathing', 'cognitive_therapy',
    'self_care', 'depression', 'trauma', 'education',
    'motivation', 'mindfulness', 'productivity',
  ];

  final List<Map<String, dynamic>> _hardcodedResources = [
    {
      'id': '1', 'title': 'The Power of Vulnerability', 'description': 'Brené Brown studies human connection -- our ability to empathize, belong, love. In a poignant, funny talk, she shares a deep insight from her research, one that sent her on a personal quest to know herself as well as to understand humanity.', 'url': 'https://www.youtube.com/watch?v=iCvmsMzlF7o', 'type': 'video', 'category': ['mental_health', 'self_help'], 'language': 'English', 'rating': 4.9, 'is_featured': true,
    },
    {
      'id': '2', 'title': 'How to Practice Emotional First Aid', 'description': 'We\'ll go to the doctor when we feel physically ill, but what about when we feel emotionally ill -- loneliness, failure, rejection, heartbreak? Guy Winch makes a powerful case for practicing emotional hygiene.', 'url': 'https://www.youtube.com/watch?v=F2COP4yF_lM', 'type': 'video', 'category': ['mental_health', 'self_help'], 'language': 'English', 'rating': 4.8, 'is_featured': false,
    },
    {
      'id': '3', 'title': 'The Antidote to Stress', 'description': 'Stress is an inevitable part of modern life. Learn how to reframe your perception of stress to make it work for you, not against you.', 'url': 'https://www.youtube.com/watch?v=hnpC7W_z0rM', 'type': 'video', 'category': ['stress', 'mindfulness'], 'language': 'English', 'rating': 4.7, 'is_featured': false,
    },
    {
      'id': '5', 'title': '5-Minute Mindfulness Meditation', 'description': 'A quick guided meditation to bring calm and focus to your day.', 'url': 'https://www.youtube.com/watch?v=inpGa6JzK-U', 'type': 'audio', 'category': ['Meditation', 'mindfulness'], 'language': 'English', 'rating': 4.9, 'is_featured': false,
    },
    {
      'id': '7', 'title': '10 Tips for Managing Anxiety', 'description': 'Practical strategies to help you cope with feelings of anxiety in your daily life.', 'url': 'https://example.com/article-anxiety-tips', 'type': 'article', 'category': ['Anxiety', 'tips'], 'language': 'English', 'rating': 4.7, 'is_featured': false,
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
    if (_tabController.indexIsChanging || (!_tabController.indexIsChanging && _tabController.previousIndex != _tabController.index)) {
        final newType = ['article', 'video', 'audio'][_tabController.index];
        if (newType != _selectedMediaType) {
            setState(() {
                _selectedMediaType = newType;
                _applyFilters();
            });
        }
    }
  }

  String? _getYouTubeVideoId(String url) {
    if (url.isEmpty) return null;
    final regExp = RegExp(r'.*(?:youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=)([^#\&\?]*).*');
    final match = regExp.firstMatch(url);
    return (match != null && match.group(1) != null) ? match.group(1) : null;
  }

  String _getYouTubeThumbnail(String youtubeUrl) {
    final videoId = _getYouTubeVideoId(youtubeUrl);
    if (videoId != null) return 'https://img.youtube.com/vi/$videoId/0.jpg';
    return 'https://via.placeholder.com/150';
  }

  Future<List<Map<String, dynamic>>> _fetchResources({String? type, String? category, String? searchTerm}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _hardcodedResources.where((resource) {
      final bool matchesType = type == null || type == 'All' || resource['type'] == type;
      final bool matchesCategory = category == null || category == 'All' || (resource['category'] as List<dynamic>).cast<String>().contains(category);
      final bool matchesSearch = searchTerm == null || searchTerm.isEmpty || resource['title'].toLowerCase().contains(searchTerm.toLowerCase());
      return matchesType && matchesCategory && matchesSearch;
    }).toList();
  }

  Future<Map<String, dynamic>?> _fetchFeaturedVideo() async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _hardcodedResources.firstWhere((r) => r['is_featured'] == true && r['type'] == 'video');
    } catch (e) {
      return null;
    }
  }

  void _applyFilters() {
    setState(() {
      _allResourcesFuture = _fetchResources(
        type: _selectedMediaType,
        category: _selectedFilter == 'All' ? null : _selectedFilter,
        searchTerm: _searchController.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade50, Colors.deepPurple.shade50, Colors.white],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: Text(
                  'Wellness Resources',
                  style: GoogleFonts.quicksand(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                floating: true,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search resources...',
                        hintStyle: GoogleFonts.lato(color: Colors.grey.shade600),
                        prefixIcon: Icon(Icons.search, color: Colors.purple.shade200),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.purple.shade100)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.deepPurple.shade300, width: 2)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
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
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                      child: SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _availableCategories.map((c) => _buildFilterChip(c)).toList(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Text('Featured Today', style: GoogleFonts.quicksand(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ),
                    FutureBuilder<Map<String, dynamic>?>(
                      future: _featuredVideoFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                        if (!snapshot.hasData || snapshot.data == null) return const SizedBox.shrink();
                        return _buildFeaturedVideoCard(snapshot.data!);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.deepPurple.shade400,
                    unselectedLabelColor: Colors.grey.shade600,
                    indicatorColor: Colors.deepPurple.shade400,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
                    unselectedLabelStyle: GoogleFonts.quicksand(),
                    tabs: const [
                      Tab(icon: Icon(Icons.article_outlined), text: 'Articles'),
                      Tab(icon: Icon(Icons.video_library_outlined), text: 'Videos'),
                      Tab(icon: Icon(Icons.headset_outlined), text: 'Audio'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildResourceList(), // Articles
              _buildResourceList(), // Videos
              _buildResourceList(), // Audios
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ActionChip(
        label: Text(label, style: GoogleFonts.lato(color: isSelected ? Colors.white : Colors.deepPurple.shade800)),
        onPressed: () {
          setState(() {
            _selectedFilter = label;
            _applyFilters();
          });
        },
        backgroundColor: isSelected ? Colors.deepPurple.shade400 : Colors.white.withOpacity(0.8),
        side: isSelected ? BorderSide.none : BorderSide(color: Colors.purple.shade100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: isSelected ? 3 : 0,
        shadowColor: isSelected ? Colors.deepPurple.withOpacity(0.2) : Colors.transparent,
      ),
    );
  }

  Widget _buildFeaturedVideoCard(Map<String, dynamic> video) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(youtubeUrl: video['url'])));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 6,
        shadowColor: Colors.purple.withOpacity(0.15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: _getYouTubeThumbnail(video['url']),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.videocam_off, size: 50, color: Colors.red),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Featured Today', style: GoogleFonts.lato(color: Colors.deepPurple.shade400, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(video['title'], style: GoogleFonts.quicksand(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(video['description'], style: GoogleFonts.lato(fontSize: 14, color: Colors.black54), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(youtubeUrl: video['url'])));
                      },
                      icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                      label: Text('Watch Now', style: GoogleFonts.quicksand(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade400,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

  Widget _buildResourceList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _allResourcesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading resources: ${snapshot.error}', style: GoogleFonts.lato(color: Colors.black54)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No resources found.', style: GoogleFonts.lato(color: Colors.black54)));
        } else {
          final resources = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
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
    Color iconColor;
    if (resource['type'] == 'article') {
      icon = Icons.article_outlined;
      iconColor = Colors.teal.shade400;
    } else if (resource['type'] == 'video') {
      icon = Icons.video_library_outlined;
      iconColor = Colors.deepPurple.shade400;
    } else { // audio
      icon = Icons.headset_outlined;
      iconColor = Colors.pink.shade400;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shadowColor: Colors.purple.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          if ((resource['type'] == 'video' || resource['type'] == 'audio') && resource['url'] != null) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerScreen(youtubeUrl: resource['url'])));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening ${resource['type']}: ${resource['title']}')));
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: (resource['type'] == 'video' && resource['url'] != null)
                    ? CachedNetworkImage(
                        imageUrl: _getYouTubeThumbnail(resource['url']),
                        width: 70, height: 70, fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        errorWidget: (context, url, error) => Container(width: 70, height: 70, color: Colors.grey.shade200, child: Icon(Icons.videocam_off, size: 30, color: Colors.grey.shade500)),
                      )
                    : Container(width: 70, height: 70, color: iconColor.withOpacity(0.1), child: Icon(icon, size: 40, color: iconColor)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(resource['title'], style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text('${resource['description'] ?? 'No description available.'}', style: GoogleFonts.lato(fontSize: 13, color: Colors.black54), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0, runSpacing: 4.0,
                      children: [
                        if (resource['type'] != null) Chip(label: Text(resource['type'].toString(), style: GoogleFonts.lato(fontSize: 11, color: Colors.white)), backgroundColor: iconColor, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        if (resource['rating'] != null) Chip(label: Text('⭐ ${resource['rating']}', style: GoogleFonts.lato(fontSize: 11, color: Colors.amber.shade900)), backgroundColor: Colors.amber.shade100, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}