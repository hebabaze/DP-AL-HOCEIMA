import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:crypto/crypto.dart';
class GoogleSheetsService {
  static final GoogleSheetsService _instance = GoogleSheetsService._privateConstructor();
  static const _scopes = [
    sheets.SheetsApi.spreadsheetsReadonlyScope, // Read-only access to sheets
    'https://www.googleapis.com/auth/drive.readonly', // Read-only access to Drive
  ];

  final String spreadsheetId = "1BOi13OBrITCVjbHY5osOJFZs4lp0gMVYQCFdRWzrpHY";
  late sheets.SheetsApi _sheetsApi;
  final Map<String, List<Map<String, dynamic>>> _cache = {};
  bool _isInitialized = false;

  GoogleSheetsService._privateConstructor();

  factory GoogleSheetsService() {
    return _instance;
  }

Future<void> _initialize({int maxRetries = 3, Duration delay = const Duration(seconds: 2)}) async {
  int retryCount = 0;

  while (retryCount < maxRetries) {
    try {
      final credentials = await _loadServiceAccountCredentials();
      final client = await clientViaServiceAccount(credentials, _scopes);
      _sheetsApi = sheets.SheetsApi(client);
      _isInitialized = true;
      log("Google Sheets API initialized.");
      return; // Exit if initialization succeeds
    } catch (e) {
      retryCount++;
      log("Initialization attempt $retryCount failed: $e");

      if (retryCount < maxRetries) {
        log("Retrying in ${delay.inSeconds} seconds...");
        await Future.delayed(delay);
      } else {
        log("Failed to initialize Google Sheets API after $maxRetries attempts.");
        throw Exception("Initialization failed after $maxRetries attempts: $e");
      }}}}
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      log("Waiting for Google Sheets API to initialize...");
      await _initialize();}}

  Future<ServiceAccountCredentials> _loadServiceAccountCredentials() async {
    final credentialsJson = await loadCredentials();
    return ServiceAccountCredentials.fromJson(credentialsJson);
  }
Future<List<Map<String, dynamic>>> loadData(String sheetName) async {
  try {
    // Load local data (either from local storage or assets)
    final localData = await _loadLocalData(sheetName);
    if (localData.isNotEmpty) {
      log("Données locales chargées pour $sheetName.");
      return localData;
    }

    // If no local data and there's an internet connection, fetch remote data
    if (await isConnectedToInternet()) {
      log("Aucune donnée locale disponible. Chargement depuis Google Sheets pour $sheetName.");
      final remoteData = await _loadRemoteData(sheetName);
      await _saveLocalData(sheetName, remoteData); // Save the data locally for future use
      return remoteData;
    } else {
      log("Aucune connexion Internet et pas de données locales pour $sheetName.");
      return [];
    }
  } catch (e) {
    log("Erreur lors du chargement des données pour $sheetName : $e");
    return [];
  }
}


Future<List<Map<String, dynamic>>> _loadRemoteData(String sheetName) async {
  await _ensureInitialized();
  try {
    final response = await _sheetsApi.spreadsheets.values
        .get(spreadsheetId, sheetName);

    if (response.values == null || response.values!.isEmpty) {
      log("Aucune donnée trouvée dans la feuille : $sheetName");
      return [];
    }

    // Extraction des en-têtes
    final headers = List<String>.from(response.values!.first);
    final dataRows = response.values!.skip(1);

    // Conversion des lignes en liste de maps
    final data = dataRows.map((row) {
      final Map<String, dynamic> rowMap = {};
      for (int i = 0; i < headers.length; i++) {
        rowMap[headers[i]] = i < row.length ? row[i] : null;
      }

      // Normalize 'mobile' field
      if (rowMap.containsKey('mobile') && rowMap['mobile'] != null) {
        rowMap['mobile'] = normalizeMobile(rowMap['mobile'].toString());
      }

      return rowMap;
    }).toList();

    log("Chargé ${data.length} lignes depuis $sheetName.");
    return data;
  } catch (e) {
    log("Erreur lors du chargement des données distantes pour $sheetName : $e");
    return [];
  }
}


  Future<List<String>> fetchSheetNames() async {
    await _ensureInitialized();
    try {
      final response =
          await _sheetsApi.spreadsheets.get(spreadsheetId, $fields: 'sheets');
      if (response.sheets == null || response.sheets!.isEmpty) {
        log("No sheets found in the spreadsheet.");
        return [];
      }

      final sheetNames =
          response.sheets!.map((sheet) => sheet.properties!.title!).toList();
      log("Fetched sheet names: $sheetNames");
      return sheetNames;
    } catch (e) {
      log("Error fetching sheet names: $e");
      return [];
    }
  }
