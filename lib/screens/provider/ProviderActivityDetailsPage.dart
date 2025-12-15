import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/theme.dart';
import '../service/api_service.dart';

class ProviderActivityDetailsPage extends StatefulWidget {
  final String? activityId; // ✅ يقبل null

  const ProviderActivityDetailsPage({
    super.key,
    this.activityId,
  });

  @override
  State<ProviderActivityDetailsPage> createState() =>
      _ProviderActivityDetailsPageState();
}

class _ProviderActivityDetailsPageState
    extends State<ProviderActivityDetailsPage> {
  String? loggedProviderId;
  Map<String, dynamic>? activityData;
  List<Map<String, dynamic>> providerActivities = [];

  bool isLoading = true;
  String? errorMessage;
  bool showList = false;

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    final prefs = await SharedPreferences.getInstance();
    loggedProviderId = prefs.getString("provider_id");

    if (loggedProviderId == null) {
      setState(() {
        errorMessage = "Provider not logged in";
        isLoading = false;
      });
      return;
    }

    try {
      // ✅ لو فيه ID → تفاصيل نشاط واحد
      if (widget.activityId != null && widget.activityId!.trim().isNotEmpty) {
        final data = await ApiService.getActivityById(widget.activityId!);
        print("API provider_id: ${data["provider_id"]}");
        print("Logged provider_id: $loggedProviderId");
        if (data["provider_id"] != loggedProviderId) {
          throw Exception("Unauthorized activity access");
        }

        setState(() {
          activityData = data;
          showList = false;
          isLoading = false;
        });
        return;
      }
      providerActivities.clear();
      // ✅ لو ما فيه ID → كل أنشطة البروفايدر
      final activities =
          await ApiService.getProviderActivities(loggedProviderId!);
          print("Activities type: ${activities.runtimeType}");
          print("Activities value: $activities");

      if (activities.isEmpty) {
        setState(() {
          providerActivities = [];
          showList = true;
          isLoading = false;
          errorMessage = null;
        });
        return;
      }

      setState(() {
        providerActivities = activities;
        showList = true;
        isLoading = false;
      });
    }  catch (e) {
  print("ERROR 👉 $e");
  setState(() {
    errorMessage = e.toString();
    isLoading = false;
  });
}

  }

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text(
            "Provider Activities",
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 2,
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : errorMessage != null
                ? Center(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : showList
                    ? _buildActivitiesList()
                    : _buildActivityContent(),
      ),
    );
  }

  // ==========================
  // ✅ قائمة كل أنشطة البروفايدر
  // ==========================
  Widget _buildActivitiesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: providerActivities.length,
      itemBuilder: (context, index) {
        final a = providerActivities[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary),
          ),
          child: ListTile(
            title: Text(
              a["title"] ?? "",
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text("${a["price"]} SAR"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ProviderActivityDetailsPage(
                    activityId: a["activity_id"],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ==========================
  // ✅ تفاصيل نشاط واحد (كما عندك)
  // ==========================
  Widget _buildActivityContent() {
    final a = activityData!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _info("Title", a["title"]),
            _info("Description", a["description"]),
            _info("Type", a["type"]),
            _info("Price", "${a["price"]} SAR"),
            _info("Capacity", "${a["capacity"]}"),
            _info("Duration", "${a["duration"]} hours"),
            _info("Age Range", "${a["age_from"]} - ${a["age_to"]}"),
            _info("Gender", a["gender"]),
            _info("Start Date", a["start_date"]?.toString() ?? "-"),
            _info("End Date", a["end_date"]?.toString() ?? "-"),
            _info("Status", a["status"] == true ? "Active" : "Inactive"),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () async {
                await _showEditDialog(a);
              },
              child: const Text(
                "Edit Activity",
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Delete Activity"),
                    content: const Text(
                        "Are you sure you want to delete this activity?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  try {
                    await ApiService.deleteActivity(a["activity_id"]);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProviderActivityDetailsPage(),
                      ),
                    );
                    // يرجع لقائمة الأنشطة

                    // ✅ إعادة تحميل القائمة بدون تكرار
                    setState(() {
                      providerActivities.clear();
                      activityData = null;
                      showList = true;
                      isLoading = true;
                    });

                    await _initPage();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Activity deleted successfully"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Failed to delete activity"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                "Delete Activity",
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? "-",
            style: const TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================
  // ✅ نافذة التعديل عندك كما هي
   // ==========================
Future<void> _showEditDialog(Map<String, dynamic> a) async {
  final titleController = TextEditingController(text: a["title"]);
  final descController = TextEditingController(text: a["description"]);
  final typeController = TextEditingController(text: a["type"]);
  final priceController = TextEditingController(text: a["price"]?.toString());
  final capacityController =
      TextEditingController(text: a["capacity"]?.toString());
  final durationController =
      TextEditingController(text: a["duration"]?.toString());
  final ageFromController =
      TextEditingController(text: a["age_from"]?.toString());
  final ageToController =
      TextEditingController(text: a["age_to"]?.toString());

  String gender = a["gender"] ?? "male"; // ✅ بدون both
  bool statusValue = a["status"] == true;

  bool showBasic = false;
  bool showAge = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => StatefulBuilder(
      builder: (context, setLocalState) {
        Widget box({
          required String title,
          required Widget child,
          VoidCallback? onTap,
          bool show = true,
        }) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.grey),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: onTap,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                      if (onTap != null)
                        const Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
                if (onTap == null) child,
                if (onTap != null && show)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: child,
                  ),
              ],
            ),
          );
        }

        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 600),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      "Edit Activity",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // ✅ Basic Info Dropdown
                    box(
                      title: "Basic Info",
                      onTap: () =>
                          setLocalState(() => showBasic = !showBasic),
                      show: showBasic,
                      child: Column(
                        children: [
                          TextField(
                            controller: titleController,
                            decoration:
                                const InputDecoration(labelText: "Title"),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: descController,
                            decoration:
                                const InputDecoration(labelText: "Description"),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: typeController,
                            decoration:
                                const InputDecoration(labelText: "Type"),
                          ),
                        ],
                      ),
                    ),

                    // ✅ Gender (NO BOTH ❌)
                    box(
                      title: "Gender",
                      child: Column(
                        children: [
                          RadioListTile(
                            value: "male",
                            groupValue: gender,
                            title: const Text("Male"),
                            onChanged: (v) =>
                                setLocalState(() => gender = v!),
                          ),
                          RadioListTile(
                            value: "female",
                            groupValue: gender,
                            title: const Text("Female"),
                            onChanged: (v) =>
                                setLocalState(() => gender = v!),
                          ),
                        ],
                      ),
                    ),

                    // ✅ Pricing & Capacity
                    box(
                      title: "Pricing",
                      child: Column(
                        children: [
                          TextField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: "Price"),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: capacityController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: "Capacity"),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: durationController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: "Duration (hours)"),
                          ),
                        ],
                      ),
                    ),

                    // ✅ Age Range Dropdown
                    box(
                      title: "Age Range",
                      onTap: () =>
                          setLocalState(() => showAge = !showAge),
                      show: showAge,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ageFromController,
                              keyboardType: TextInputType.number,
                              decoration:
                                  const InputDecoration(labelText: "Min Age"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: ageToController,
                              keyboardType: TextInputType.number,
                              decoration:
                                  const InputDecoration(labelText: "Max Age"),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ✅ Status
                    box(
                      title: "Status",
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Active"),
                          Switch(
                            value: statusValue,
                            onChanged: (val) {
                              setLocalState(() {
                                statusValue = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        icon: const Icon(Icons.save),
                        label: const Text("Save"),
                        onPressed: () async {
                          try {
                            await ApiService.updateActivity(
                              activityId: a["activity_id"],
                              data: {
                                "title": titleController.text.trim(),
                                "description": descController.text.trim(),
                                "type": typeController.text.trim(),
                                "gender": gender,
                                "price": double.parse(
                                    priceController.text.trim()),
                                "capacity": int.parse(
                                    capacityController.text.trim()),
                                "duration": int.parse(
                                    durationController.text.trim()),
                                "age_from": int.parse(
                                    ageFromController.text.trim()),
                                "age_to": int.parse(
                                    ageToController.text.trim()),
                                "status": statusValue,
                              },
                            );

                            Navigator.pop(context);
                            await _initPage();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("Activity updated successfully"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Failed to update activity"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
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

  }
