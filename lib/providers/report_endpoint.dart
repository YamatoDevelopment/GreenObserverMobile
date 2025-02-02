import 'package:dio/dio.dart';
import 'package:greenobserver/models.dart';

class ReportEndpoint {
  Dio _client;

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
