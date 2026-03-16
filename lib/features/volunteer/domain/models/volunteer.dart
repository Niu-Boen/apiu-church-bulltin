enum VolunteerRole { ushering, music, av, greeter, children, other }
enum VolunteerStatus { pending, approved, declined }

class VolunteerRequest {
  final String id;
  final String userId;
  final String userName;
  final VolunteerRole role;
  final DateTime requestDate;
  final VolunteerStatus status;
  final String? notes;

  VolunteerRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.role,
    required this.requestDate,
    this.status = VolunteerStatus.pending,
    this.notes,
  });
}