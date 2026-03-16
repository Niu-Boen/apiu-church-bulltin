import 'lib/../../domain/models/volunteer_models.dart';

List<VolunteerRequest> volunteerRequests = [
  VolunteerRequest(
    id: '1',
    userId: 'user1',
    userName: 'John Doe',
    role: VolunteerRole.ushering,
    requestDate: DateTime.now(),
    serviceDate: DateTime.now().add(const Duration(days: 5)),
  ),
];