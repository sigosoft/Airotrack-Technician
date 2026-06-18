import 'dart:io';

import 'package:airotrackgit/config/api_config.dart';
import 'package:airotrackgit/ui/utils/Functions/network_testing.dart';
import 'package:airotrackgit/ui/utils/Functions/on_dio_exception.dart';
import 'package:airotrackgit/ui/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:path_provider/path_provider.dart';

class ProductCertificateController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    debugPrint("ProductCertificateController initialized");
  }

  @override
  void onClose() {
    debugPrint("ProductCertificateController disposed");
    super.onClose();
  }

  String? localPdfPath;
  bool isLoading = false;
  Dio dio = () {
    final d = Dio();
    configureDio(d);
    return d;
  }();
  String productCertificate = "";

  Future<void> generateProductCertificate(String id) async {
    isLoading = true;
    checkNetworkAndRedirectOffAll();
    try {
      var token = await getSavedObject("token");
      debugPrint("Token: $token");
      String url = APIConfig.BASE_URL + APIEndpoints.generateProductCertificate;
      dio.options.headers["Authorization"] = "Bearer $token";
      dio.options.queryParameters = {
        "job_id": id,
      };
      debugPrint("URL: $url");
      debugPrint("Query Parameters: ${dio.options.queryParameters}");
      
      // Try to get PDF as bytes first
      final response = await dio.get(url, 
        options: Options(responseType: ResponseType.bytes),
      );
      debugPrint("Response Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        // Check if response is actually JSON (contains PDF URL)
        final responseData = response.data;
        String? pdfUrl;
        
        try {
          // Try to parse as JSON to check if it contains a URL
          final jsonString = String.fromCharCodes(responseData);
          if (jsonString.trim().startsWith('{')) {
            // It's JSON, try to extract PDF URL
            final jsonResponse = await dio.get(url, 
              options: Options(responseType: ResponseType.json),
            );
            debugPrint("JSON Response: ${jsonResponse.data}");
            
            // Check common response formats
            if (jsonResponse.data is Map) {
              pdfUrl = jsonResponse.data['data']?['pdf_url'] ?? 
                      jsonResponse.data['pdf_url'] ?? 
                      jsonResponse.data['url'] ??
                      jsonResponse.data['data'];
            }
            
            if (pdfUrl != null) {
              // Download PDF from URL
              await _downloadPdfFromUrl(pdfUrl, id);
            } else {
              throw Exception("PDF URL not found in response");
            }
          } else {
            // It's raw PDF bytes, save directly
            await _savePdfBytes(responseData, id);
          }
        } catch (e) {
          debugPrint("Error parsing response: $e");
          // Assume it's raw PDF bytes
          await _savePdfBytes(responseData, id);
        }
      } else {
        throw Exception("Unexpected status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        handleDioException(e);
      } else {
        debugPrint("Dio Exception without response: ${e.message}");
      }
    } catch (e) {
      debugPrint("Unexpected Error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> _savePdfBytes(dynamic bytes, String id) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/product_certificate_$id.pdf");
    await file.writeAsBytes(bytes, flush: true);
    localPdfPath = file.path;
    productCertificate = "Generated";
    debugPrint("PDF saved to: ${localPdfPath}");
    update();
  }

  Future<void> _downloadPdfFromUrl(String pdfUrl, String id) async {
    try {
      var token = await getSavedObject("token");
      final response = await dio.get(
        pdfUrl,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
          responseType: ResponseType.bytes,
        ),
      );
      
      if (response.statusCode == 200) {
        await _savePdfBytes(response.data, id);
      } else {
        throw Exception("Failed to download PDF: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error downloading PDF from URL: $e");
      rethrow;
    }
  }
}