Future<bool> downloadAllSheets() async {
  bool updatesPerformed = false;

  try {
    // Check for internet connectivity
    if (!await isConnectedToInternet()) {
      log("No internet connection available. Cannot fetch remote data.");
      throw Exception("No internet connection.");
    }

    final sheetNames = await fetchSheetNames();
    final localChecksums = await _loadChecksums();
    final updatedChecksums = <String, String>{};

    // Use Future.wait to process sheets concurrently
    final results = await Future.wait(sheetNames.map((sheetName) async {
      final remoteData = await _loadRemoteData(sheetName);
      final remoteChecksum = generateChecksum(remoteData);

      if (localChecksums[sheetName] == remoteChecksum) {
        log("No changes detected for $sheetName. Skipping download.");
        updatedChecksums[sheetName] = remoteChecksum; // Keep the current checksum
        return false; // No update for this sheet
      }

      // Perform the update
      log("Changes detected for $sheetName. Downloading...");
      await _saveLocalData(sheetName, remoteData);
      updatedChecksums[sheetName] = remoteChecksum;
      return true; // Update performed for this sheet
    }));

    // Determine if any updates were performed
    updatesPerformed = results.contains(true);

    // Save updated checksums locally
    await _saveChecksums(updatedChecksums);

    if (updatesPerformed) {
      log("All updated sheets downloaded successfully.");
    } else {
      log("All sheets are already up-to-date.");
    }
  } catch (e) {
    log("Error downloading sheets: $e");
    rethrow; // Allow the error to propagate for handling in the calling method
  }

  return updatesPerformed; // Indicate whether updates were made
}


  Future<void> _saveLocalData(String sheetName, List<Map<String, dynamic>> data) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/contacts_$sheetName.json';
      final file = File(path);
      log("Saving JSON to: $path"); // Log the file path
      if (file.existsSync()) {
        log("Overwriting existing file for $sheetName.");
      } else {
        log("Creating new file for $sheetName.");
      }

      final content = json.encode(data);
      await file.writeAsString(content, flush: true);
      log("Data saved locally for $sheetName with ${data.length} entries.");
    } catch (e) {
      log("Error saving local data for $sheetName: $e");
    }
  }

Future<List<Map<String, dynamic>>> _loadLocalData(String sheetName) async {
  try {
    // Attempt to load from the application documents directory first
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/contacts_$sheetName.json';

    if (File(path).existsSync()) {
      final content = await File(path).readAsString();
      final data = json.decode(content);
      if (data is List) {
        final processedData = data.map((entry) {
          final rowMap = Map<String, dynamic>.from(entry);
          
          // Normalize 'mobile' field
          if (rowMap.containsKey('mobile') && rowMap['mobile'] != null) {
            rowMap['mobile'] = normalizeMobile(rowMap['mobile'].toString());
          }
          
          return rowMap;
        }).toList();

        log("Loaded local data for $sheetName from app documents with ${processedData.length} entries.");
        return processedData;
      } else {
        log("Invalid format in local file for $sheetName.");
      }
    } else {
      log("Local file for $sheetName does not exist in documents directory. Attempting to load from assets.");
    }

    // Fallback to loading from assets if file doesn't exist in local storage
    final assetPath = 'assets/data/contacts_$sheetName.json';
    final assetContent = await rootBundle.loadString(assetPath);
    final assetData = json.decode(assetContent);
    if (assetData is List) {
      final processedData = assetData.map((entry) {
        final rowMap = Map<String, dynamic>.from(entry);
        
        // Normalize 'mobile' field
        if (rowMap.containsKey('mobile') && rowMap['mobile'] != null) {
          rowMap['mobile'] = normalizeMobile(rowMap['mobile'].toString());
        }
        
        return rowMap;
      }).toList();

      log("Loaded local data for $sheetName from assets with ${processedData.length} entries.");
      return processedData;
    } else {
      log("Invalid format in assets file for $sheetName.");
    }
  } catch (e) {
    log("Error loading local data for $sheetName: $e");
  }
  return [];
}



    // Load application state
  Future<String> loadState() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/app_state.json';
      final file = File(path);

      if (await file.exists()) {
        final content = await file.readAsString();
        final jsonData = json.decode(content);
        return jsonData['route'] ?? '/';
      }
    } catch (e) {
      log('Error loading state: $e');
    }
    return '/';
  }

  // Save application state
  Future<void> saveState(String route) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/app_state.json';
      final file = File(path);
      final jsonData = {'route': route};
      await file.writeAsString(json.encode(jsonData), flush: true);
      log("App state saved: $route");
    } catch (e) {
      log("Error saving state: $e");
    }
  }

  // Clear cache
  void clearCache() {
    _cache.clear();
    log("Cache cleared.");
  }

  // Check for internet connectivity
  Future<bool> isConnectedToInternet() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com')).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      log("Internet connectivity check failed: $e");
      return false;
    }
  }
