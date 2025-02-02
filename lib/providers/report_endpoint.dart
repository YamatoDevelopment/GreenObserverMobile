import 'package:dio/dio.dart';
import 'package:greenobserver/models.dart';

class ReportEndpoint {
  final Dio _client;

  ReportEndpoint(this._client);

  Future<void> createReport(ReportFormData report) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(report.photo.path),
      'title': report.title,
      'description': report.description,
      'location_lat': report.locationLat,
      'location_lon': report.locationLon,
      'tag': report.tag,
      'reported_by': report.reportedBy,
    });

    await _client.post('/reports/', data: formData);
  }

  Future<Report> getReport(String id) async {
    final response = await _client.get('/reports/$id/');
    return Report.fromJson(response.data);
  }

  Future<void> upvoteReport(String id, String username) async {
    await _client.post('/reports/$id/upvote/', data: {'upvoted_by': username});
  }

  Future<List<Report>> getReports() async {
    final response = await _client.get('/reports/');
    final List<dynamic> reportsJson = response.data['reports'];
    List<Report> reports = [];
    for (var report in reportsJson) {
      reports.add(Report.fromJson(report));
    }
    return reports;
  }
}
