import 'package:url_launcher/url_launcher.dart';

class MapNavigationService {
  const MapNavigationService();

  /// Launch Google Maps navigation to destination coordinates
  Future<bool> launchMapsNavigation({
    required double lat,
    required double lng,
    String? label,
  }) async {
    // Web intent / Google Maps universal URL
    final urlString = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    final uri = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}

    // Fallback attempt without mode restriction
    try {
      return await launchUrl(uri);
    } catch (_) {
      return false;
    }
  }

  /// Launch navigation or search using destination address string
  Future<bool> launchAddressNavigation(String address) async {
    final encoded = Uri.encodeComponent(address);
    final urlString = 'https://www.google.com/maps/search/?api=1&query=$encoded';
    final uri = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}

    try {
      return await launchUrl(uri);
    } catch (_) {
      return false;
    }
  }

  /// Launch the device phone dialer for contacting farmer or customer
  Future<bool> launchPhoneCall(String phoneNumber) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleaned');

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
    } catch (_) {}
    return false;
  }
}

