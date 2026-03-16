enum VolunteerRole {
  ushering,
  music,
  av,
  greeter,
  children,
  other;

  String get displayName {
    switch (this) {
      case VolunteerRole.ushering:
        return 'Ushering';
      case VolunteerRole.music:
        return 'Music';
      case VolunteerRole.av:
        return 'AV Team';
      case VolunteerRole.greeter:
        return 'Greeter';
      case VolunteerRole.children:
        return 'Children\'s Ministry';
      case VolunteerRole.other:
        return 'Other';
    }
  }
}

enum VolunteerStatus { pending, approved, declined }

class VolunteerRequest {
  final String id;
  final String userId;
  final String userName;
  final VolunteerRole role;
  final DateTime requestDate;
  final DateTime? serviceDate;
  VolunteerStatus status;
  final String? notes;

  VolunteerRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.role,
    required this.requestDate,
    this.serviceDate,
    this.status = VolunteerStatus.pending,
    this.notes,
  });
}