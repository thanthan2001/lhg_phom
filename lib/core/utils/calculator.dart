import 'dart:math';

class CalculatorUtils {
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Bán kính trái đất, đơn vị kilometer

    // Kiểm tra nếu hai điểm có cùng tọa độ
    if ((lat1 == lat2) && (lon1 == lon2)) {
      return 0;
    }

    // Kiểm tra giới hạn hợp lệ của tọa độ
    if ((lat1 < -90 || lat1 > 90) ||
        (lon1 < -180 || lon1 > 180) ||
        (lat2 < -90 || lat2 > 90) ||
        (lon2 < -180 || lon2 > 180)) {
      throw ArgumentError('Invalid coordinates');
    }

    // Chuyển đổi tọa độ từ độ sang radian
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    // Tính toán haversine
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;
    return distance;
  }

// Hàm chuyển đổi từ độ sang radian
 static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}