Future<String?> fetchSpreadsheetLastModifiedTime() async {
  try {
    // Create the Drive API client
    final driveApi = drive.DriveApi(
      await clientViaServiceAccount(await _loadServiceAccountCredentials(), _scopes),
    );

    // Fetch the file metadata, including the 'modifiedTime' field
    final file = await driveApi.files.get(
      spreadsheetId,
      $fields: 'modifiedTime',
    );

    // Ensure the result is a drive.File and extract 'modifiedTime'
    if (file is drive.File && file.modifiedTime != null) {
      return file.modifiedTime!.toIso8601String();
    }

    log("No modified time available for spreadsheet ID: $spreadsheetId");
    return null;
  } catch (e) {
    log("Error fetching spreadsheet modification time: $e");
    return null;
  }
}
  Future<void> _saveTimestamps(Map<String, String> timestamps) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/sheet_timestamps.json';
    final file = File(path);
    final content = json.encode(timestamps);
    await file.writeAsString(content, flush: true);
    log("Timestamps saved locally.");
  } catch (e) {
    log("Error saving timestamps: $e");
  }
}

Future<Map<String, String>> _loadTimestamps() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/sheet_timestamps.json';
    final file = File(path);

    if (file.existsSync()) {
      final content = await file.readAsString();
      final data = json.decode(content);
      return Map<String, String>.from(data);
    }
  } catch (e) {
    log("Error loading timestamps: $e");
  }
  return {};
}


String generateChecksum(List<Map<String, dynamic>> data) {
  final jsonString = json.encode(data); // Convert data to JSON string
  return md5.convert(utf8.encode(jsonString)).toString(); // Calculate MD5 hash
}
Future<void> _saveChecksums(Map<String, String> checksums) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/sheet_checksums.json';
    final file = File(path);
    final content = json.encode(checksums);
    await file.writeAsString(content, flush: true);
    log("Checksums saved locally.");
  } catch (e) {
    log("Error saving checksums: $e");
  }
}
Future<Map<String, String>> _loadChecksums() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/sheet_checksums.json';
    final file = File(path);

    if (file.existsSync()) {
      final content = await file.readAsString();
      final data = json.decode(content);
      return Map<String, String>.from(data);
    }
  } catch (e) {
    log("Error loading checksums: $e");
  }
  return {};
}
String normalizeMobile(String mobile) {
  // Remove all non-numeric characters
  mobile = mobile.replaceAll(RegExp(r'\D'), '');

  // Ensure the number starts with '0'
  if (!mobile.startsWith('0')) {
    mobile = '0$mobile';
  }

  // Pad with zeros to ensure a length of 10
  return mobile.padLeft(10, '0');
}
  
Future<ServiceAccountCredentials> loadCredentials() async {
  final credentialsJson = Platform.environment['GOOGLE_CREDENTIALS'];

  if (credentialsJson == null || credentialsJson.isEmpty) {
    log("GOOGLE_CREDENTIALS not found.");
    throw Exception("Missing credentials!");
  }

  log("GOOGLE_CREDENTIALS loaded successfully.");
  return ServiceAccountCredentials.fromJson(jsonDecode(credentialsJson));
}



}
