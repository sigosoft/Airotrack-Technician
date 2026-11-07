import 'package:airotrackgit/config/api_config.dart';
import 'package:airotrackgit/ui/server/serverdown.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils.dart';

void handleDioException(DioException e) {
  if (e.response != null) {
    switch (e.response?.statusCode) {
      case 400:
        debugPrint("Bad Request: ${e.response?.data}");
        showToast("Bad Request: ${e.response?.data}");
        break;
      case 401:
        debugPrint("Unauthorized: ${e.response?.data}");
        final path = e.requestOptions.path;
        bool isAuthEndpoint = path.endsWith(APIEndpoints.login) ||
            path.endsWith(APIEndpoints.logout) ||
            path.contains('/${APIEndpoints.login}') ||
            path.contains('/${APIEndpoints.logout}');
        if (!isAuthEndpoint) {
          handleTokenExpired();
        } else {
          showToast("Unauthorized: Please login again");
        }
        break;
      case 403:
        debugPrint("Forbidden: ${e.response?.data}");
        showToast("Access Denied: ${e.response?.data}");
        break;
      case 404:
        debugPrint("Not Found: ${e.response?.data}");
        showToast("Resource Not Found");
        break;
      case 422:
        debugPrint("Validation Error: ${e.response?.data}");
        showToast(e.response?.data["message"].toString() ?? "");
        break;
      case 500:
        debugPrint("Server Error: ${e.response?.data}");
        Get.offAll(const ServerDown());
        break;
      case 502:
        debugPrint("Bad Gateway: ${e.response?.data}");
        showToast("Server temporarily unavailable");
        break;
      case 503:
        debugPrint("Service Unavailable: ${e.response?.data}");
        showToast("Service temporarily unavailable");
        break;
      default:
        debugPrint(
            "Dio Error: ${e.response?.statusCode} -> ${e.response?.data}");
        showToast("An error occurred: ${e.response?.statusCode}");
    }
  } else {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        debugPrint("Connection Timeout: ${e.message}");
        showToast("Connection timed out. Please check your internet");
        break;
      case DioExceptionType.sendTimeout:
        debugPrint("Send Timeout: ${e.message}");
        showToast("Request timed out");
        break;
      case DioExceptionType.receiveTimeout:
        debugPrint("Receive Timeout: ${e.message}");
        showToast("Request timed out");
        break;
      case DioExceptionType.badResponse:
        debugPrint("Bad Response: ${e.message}");
        break;
      case DioExceptionType.cancel:
        debugPrint("Request Cancelled: ${e.message}");
        showToast("Request cancelled");
        break;
      case DioExceptionType.unknown:
        debugPrint("Dio Exception (Unknown): ${e.message}");
        showToast("No internet connection. Please check your network");
        break;
      default:
        debugPrint("Dio Exception: ${e.message}");
        showToast("Network error occurred");
    }
  }
}
