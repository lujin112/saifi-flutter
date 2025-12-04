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

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to register parent: ${response.body}");
    }
  }

  // =========================
  // ✅ Login Parent
  // =========================
static Future<Map<String, dynamic>> loginParent({
  String? email,
  String? phone,
  required String password,
}) async {
  final url = Uri.parse("$baseUrl/parents/login");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "phone": phone,
      "password": password,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception("Login failed: ${response.body}");
  }

  final decoded = jsonDecode(response.body);

  // ✅ لو داخل data
  Map<String, dynamic> parent;
  if (decoded is Map && decoded["data"] != null) {
    parent = Map<String, dynamic>.from(decoded["data"]);
  }
  // ✅ لو راجع مباشر
  else if (decoded is Map) {
    parent = Map<String, dynamic>.from(decoded);
  } else {
    throw Exception("Invalid login response format");
  }

  // ✅ حفظ الجلسة محليًا (هذا اللي كان ناقصك)
  // ملاحظة: هذه الأسطر لازم توضع في صفحة الـ UI لو ما تبين ApiService يلمس SharedPreferences
  parent["_save_session"] = true;

  return parent;
}


  // =========================
  // ✅ Login Provider
  // =========================
static Future<Map<String, dynamic>> loginProvider({
  String? email,
  String? phone,
  required String password,
}) async {
  final url = Uri.parse("$baseUrl/providers/login");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "phone": phone,
      "password": password,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception("Provider login failed: ${response.body}");
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

  print("STATUS CODE: ${response.statusCode}");
  print("RESPONSE BODY: ${response.body}");

  if (response.statusCode == 200 || response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to register provider: ${response.body}");
  }
}


  // =========================
  // ✅ Create Activity
  // =========================
static Future<Map<String, dynamic>> createActivity(
  Map<String, dynamic> data,
) async {
  final url = Uri.parse("$baseUrl/activities/create");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(data),
  );

  print("CREATE STATUS: ${response.statusCode}");
  print("CREATE BODY: ${response.body}");

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception("Failed to create activity: ${response.body}");
  }

  return jsonDecode(response.body); // ✅ يرجع activity_id فقط
}


  // =========================
  // ✅ Get All Activities
  // =========================
  static Future<List<Map<String, dynamic>>> getAllActivities() async {
    final url = Uri.parse("$baseUrl/activities");

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to load activities");
    }

    final decoded = jsonDecode(response.body);
    final List data = decoded["data"];
    return data.cast<Map<String, dynamic>>();
  }

  // =========================
  // ✅ Create Booking
  // =========================
  static Future<Map<String, dynamic>> createBooking({
    required String parentId,
    required String childId,
    required String activityId,
    required String providerId,
    required String status,
    required String bookingDate,
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
        "status": status,
        "booking_date": bookingDate,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Create booking failed: ${response.body}");
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

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to load bookings");
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    } else {
      return [];
    }
  }

// =========================
// ✅ Create Child (TRULY FIXED ✅)
// =========================
static Future<Map<String, dynamic>> createChild({
  required String parentId,
  required String firstName,
  required String lastName,
  required String gender,
  required String birthday,   // ✅ الاسم الصحيح
  required int age,
  String? notes,
}) async {
  final url = Uri.parse("$baseUrl/children/create");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "parent_id": parentId,
      "first_name": firstName,
      "last_name": lastName,
      "gender": gender,
     "birthdate": birthday,
      "age": age,
      "notes": notes,
    }),
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception("Create child failed: ${response.body}");
  }

  return jsonDecode(response.body);
}



  // =========================
  // ✅ Get Children By Parent
  // =========================
  static Future<List<Map<String, dynamic>>> getChildrenByParent(
    String parentId,
  ) async {
    final url = Uri.parse("$baseUrl/children/by-parent/$parentId");

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to load children");
    }

    final List data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  // =========================
  // ✅ Get Provider By ID
  // =========================
static Future<Map<String, dynamic>> getProviderById(
    String providerId,
) async {
  final res = await http.get(
    Uri.parse("$baseUrl/providers/$providerId"),
  );

  print("GET PROVIDER STATUS: ${res.statusCode}");
  print("GET PROVIDER BODY: ${res.body}");

  if (res.statusCode != 200) {
    throw Exception("Failed to fetch provider: ${res.body}");
  }

  final decoded = jsonDecode(res.body);

  // ✅ لو راجع مباشر
  if (decoded is Map<String, dynamic> &&
      decoded.containsKey("provider_id")) {
    return decoded;
  }

  // ✅ لو داخل data
  if (decoded is Map &&
      decoded["data"] != null &&
      decoded["data"] is Map) {
    return Map<String, dynamic>.from(decoded["data"]);
  }

  throw Exception("Invalid provider response format");
}




  // =========================
  // ✅ Get Parent By ID
  // =========================
