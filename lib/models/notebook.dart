import 'dart:convert';

class NotebookPage {
  final String id;
  final int dayNum;
  final String date;
  final String place;
  final String people;
  final int rating;
  final String done;
  final String eaten;
  final String bought;
  final String notes; // Added field for speech bubble diary note
  final List<String> images; // Base64 image strings

  NotebookPage({
    required this.id,
    required this.dayNum,
    required this.date,
    required this.place,
    required this.people,
    required this.rating,
    required this.done,
    required this.eaten,
    required this.bought,
    required this.notes,
    required this.images,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dayNum': dayNum,
      'date': date,
      'place': place,
      'people': people,
      'rating': rating,
      'done': done,
      'eaten': eaten,
      'bought': bought,
      'notes': notes,
      'images': images,
    };
  }

  factory NotebookPage.fromMap(Map<String, dynamic> map) {
    return NotebookPage(
      id: map['id'] ?? '',
      dayNum: map['dayNum']?.toInt() ?? 1,
      date: map['date'] ?? '',
      place: map['place'] ?? '',
      people: map['people'] ?? '',
      rating: map['rating']?.toInt() ?? 5,
      done: map['done'] ?? '',
      eaten: map['eaten'] ?? '',
      bought: map['bought'] ?? '',
      notes: map['notes'] ?? '',
      images: List<String>.from(map['images'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory NotebookPage.fromJson(String source) => NotebookPage.fromMap(json.decode(source));
}

class Notebook {
  final String id;
  final String title;
  final String startDate;
  final String endDate;
  final String coverColor;
  final String coverEmoji;
  final int rating;
  final List<NotebookPage> pages;

  Notebook({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.coverColor,
    required this.coverEmoji,
    required this.rating,
    required this.pages,
  });

  Notebook copyWith({
    String? title,
    String? startDate,
    String? endDate,
    String? coverColor,
    String? coverEmoji,
    int? rating,
    List<NotebookPage>? pages,
  }) {
    return Notebook(
      id: this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      coverColor: coverColor ?? this.coverColor,
      coverEmoji: coverEmoji ?? this.coverEmoji,
      rating: rating ?? this.rating,
      pages: pages ?? this.pages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate,
      'endDate': endDate,
      'coverColor': coverColor,
      'coverEmoji': coverEmoji,
      'rating': rating,
      'pages': pages.map((x) => x.toMap()).toList(),
    };
  }

  factory Notebook.fromMap(Map<String, dynamic> map) {
    return Notebook(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      coverColor: map['coverColor'] ?? '#FFFFFF',
      coverEmoji: map['coverEmoji'] ?? '✈️',
      rating: map['rating']?.toInt() ?? 5,
      pages: List<NotebookPage>.from(map['pages']?.map((x) => NotebookPage.fromMap(x)) ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory Notebook.fromJson(String source) => Notebook.fromMap(json.decode(source));
}
