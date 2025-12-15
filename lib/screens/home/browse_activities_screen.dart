import 'package:flutter/material.dart';
import '../service/theme.dart';
import '../service/api_service.dart';
import 'activity_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BrowseActivitiesScreen extends StatefulWidget {
  const BrowseActivitiesScreen({super.key});

  @override
  State<BrowseActivitiesScreen> createState() =>
      _BrowseActivitiesScreenState();
}

class _BrowseActivitiesScreenState
    extends State<BrowseActivitiesScreen> {

  late Future<List<Map<String, dynamic>>> _activitiesFuture;

  List<Map<String, dynamic>> _recommendations = [];
  bool _loadingRecommendations = true;

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allActivities = [];
  List<Map<String, dynamic>> _filteredActivities = [];

  @override
  void initState() {
    super.initState();

    _activitiesFuture = ApiService.getAllActivities();
    _loadAllChildrenRecommendations();

    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadAllChildrenRecommendations() async {
    try {
      setState(() => _loadingRecommendations = true);

      final prefs = await SharedPreferences.getInstance();
      final parentId = prefs.getString("parent_id");

      if (parentId == null) {
        setState(() => _loadingRecommendations = false);
        return;
      }

      final children =
          await ApiService.getChildrenByParent(parentId);

      List<Map<String, dynamic>> allRecs = [];

      for (final child in children) {
        final childId = child["child_id"];
        final childName = child["first_name"];

        final recs =
            await ApiService.getInitialRecommendations(childId);

        for (final r in recs) {
          r["recommended_for_child"] = childName;
          r["recommended_for_child_id"] = childId;
        }

        allRecs.addAll(recs);
      }

      final uniqueMap = <String, Map<String, dynamic>>{};
      for (var r in allRecs) {
        uniqueMap[r["activity_id"]] = r;
      }

      setState(() {
        _recommendations = uniqueMap.values.toList();
        _loadingRecommendations = false;
      });
    } catch (e) {
      _loadingRecommendations = false;
      debugPrint("❌ Failed to load recommendations: $e");
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredActivities = List.from(_allActivities);
      } else {
        _filteredActivities = _allActivities.where((a) {
          final title =
              (a["title"] ?? "").toString().toLowerCase();
          final description =
              (a["description"] ?? "").toString().toLowerCase();
          return title.contains(query) ||
              description.contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: const Text(
            "Browse Activities",
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),

        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _activitiesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  "Failed to load activities",
                  style:
                      TextStyle(fontFamily: 'RobotoMono'),
                ),
              );
            }

            if (snapshot.hasData && _allActivities.isEmpty) {
              _allActivities = snapshot.data!;
              _filteredActivities =
                  List.from(_allActivities);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  // ================= Search Box =================
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search activities...",
                      prefixIcon:
                          const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ================= Recommendation Box =================
                  Container(
                    padding:
                        const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary
                              .withOpacity(0.15),
                          Colors.white
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary
                            .withOpacity(0.2),
                      ),
                    ),
                    child: const Text(
                      "These are our best recommendations for your child",
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ================= Recommended (Horizontal) =================
                  SizedBox(
                    height: 190,
                    child: _loadingRecommendations
                        ? const Center(
                            child:
                                CircularProgressIndicator())
                        : _recommendations.isEmpty
                            ? const Center(
                                child: Text(
                                    "No recommendations yet"))
                            : ListView.separated(
                                scrollDirection:
                                    Axis.horizontal,
                                itemCount:
                                    _recommendations
                                        .length,
                                separatorBuilder:
                                    (_, __) =>
                                        const SizedBox(
                                            width: 12),
                                itemBuilder:
                                    (context, index) {
                                  final a =
                                      _recommendations[
                                          index];
                                  return
                                      _recommendedCard(
                                          a);
                                },
                              ),
                  ),

                  const SizedBox(height: 16),

                  // ================= All Activities Header =================
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "All Activities",
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                            Icons.filter_list),
                      )
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ================= All Activities (Vertical) =================
                  ListView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount:
                        _filteredActivities.length,
                    itemBuilder:
                        (context, index) {
                      final a =
                          _filteredActivities[index];
                      return _activityCard(a);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ================= Recommended Card =================
  Widget _recommendedCard(Map<String, dynamic> a) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ActivityDetailsPage(activity: a),
          ),
        );
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary
                  .withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Icon(Icons.local_activity,
                color: AppColors.primary,
                size: 36),
            const SizedBox(height: 10),
            Text(
              a["title"] ?? "Activity",
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            if (a["recommended_for_child"] !=
                null)
              Text(
                "For ${a["recommended_for_child"]}",
                style: const TextStyle(
                  fontFamily:
                      'RobotoMono',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            const Spacer(),
            Text(
              "${a["price"] ?? 0} SAR",
              style: const TextStyle(
                fontFamily:
                    'RobotoMono',
                color:
                    AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= Normal Activity Card =================
  Widget _activityCard(Map<String, dynamic> a) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ActivityDetailsPage(activity: a),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin:
            const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary
                  .withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.local_activity,
                color: AppColors.primary,
                size: 34),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    a["title"] ??
                        "Activity",
                    style: const TextStyle(
                      fontFamily:
                          'RobotoMono',
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    a["description"] ?? "",
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily:
                          'RobotoMono',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "${a["price"] ?? 0} SAR",
              style: const TextStyle(
                fontFamily:
                    'RobotoMono',
                color:
                    AppColors.primary,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
