import 'health_summary.dart';
import 'models.dart';

class HomeState {
  final String ownerFirstName;
  final Dog? selectedDog;
  final List<SitterListing> featuredSitters;
  final BookingRequest? activeBooking;
  final BookingRequest? nextBooking;
  final int otherBookingCount;
  final int pendingCount;
  final HealthSummary health;
  final DateTime evaluatedAt;

  HomeState({
    required this.ownerFirstName,
    required this.evaluatedAt,
    this.selectedDog,
    List<SitterListing> featuredSitters = const [],
    this.activeBooking,
    this.nextBooking,
    this.otherBookingCount = 0,
    this.pendingCount = 0,
  }) : featuredSitters = List.unmodifiable(featuredSitters),
       health = HealthSummary.forDog(selectedDog, evaluatedAt);
}
