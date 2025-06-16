class QuoteModel {
  String? id;
  String author;
  String quote;
  String date;

  QuoteModel({
    this.id,
    required this.author,
    required this.quote,
    required this.date,
  });

  factory QuoteModel.fromMap(Map<String, dynamic> map) {
    return QuoteModel(
      id: map['id'],
      author: map['author'],
      quote: map['quote'],
      date: map['date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'author': author, 'quote': quote, 'date': date};
  }
}
