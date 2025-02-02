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
  final String? description;
  final double locationLat;
  final double locationLon;
  final String tag;
  final String reportedBy;

  ReportFormData({
    required this.photo,
    required this.title,
    this.description,
    required this.locationLat,
    required this.locationLon,
    required this.tag,
    required this.reportedBy,
  });

  factory ReportFormData.fromMap(Map<String, dynamic> map) {
    return ReportFormData(
      photo: map['photo'],
      title: map['title'],
      description: map['description'],
      locationLat: map['location_lat'],
      locationLon: map['location_lon'],
      tag: map['tag'],
      reportedBy: map['reported_by'],
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
      'reported_by': reportedBy,
    };
  }
}

class Comment {
  String id;
  String comment;
  String authorId;

  Comment({
    required this.id,
    required this.comment,
    required this.authorId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      comment: json['comment'],
      authorId: json['author_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comment': comment,
      'author_id': authorId,
    };
  }
}

class Report {
  String id;
  String title;
  String? description;
  String photoUrl;
  double locationLat;
  double locationLon;
  String tag;
  String reportedBy;
  int timestamp; // epoch seconds
  int upvotes;
  List<Comment> comments;

  Report({
    required this.id,
    required this.title,
    this.description,
    required this.photoUrl,
    required this.locationLat,
    required this.locationLon,
    required this.tag,
    required this.reportedBy,
    required this.timestamp,
    required this.upvotes,
    required this.comments,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      photoUrl: json['photo_path'],
      locationLat: json['location_lat'],
      locationLon: json['location_lon'],
      tag: json['tag'],
      reportedBy: json['reported_by'],
      timestamp: json['timestamp'],
      upvotes: json['upvotes'],
      // Parse comments as a list of Comment objects
      comments: (json['comments'] as List<dynamic>)
          .map((commentJson) => Comment.fromJson(commentJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'photo_path': photoUrl,
      'location_lat': locationLat,
      'location_lon': locationLon,
      'tag': tag,
      'reported_by': reportedBy,
      'timestamp': timestamp,
      'upvotes': upvotes,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }
}
