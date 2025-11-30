import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://saifi-backend-pmbz.onrender.com";

  // =========================
  // ✅ Register Parent
  // =========================
  static Future<Map<String, dynamic>> registerParent({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/parents/register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "phone": phone,
        "password": password,
      }),
    );

    // ✅ تحقق قبل فك JSON
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      print("Parent Register Error: ${response.body}");
      throw Exception("Failed to register parent: ${response.statusCode}");
    }
  }

  // =========================
  // ✅ Login Parent
  // =========================
  static Future<Map<String, dynamic>> loginParent({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/parents/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return jsonDecode(response.body);
  }

  // =========================
  // ✅ Create Booking
  // =========================
  static Future<Map<String, dynamic>> createBooking({
    required String parentId,
    required String childId,
    required String activityId,
    required String providerId, // 👈 مهم حسب جدول bookings
  }) async {
    final url = Uri.parse("$baseUrl/bookings/create");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "parent_id": parentId,
        "child_id": childId,
        "activity_id": activityId,
        "provider_id": providerId,
      }),
    );

    return jsonDecode(response.body);
  }

  // ✅ Get Children By Parent
  static Future<List<Map<String, dynamic>>> getChildrenByParent(
    String parentId,
  ) async {
    final url = Uri.parse("$baseUrl/children/by-parent/$parentId");

    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load children");
    }

    final List data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  // ✅ Get Provider By ID
  static Future<Map<String, dynamic>> getProviderById(String providerId) async {
    final url = Uri.parse("$baseUrl/providers/$providerId");

    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load provider");
    }

    return jsonDecode(response.body);
  }

  // ✅ Create Activity
  static Future<Map<String, dynamic>> createActivity(
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse("$baseUrl/activities/create");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to create activity");
    }

    return jsonDecode(response.body);
  }

  // =========================
  // ✅ Get Parent Bookings
  // =========================
  static Future<List<Map<String, dynamic>>> getParentBookings(
    String parentId,
  ) async {
    final url = Uri.parse("$baseUrl/bookings/parent/$parentId");

    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return List<Map<String, dynamic>>.from(decoded);
    } else {
      return [];
    }
  }

  // =========================
  // ✅ Create Child
  // =========================
  static Future<Map<String, dynamic>> createChild(
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse("$baseUrl/children/create");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to create child");
    }

    return jsonDecode(response.body);
  }

  // =========================
  // ✅ Register Provider
  // =========================
  static Future<Map<String, dynamic>> registerProvider(
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse("$baseUrl/providers/register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      print("Provider Register Error: ${response.body}");
      throw Exception("Failed to register provider: ${response.statusCode}");
    }
  }

  // =========================
  // ✅ Get Parent By ID
  // =========================
  static Future<Map<String, dynamic>> getParentById(String parentId) async {
    final url = Uri.parse("$baseUrl/parents/$parentId");

    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load parent");
    }

    return jsonDecode(response.body);
  }

  // =========================
  // ✅ Update Parent
  // =========================
  static Future<void> updateParent({
    required String parentId,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    
    final url = Uri.parse("$baseUrl/parents/$parentId");

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "first_name": firstName,
        "last_name": lastName,
        "phone": phone,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update parent");
    }
  }

  // =========================
  // ✅ Get All Activities
  // =========================
  static Future<List<Map<String, dynamic>>> getAllActivities() async {
  final url = Uri.parse("$baseUrl/activities");

  final response = await http.get(
    url,
    headers: {"Content-Type": "application/json"},
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to load activities");
  }

  final decoded = jsonDecode(response.body);
  final List data = decoded["data"];

  return data.cast<Map<String, dynamic>>();
}


  // ✅ Update Parent Location
  static Future<void> updateParentLocation({
    required String parentId,
    required double lat,
    required double lng,
  }) async {
    final url = Uri.parse("$baseUrl/parents/update-location");

    await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "parent_id": parentId,
        "location_lat": lat,
        "location_lng": lng,
      }),
    );
  }

  // =========================
  // ✅ Update Parent Password
  // =========================
  static Future<Map<String, dynamic>> updateParentPassword({
    required String parentId,
    required String newPassword,
  }) async {
    final url = Uri.parse("$baseUrl/parents/update-password");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"parent_id": parentId, "new_password": newPassword}),
    );

    return jsonDecode(response.body);
  }
}
