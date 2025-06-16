import 'package:flutter/material.dart';
import '../models/quote_model.dart';
import '../services/quote_service.dart';
import '../widgets/quote_form.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final QuoteServiceHttp _quoteService = QuoteServiceHttp();
  List<QuoteModel> _quotes = [];
  final _authorController = TextEditingController();
  final _quoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchQuotes();
  }

  Future<void> _fetchQuotes() async {
    try {
      _quotes = await _quoteService.getQuotes();
      setState(() {});
    } catch (e) {
      print('Gagal memuat quotes: $e');
    }
  }

  void _addQuote() async {
    final newQuote = QuoteModel(
      author: _authorController.text,
      quote: _quoteController.text,
      date: DateTime.now().toIso8601String(),
    );
    await _quoteService.addQuote(newQuote);
    _authorController.clear();
    _quoteController.clear();
    Navigator.of(context).pop();
    _fetchQuotes();
  }

  void _showEditDialog(QuoteModel quote) {
    _authorController.text = quote.author;
    _quoteController.text = quote.quote;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Quote'),
            content: QuoteForm(
              authorController: _authorController,
              quoteController: _quoteController,
              onSave: () async {
                final updatedQuote = QuoteModel(
                  id: quote.id,
                  author: _authorController.text,
                  quote: _quoteController.text,
                  date: DateTime.now().toIso8601String(),
                );
                await _quoteService.updateQuote(updatedQuote);
                _authorController.clear();
                _quoteController.clear();
                Navigator.of(context).pop();
                _fetchQuotes();
              },
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quote Harian'),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: SafeArea(
        child:
            _quotes.isEmpty
                ? Center(child: Text('Belum ada quote'))
                : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _quotes.length,
                  itemBuilder: (context, index) {
                    final quote = _quotes[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quote.quote,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'By: ${quote.author}',
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[700],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.purple),
                                  onPressed: () => _showEditDialog(quote),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await _quoteService.deleteQuote(quote.id!);
                                    _fetchQuotes();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: Icon(Icons.add, color: Colors.white),
        onPressed:
            () => showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text('Tambah Quote'),
                    content: QuoteForm(
                      authorController: _authorController,
                      quoteController: _quoteController,
                      onSave: _addQuote,
                    ),
                  ),
            ),
      ),
    );
  }
}
