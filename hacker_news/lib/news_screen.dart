import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'news_provider.dart';
import 'news_details.dart';
import 'model/story_type.dart';
import 'model/story.dart';
import 'database_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final NewsProvider _newsProvider = NewsProvider();
  final DatabaseService _databaseService = DatabaseService();
  final ScrollController _scrollController = ScrollController();

  List<int> _allStoryIds = [];
  List<Story> _stories = [];
  bool _isLoadingIds = true;
  bool _isLoadingMore = false;
  bool _hasMoreStories = true;
  String? _error;

  StoryType _currentStoryType = StoryType.top;
  int _selectedNavIndex = 0;
  static const int _batchSize = 20;

  @override
  void initState() {
    super.initState();
    _loadStories();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreStories) {
      _loadMoreStories();
    }
  }

  Future<void> _loadStories() async {
    try {
      setState(() {
        _isLoadingIds = true;
        _error = null;
        _stories.clear();
        _hasMoreStories = true;
      });

      // First check if we have cached story IDs
      final cachedIds = await _databaseService.getCachedStoryIds(_currentStoryType);
      List<int> storyIds;

      if (cachedIds != null) {
        storyIds = cachedIds;
        setState(() {
          _allStoryIds = storyIds;
          _isLoadingIds = false;
        });
      } else {
        // Fetch from API if not cached
        storyIds = await _newsProvider.fetchStoryIds(_currentStoryType);
        setState(() {
          _allStoryIds = storyIds;
          _isLoadingIds = false;
        });
      }

      await _loadMoreStories();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingIds = false;
      });
    }
  }

  Future<void> _loadMoreStories() async {
    if (_isLoadingMore || !_hasMoreStories) return;

    try {
      setState(() {
        _isLoadingMore = true;
      });

      final startIndex = _stories.length;
      final endIndex = (startIndex + _batchSize).clamp(0, _allStoryIds.length);
      final batchIds = _allStoryIds.sublist(startIndex, endIndex);

      if (batchIds.isEmpty) {
        setState(() {
          _hasMoreStories = false;
          _isLoadingMore = false;
        });
        return;
      }

      // First try to get stories from cache
      final cachedStories = await _databaseService.getCachedStories(batchIds);
      List<Story> newStories = List.from(cachedStories);

      // Find which stories are missing from cache
      final cachedIds = cachedStories.map((story) => story.id).toSet();
      final missingIds = batchIds.where((id) => !cachedIds.contains(id)).toList();

      // Fetch missing stories from API
      if (missingIds.isNotEmpty) {
        try {
          final fetchedStories = await _newsProvider.fetchStories(missingIds);
          newStories.addAll(fetchedStories);

          // Save fetched stories to database
          await _databaseService.saveStories(fetchedStories);
        } catch (e) {
          debugPrint('Failed to fetch some stories: $e');
          // Continue with cached stories only
        }
      }

      // Sort stories by their order in the original list
      newStories.sort((a, b) {
        final aIndex = batchIds.indexOf(a.id);
        final bIndex = batchIds.indexOf(b.id);
        return aIndex.compareTo(bIndex);
      });

      setState(() {
        _stories.addAll(newStories);
        _isLoadingMore = false;
        _hasMoreStories = _stories.length < _allStoryIds.length;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _error = e.toString();
      });
    }
  }

  void _onNavItemTapped(int index) {
    final storyTypes = [StoryType.top, StoryType.best, StoryType.newStories];
    if (index != _selectedNavIndex) {
      setState(() {
        _selectedNavIndex = index;
        _currentStoryType = storyTypes[index];
      });
      _loadStories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.newspaper,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _currentStoryType.displayName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadStories,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedNavIndex,
          onTap: _onNavItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up_rounded),
              label: 'Top',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_rounded),
              label: 'Best',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fiber_new_rounded),
              label: 'New',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingIds) {
      return _buildShimmerLoading();
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Color(0xFFE74C3C),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF7F8C8D),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadStories,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_stories.isEmpty && !_isLoadingMore) {
      return const Center(
        child: Text('No stories found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStories,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _stories.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _stories.length) {
            return _buildShimmerLoadingItem();
          }

          final story = _stories[index];
          final globalIndex = index + 1;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              borderRadius: BorderRadius.circular(16),
              elevation: 0,
              color: Colors.white,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetails(storyId: story.id),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '$globalIndex',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Color(0xFF2C3E50),
                                height: 1.3,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildInfoChip(
                                  Icons.person_outline_rounded,
                                  story.by,
                                  const Color(0xFF3498DB),
                                ),
                                const SizedBox(width: 12),
                                _buildInfoChip(
                                  Icons.arrow_upward_rounded,
                                  '${story.score}',
                                  const Color(0xFFFF6B35),
                                ),
                                const SizedBox(width: 12),
                                _buildInfoChip(
                                  Icons.comment_outlined,
                                  '${story.kids.length}',
                                  const Color(0xFF9B59B6),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Color(0xFFBDC3C7),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF7F8C8D),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: List.generate(10, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            height: 12,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            height: 12,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildShimmerLoadingItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
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
}