static Future<Map<String, dynamic>> getParentById(String parentId) async {
  final url = Uri.parse("$baseUrl/parents/$parentId");

  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception("Failed to load parent: ${response.body}");
  }

  final decoded = jsonDecode(response.body);

  // ✅ لو داخل data
  if (decoded is Map && decoded["data"] != null) {
    return Map<String, dynamic>.from(decoded["data"]);
  }

  // ✅ لو راجع مباشر
  if (decoded is Map) {
    return Map<String, dynamic>.from(decoded);
  }

  // ✅ لو راجع List (أسوأ سيناريو)
  if (decoded is List && decoded.isNotEmpty) {
    return Map<String, dynamic>.from(decoded.first);
  }

  throw Exception("Invalid parent response format");
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
  // ✅ Update Parent Location
  // =========================
    static Future<void> updateParentLocation({
      required String parentId,
      required double lat,
      required double lng,
    }) async {
      final url = Uri.parse("$baseUrl/parents/update-location");

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "parent_id": parentId,
          "location_lat": lat,
          "location_lng": lng,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to update location");
      }
    }
// =========================
// ✅ Get Provider Activities
// =========================
static Future<List<Map<String, dynamic>>> getProviderActivities(
  String providerId,
) async {
  final url = Uri.parse("$baseUrl/activities/by-provider/$providerId");

  final response = await http.get(
    url,
    headers: {"Content-Type": "application/json"},
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to load provider activities");
  }

  final List data = jsonDecode(response.body);
  return data.cast<Map<String, dynamic>>();
}
// =========================
// ✅ Get Bookings By Activity (Provider)
// =========================
static Future<List<Map<String, dynamic>>> getBookingsByActivity({
  required String activityId,
}) async {
  final url = Uri.parse("$baseUrl/bookings/by-activity/$activityId");

  final response = await http.get(
    url,
    headers: {"Content-Type": "application/json"},
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to load bookings");
  }

  final decoded = jsonDecode(response.body);

  // لو الباك يرجع List مباشرة
  if (decoded is List) {
    return List<Map<String, dynamic>>.from(decoded);
  }

  // لو ملفوفة داخل data
  if (decoded["data"] != null) {
    return List<Map<String, dynamic>>.from(decoded["data"]);
  }

  return [];
}
// =========================
// ✅ Update Provider
// =========================
static Future<void> updateProvider({
  required String providerId,
  required Map<String, dynamic> data,
}) async {
  final url = Uri.parse("$baseUrl/providers/$providerId");

  final response = await http.put(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(data),
  );

  print("UPDATE STATUS: ${response.statusCode}");
  print("UPDATE BODY: ${response.body}");

  if (response.statusCode != 200) {
    throw Exception("Failed to update provider");
  }
}


// =========================
// ✅ Update Booking Status
// =========================
static Future<void> updateBookingStatus({
  required String bookingId,
  required String status,
}) async {
  final url = Uri.parse("$baseUrl/bookings/update-status");

  final response = await http.put(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "booking_id": bookingId,
      "status": status,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to update booking status");
  }
}
static Future<Map<String, dynamic>> getActivityById(String activityId) async {
  final url = Uri.parse("$baseUrl/activities/$activityId");

  print("🔵 FETCH ACTIVITY URL: $url");

  final response = await http.get(url);

  print("🔵 ACTIVITY STATUS: ${response.statusCode}");
  print("🔵 ACTIVITY BODY: ${response.body}");

  if (response.statusCode != 200) {
    throw Exception("Failed to load activity");
  }

  final decoded = jsonDecode(response.body);

  // ✅ لو الباك يرجّع داخل data
  if (decoded is Map && decoded["data"] != null) {
    return Map<String, dynamic>.from(decoded["data"]);
  }

  // ✅ لو يرجّع مباشر
  if (decoded is Map) {
    return Map<String, dynamic>.from(decoded);
  }

  throw Exception("Invalid activity response format");
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
      body: jsonEncode({
        "parent_id": parentId,
        "new_password": newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update password");
    }

    return jsonDecode(response.body);
  }
}
