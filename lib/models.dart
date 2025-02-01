/*
class ReportFormData(BaseModel):
    photo: UploadFile
    title: str
    description: str | None = None
    location_lat: float
    location_lon: float
    tag: ReportTag
    reported_by_id: uuid.UUID
*/

import 'dart:io';

class ReportFormData {
  final File photo;
  final String title;
  final String description;
  final double locationLat;
  final double locationLon;
  final String tag;
  final String reportedById;

  ReportFormData({
    required this.photo,
    required this.title,
    required this.description,
    required this.locationLat,
    required this.locationLon,
    required this.tag,
    required this.reportedById,
  });

  factory ReportFormData.fromMap(Map<String, dynamic> map) {
    return ReportFormData(
      photo: map['photo'],
      title: map['title'],
      description: map['description'],
      locationLat: map['location_lat'],
      locationLon: map['location_lon'],
      tag: map['tag'],
      reportedById: map['reported_by_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'photo': photo,
      'title': title,
      'description': description,
      'location_lat': locationLat,
      'location_lon': locationLon,
      'tag': tag,
      'reported_by_id': reportedById,
    };
  }
}
