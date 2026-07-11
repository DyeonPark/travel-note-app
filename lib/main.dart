import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import './models/notebook.dart';
import './services/storage_service.dart';
import './theme/app_theme.dart';
import './theme/app_doodles.dart';

void main() {
  runApp(const MongleApp());
}

class MongleApp extends StatelessWidget {
  const MongleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '몽글수첩',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFDFBF7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
        ),
        fontFamily: 'UhBeeMysen',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFDFBF7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
        ),
        fontFamily: 'UhBeeMysen',
      ),
      home: const MainHomeScreen(),
    );
  }
}

class NotebookLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..strokeWidth = 1.5;
    
    double y = 42.0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += AppThemeConstants.notebookLineSpacing;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();

  List<Notebook> _notebooks = [];
  String _currentView = 'home'; // home | notebook | add-notebook | add-page | edit-page
  Notebook? _selectedNotebook;
  int _activePageIndex = 0;
  String? _editingPageId;

  // New Notebook Form fields
  final _newTitleController = TextEditingController();
  final _newStartController = TextEditingController();
  final _newEndController = TextEditingController();
  String _newEmoji = '✈️';
  String _newColor = '#FFFFFF';

  // New Page Entry fields
  final _pageDateController = TextEditingController();
  final _pagePlaceController = TextEditingController();
  final _pagePeopleController = TextEditingController();
  int _pageRating = 5;
  final _pageDoneController = TextEditingController();
  final _pageEatenController = TextEditingController();
  final _pageBoughtController = TextEditingController();
  final _pageNotesController = TextEditingController(); // Added controller for speech bubble
  List<String> _pageImages = []; // Base64 strings

  // Custom alert modal config
  bool _dialogShow = false;
  String _dialogMsg = '';
  String _dialogType = 'alert'; // alert | confirm
  VoidCallback? _dialogOnConfirm;

  @override
  void initState() {
    super.initState();
    _loadAllNotebooks();
  }

  @override
  void dispose() {
    _newTitleController.dispose();
    _newStartController.dispose();
    _newEndController.dispose();
    _pageDateController.dispose();
    _pagePlaceController.dispose();
    _pagePeopleController.dispose();
    _pageDoneController.dispose();
    _pageEatenController.dispose();
    _pageBoughtController.dispose();
    _pageNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadAllNotebooks() async {
    final list = await _storageService.loadNotebooks();
    setState(() {
      _notebooks = list;
      // Sync reference
      if (_selectedNotebook != null) {
        _selectedNotebook = _notebooks.firstWhere((x) => x.id == _selectedNotebook!.id, orElse: () => _selectedNotebook!);
      }
    });
  }

  Future<void> _saveAll() async {
    await _storageService.saveAllNotebooks(_notebooks);
    _loadAllNotebooks();
  }

  void _triggerAlert(String msg) {
    setState(() {
      _dialogShow = true;
      _dialogMsg = msg;
      _dialogType = 'alert';
      _dialogOnConfirm = null;
    });
  }

  void _triggerConfirm(String msg, VoidCallback onConfirm) {
    setState(() {
      _dialogShow = true;
      _dialogMsg = msg;
      _dialogType = 'confirm';
      _dialogOnConfirm = onConfirm;
    });
  }

  // Image upload and compression
  Future<void> _pickImage() async {
    if (_pageImages.length >= 3) {
      _triggerAlert("이미지는 최대 3장까지만 넣을 수 있어요! 📸");
      return;
    }

    try {
      final List<XFile> picked = await _imagePicker.pickMultiImage(
        imageQuality: 30, // Compress heavily for local storage compatibility
      );

      if (picked.isNotEmpty) {
        for (var file in picked) {
          final bytes = await file.readAsBytes();
          final base64String = base64Encode(bytes);
          setState(() {
            if (_pageImages.length < 3) {
              _pageImages.add("data:image/jpeg;base64,$base64String");
            }
          });
        }
      }
    } catch (e) {
      _triggerAlert("사진 라이브러리를 여는 중에 오류가 발생했습니다.");
    }
  }

  void _removeSelectedImage(int index) {
    setState(() {
      _pageImages.removeAt(index);
    });
  }

  void _handleCreateNotebook() {
    final title = _newTitleController.text.trim();
    if (title.isEmpty) {
      _triggerAlert('수첩 이름을 입력해 주세요!');
      return;
    }

    final todayStr = DateTime.now().toString().split(' ')[0];
    final start = _newStartController.text.trim().isEmpty ? todayStr : _newStartController.text.trim();
    final end = _newEndController.text.trim().isEmpty ? todayStr : _newEndController.text.trim();

    final newBook = Notebook(
      id: 'book-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      startDate: start,
      endDate: end,
      coverColor: _newColor,
      coverEmoji: _newEmoji,
      rating: 5,
      pages: [],
    );

    setState(() {
      _notebooks.insert(0, newBook);
      _selectedNotebook = newBook;
      _activePageIndex = 0;
      _currentView = 'notebook';

      // Reset form
      _newTitleController.clear();
      _newStartController.clear();
      _newEndController.clear();
      _newEmoji = '✈️';
      _newColor = '#FFFFFF';
    });

    _saveAll();
  }

  void _handleDeleteNotebook(String id) {
    _triggerConfirm("이 여행 수첩을 삭제하시겠습니까?", () {
      setState(() {
        _notebooks.removeWhere((b) => b.id == id);
        _selectedNotebook = null;
        _currentView = 'home';
      });
      _saveAll();
    });
  }

  void _handleCreatePage() {
    if (_selectedNotebook == null) return;

    final todayStr = DateTime.now().toString().split(' ')[0];
    final newPage = NotebookPage(
      id: 'page-${DateTime.now().millisecondsSinceEpoch}',
      dayNum: _selectedNotebook!.pages.length + 1,
      date: _pageDateController.text.trim().isEmpty ? todayStr : _pageDateController.text.trim(),
      place: _pagePlaceController.text.trim().isEmpty ? '어느 골목길' : _pagePlaceController.text.trim(),
      people: _pagePeopleController.text.trim().isEmpty ? '나 혼자서' : _pagePeopleController.text.trim(),
      rating: _pageRating,
      done: _pageDoneController.text.trim(),
      eaten: _pageEatenController.text.trim(),
      bought: _pageBoughtController.text.trim(),
      notes: _pageNotesController.text.trim(),
      images: List<String>.from(_pageImages),
    );

    setState(() {
      final updatedPages = List<NotebookPage>.from(_selectedNotebook!.pages)..add(newPage);
      final avgRating = (updatedPages.map((e) => e.rating).reduce((a, b) => a + b) / updatedPages.length).round();

      _notebooks = _notebooks.map((b) {
        if (b.id == _selectedNotebook!.id) {
          return b.copyWith(pages: updatedPages, rating: avgRating);
        }
        return b;
      }).toList();

      _activePageIndex = updatedPages.length - 1;
      _currentView = 'notebook';
      _resetPageForm();
    });

    _saveAll();
  }

  void _startEditingPage(NotebookPage page) {
    setState(() {
      _editingPageId = page.id;
      _pageDateController.text = page.date;
      _pagePlaceController.text = page.place;
      _pagePeopleController.text = page.people;
      _pageRating = page.rating;
      _pageDoneController.text = page.done;
      _pageEatenController.text = page.eaten;
      _pageBoughtController.text = page.bought;
      _pageNotesController.text = page.notes;
      _pageImages = List<String>.from(page.images);
      _currentView = 'edit-page';
    });
  }

  void _handleUpdatePage() {
    if (_selectedNotebook == null || _editingPageId == null) return;

    setState(() {
      final updatedPages = _selectedNotebook!.pages.map((p) {
        if (p.id == _editingPageId) {
          return NotebookPage(
            id: p.id,
            dayNum: p.dayNum,
            date: _pageDateController.text.trim(),
            place: _pagePlaceController.text.trim().isEmpty ? '어느 골목길' : _pagePlaceController.text.trim(),
            people: _pagePeopleController.text.trim().isEmpty ? '나 혼자서' : _pagePeopleController.text.trim(),
            rating: _pageRating,
            done: _pageDoneController.text.trim(),
            eaten: _pageEatenController.text.trim(),
            bought: _pageBoughtController.text.trim(),
            notes: _pageNotesController.text.trim(),
            images: List<String>.from(_pageImages),
          );
        }
        return p;
      }).toList();

      final avgRating = (updatedPages.map((e) => e.rating).reduce((a, b) => a + b) / updatedPages.length).round();

      _notebooks = _notebooks.map((b) {
        if (b.id == _selectedNotebook!.id) {
          return b.copyWith(pages: updatedPages, rating: avgRating);
        }
        return b;
      }).toList();

      _currentView = 'notebook';
      _editingPageId = null;
      _resetPageForm();
    });

    _saveAll();
  }

  void _resetPageForm() {
    _pageDateController.clear();
    _pagePlaceController.clear();
    _pagePeopleController.clear();
    _pageRating = 5;
    _pageDoneController.clear();
    _pageEatenController.clear();
    _pageBoughtController.clear();
    _pageNotesController.clear();
    _pageImages = [];
  }

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime initialDate = DateTime.now();
    try {
      if (controller.text.trim().isNotEmpty) {
        initialDate = DateTime.parse(controller.text.trim());
      }
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              surface: Color(0xFFFDFBF7),
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text = picked.toString().split(' ')[0];
      });
    }
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.white;
    }
  }

  Widget _buildStars(int count, {ValueChanged<int>? onChange, double size = 18}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starNum = index + 1;
        final isFilled = starNum <= count;
        return GestureDetector(
          onTap: onChange != null ? () => onChange(starNum) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: SvgPicture.string(
              isFilled ? filledStarSvg : emptyStarSvg,
              width: size,
              height: size,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxViewportWidth = width > 480 ? 450.0 : width;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: Center(
        child: Container(
          width: maxViewportWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.symmetric(
              vertical: BorderSide(color: Colors.black, width: width > 480 ? 4 : 0),
            ),
            boxShadow: width > 480
                ? const [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(8, 8),
                      blurRadius: 0,
                    )
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  // 1. Hand Drawn Custom Header
                  if (_currentView == 'home')
                    _buildHeader()
                  else
                    const SafeArea(child: SizedBox.shrink()),

                  // 2. View selector
                  Expanded(
                    child: _buildCurrentView(),
                  ),
                ],
              ),

              // 3. Custom Sketch Alert/Confirm Dialog
              if (_dialogShow) _buildCustomDialog(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 4),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _currentView = 'home';
                  _resetPageForm();
                });
              },
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Text('🖋️', style: TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '몽글수첩',
                        style: GoogleFonts.gaegu(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.1,
                        ),
                      ),
                      const Text(
                        'HAND DRAWN MEMORY',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  final todayStr = DateTime.now().toString().split(' ')[0];
                  _newStartController.text = todayStr;
                  _newEndController.text = todayStr;
                  _currentView = 'add-notebook';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(10),
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                  ],
                ),
                child: Text(
                  '+ 수첩 만들기',
                  style: GoogleFonts.gaegu(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case 'home':
        return _buildHomeView();
      case 'add-notebook':
        return _buildAddNotebookView();
      case 'notebook':
        return _buildNotebookView();
      case 'add-page':
        return _buildAddPageView(isEdit: false);
      case 'edit-page':
        return _buildAddPageView(isEdit: true);
      default:
        return _buildHomeView();
    }
  }

  // View 1: Home View (Notebook list Shelf)
  Widget _buildHomeView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 2, style: BorderStyle.none), // custom dashed style handled by padding
              ),
            ),
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Text(
                  '📖 내가 채워낸 소소한 날들 (${_notebooks.length})',
                  style: GoogleFonts.gaegu(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_notebooks.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Column(
              children: [
                SvgPicture.string(emptyIllustrationSvg, width: 100, height: 100),
                const SizedBox(height: 15),
                Text(
                  '"아무것도 그려지지 않은 빈 종이뿐이야."',
                  style: GoogleFonts.gaegu(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '첫 여행 수첩을 만들어 하루를 담아봐요.',
                  style: GoogleFonts.gaegu(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => setState(() => _currentView = 'add-notebook'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 3),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(5, 5))],
                    ),
                    child: Text(
                      '수첩 만들기 ✏️',
                      style: GoogleFonts.gaegu(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        else
          // 3-Column Bookshelf Grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(_notebooks.length, (index) {
              final book = _notebooks[index];
              return _buildBookCard(book, index);
            }),
          ),

        const SizedBox(height: 25),

        // Cozy Bottom Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFBF7),
            border: Border.all(color: Colors.black, width: 3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SvgPicture.string(bannerIllustrationSvg, width: 54, height: 54),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DRAW YOUR SOSO DAY',
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    Text(
                      '별일 아닌 듯 소소해서 소중한 기록들',
                      style: GoogleFonts.gaegu(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '당신의 모든 발걸음이 수첩 속 그림이 됩니다.',
                      style: GoogleFonts.gaegu(fontSize: 12, color: Colors.grey),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  String _formatShortDateWithYear(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      final yearShort = d.year.toString().substring(2); // e.g., '2026' -> '26'
      return '$yearShort.${d.month}.${d.day}';
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildBookCard(Notebook book, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - 32 - 24; // padding 32 + spacing 24
    final cardWidth = availableWidth / 3;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNotebook = book;
          _activePageIndex = 0;
          _currentView = 'notebook';
        });
      },
      onLongPress: () => _handleDeleteNotebook(book.id),
      child: Transform.rotate(
        angle: index % 2 == 0 ? -0.03 : 0.03,
        child: Container(
          width: cardWidth,
          height: 140,
          decoration: BoxDecoration(
            color: _parseColor(book.coverColor),
            border: Border.all(color: Colors.black, width: 3),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(3, 3)),
            ],
          ),
          child: Stack(
            children: [
              // Binding spine detail
              Positioned(
                left: 4,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 1,
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
              Positioned(
                left: 5,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  color: Colors.black.withOpacity(0.05),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 10, right: 6, top: 8, bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(book.coverEmoji, style: const TextStyle(fontSize: 18)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${book.pages.length}일',
                            style: GoogleFonts.gaegu(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                    Text(
                      book.title,
                      style: GoogleFonts.gaegu(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.1), width: 1)),
                      ),
                      child: Text(
                        '${_formatShortDateWithYear(book.startDate)}~${_formatShortDateWithYear(book.endDate)}',
                        style: GoogleFonts.gaegu(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // View 2: Add Notebook screen
  Widget _buildAddNotebookView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GestureDetector(
          onTap: () => setState(() => _currentView = 'home'),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '← 도화지 목록으로 돌아가기',
              style: GoogleFonts.gaegu(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(5, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📔 새 여행수첩 만들기',
                style: GoogleFonts.gaegu(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Title input
              Text('🏷️ 수첩 이름', style: GoogleFonts.gaegu(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 4),
              TextField(
                controller: _newTitleController,
                maxLength: 15,
                style: GoogleFonts.gaegu(fontSize: 18, color: Colors.black),
                decoration: InputDecoration(
                  hintText: '예) 제주도 푸른바람 🌴',
                  hintStyle: GoogleFonts.gaegu(fontSize: 16, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.black, width: 3),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 12),

              // Date input row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('출발 일자', style: GoogleFonts.gaegu(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _newStartController,
                          readOnly: true,
                          onTap: () => _pickDate(_newStartController),
                          style: GoogleFonts.gaegu(fontSize: 18, color: Colors.black),
                          decoration: InputDecoration(
                            hintText: '탭하여 선택',
                            hintStyle: GoogleFonts.gaegu(fontSize: 16, color: Colors.grey),
                            suffixIcon: const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
                            contentPadding: const EdgeInsets.all(8),
                            border: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8)),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('귀가 일자', style: GoogleFonts.gaegu(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _newEndController,
                          readOnly: true,
                          onTap: () => _pickDate(_newEndController),
                          style: GoogleFonts.gaegu(fontSize: 18, color: Colors.black),
                          decoration: InputDecoration(
                            hintText: '탭하여 선택',
                            hintStyle: GoogleFonts.gaegu(fontSize: 16, color: Colors.grey),
                            suffixIcon: const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
                            contentPadding: const EdgeInsets.all(8),
                            border: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8)),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),

              const SizedBox(height: 16),

              // Color choices
              Text('🎨 종이 질감 (표지 색)', style: GoogleFonts.gaegu(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PATTERN_OPTIONS.map((opt) {
                  final isSelected = _newColor == opt.value;
                  return GestureDetector(
                    onTap: () => setState(() => _newColor = opt.value),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _parseColor(opt.value),
                        border: Border.all(color: Colors.black, width: isSelected ? 3 : 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        opt.name,
                        style: GoogleFonts.gaegu(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Emoji choices
              Text('🧸 대표 스티커 (이모지)', style: GoogleFonts.gaegu(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: EMOJI_OPTIONS.map((emoji) {
                    final isSelected = _newEmoji == emoji;
                    return GestureDetector(
                      onTap: () => setState(() => _newEmoji = emoji),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(emoji, style: const TextStyle(fontSize: 18)),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Virtual Preview Box
              Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF9F5),
                    border: Border.all(color: Colors.black, width: 2, style: BorderStyle.solid), // dashed simulation
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '스케치북 가상 렌더',
                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 90,
                        height: 120,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _parseColor(_newColor),
                          border: Border.all(color: Colors.black, width: 3),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 2,
                              top: 0,
                              bottom: 0,
                              child: Container(width: 1, color: Colors.black.withOpacity(0.2)),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_newEmoji, style: const TextStyle(fontSize: 22)),
                                Text(
                                  _newTitleController.text.trim().isEmpty ? '나의 여행' : _newTitleController.text,
                                  style: GoogleFonts.gaegu(fontSize: 13, fontWeight: FontWeight.bold, height: 1.1),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Submit
              GestureDetector(
                onTap: _handleCreateNotebook,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '수첩 한 장 제작하기 📔',
                    style: GoogleFonts.gaegu(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  // View 3: Single Notebook detail page view
  Widget _buildNotebookView() {
    if (_selectedNotebook == null) return const SizedBox();

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Detect left-to-right swipe (positive velocity)
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          setState(() {
            _currentView = 'home';
          });
        }
      },
      child: Column(
        children: [
          // Inner Navbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.black, width: 3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _currentView = 'home'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                    ),
                    child: Text(
                      '← 책장',
                      style: GoogleFonts.gaegu(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                Column(
                  children: [
                    Text(
                      '${_selectedNotebook!.coverEmoji} ${_selectedNotebook!.title}',
                      style: GoogleFonts.gaegu(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_selectedNotebook!.startDate} ~ ${_selectedNotebook!.endDate}',
                      style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey),
                    )
                  ],
                ),

                // Placeholder to keep the header title centered
                const SizedBox(width: 50),
              ],
            ),
          ),

          // Daily page content occupying the rest of the screen directly!
          Expanded(
            child: _selectedNotebook!.pages.isEmpty
                ? _buildEmptyPagesView()
                : Stack(
                    children: [
                      // Render the page body directly
                      _buildLoadedPageBody(_activePageIndex),

                      // Left Edge Touch Area for Previous Page
                      if (_activePageIndex > 0)
                        Positioned(
                          left: 0,
                          top: 40,
                          bottom: 40,
                          width: 48,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              if (_activePageIndex > 0) {
                                setState(() {
                                  _activePageIndex--;
                                });
                              }
                            },
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.03),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.chevron_left,
                                  color: Colors.black26,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Right Edge Touch Area for Next Page
                      if (_activePageIndex < _selectedNotebook!.pages.length - 1)
                        Positioned(
                          right: 0,
                          top: 40,
                          bottom: 40,
                          width: 48,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              if (_activePageIndex < _selectedNotebook!.pages.length - 1) {
                                setState(() {
                                  _activePageIndex++;
                                });
                              }
                            },
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.03),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.black26,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),

          // Bottomday adder button
          if (_selectedNotebook!.pages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              child: GestureDetector(
                onTap: () {
                  final last = _selectedNotebook!.pages.last;
                  final lastDate = DateTime.parse(last.date);
                  final nextDate = lastDate.add(const Duration(days: 1));
                  final nextDateStr = nextDate.toString().split(' ')[0];
                  _resetPageForm();
                  setState(() {
                    _pageDateController.text = nextDateStr;
                    _currentView = 'add-page';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                  ),
                  child: Text(
                    '+ 다음 하루 스케치하기 (Day ${_selectedNotebook!.pages.length + 1})',
                    style: GoogleFonts.gaegu(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyPagesView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.string(notebookIconSvg, width: 50, height: 50),
          const SizedBox(height: 10),
          Text(
            '아직 스케치된 하루가 없어요!',
            style: GoogleFonts.gaegu(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '이 여정의 기억들을 한 장 한 장\n아름답고 심플하게 기록해 나가보세요.',
            style: GoogleFonts.gaegu(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              _resetPageForm();
              setState(() {
                _pageDateController.text = _selectedNotebook!.startDate;
                _currentView = 'add-page';
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
              ),
              child: Text(
                '+ 첫째 날 스케치 쓰기',
                style: GoogleFonts.gaegu(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLoadedPageBody(int pageIndex) {
    final page = _selectedNotebook!.pages[pageIndex];

    return Stack(
      children: [
        // Lined Page decoration background
        CustomPaint(
          size: Size.infinite,
          painter: NotebookLinesPainter(),
        ),

        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Page Topbar (Edit/Delete controls)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Day ${page.dayNum}',
                      style: GoogleFonts.gaegu(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: GestureDetector(
                      onTap: () => _startEditingPage(page),
                      child: const Text('✏️ 고치기', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 8),

              // 1. Title Header inside the sheet: Rabbit - "여행기" - Tiger
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.string(rabbitHeaderSvg, width: 50, height: 50),
                    Text(
                      '여 행 기',
                      style: GoogleFonts.gaegu(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 4.0,
                      ),
                    ),
                    SvgPicture.string(tigerHeaderSvg, width: 50, height: 50),
                  ],
                ),
              ),

              // 2. Metadata Boxes ("언제", "어디", "누구랑")
              Row(
                children: [
                  _buildMetadataBox('언 제', page.date),
                  const SizedBox(width: 8),
                  _buildMetadataBox('어 디', page.place),
                  const SizedBox(width: 8),
                  _buildMetadataBox('누구랑', page.people),
                ],
              ),

              // 3. Dashed line Separator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(15, (index) {
                    return Container(
                      width: 12,
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                    );
                  }),
                ),
              ),

              // 4. Main Note Area (Lined entries) & Bottom Speech Bubble
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildNoteRow('한 것', page.done),
                    const SizedBox(height: 14),
                    _buildNoteRow('먹은 것', page.eaten),
                    const SizedBox(height: 14),
                    _buildNoteRow('산 것', page.bought),
                    const SizedBox(height: 14),

                    // 여행별점
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '여행별점',
                          style: GoogleFonts.gaegu(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildStars(page.rating, size: 28),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Speech bubble with Rabbit
                    _buildSpeechBubbleSection(page),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              // Day Page Navigator Bar
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.black, width: 2.5)),
                ),
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_activePageIndex > 0) {
                          setState(() {
                            _activePageIndex--;
                          });
                        }
                      },
                      child: Opacity(
                        opacity: _activePageIndex == 0 ? 0.3 : 1.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '← 이전 장',
                            style: GoogleFonts.gaegu(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),

                    Text(
                      '${_activePageIndex + 1} / ${_selectedNotebook!.pages.length} PAGES',
                      style: GoogleFonts.gaegu(fontSize: 12, fontWeight: FontWeight.bold),
                    ),

                    GestureDetector(
                      onTap: () {
                        if (_activePageIndex < _selectedNotebook!.pages.length - 1) {
                          setState(() {
                            _activePageIndex++;
                          });
                        }
                      },
                      child: Opacity(
                        opacity: _activePageIndex == _selectedNotebook!.pages.length - 1 ? 0.3 : 1.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '다음 장 →',
                            style: GoogleFonts.gaegu(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildMetadataBox(String title, String value) {
    return Expanded(
      child: CustomPaint(
        painter: DoodleBoxPainter(),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(vertical: 4),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.gaegu(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  value.isEmpty ? '-' : value,
                  style: GoogleFonts.gaegu(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteRow(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.gaegu(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            content.isEmpty ? '기록하지 않았습니다.' : content,
            style: GoogleFonts.gaegu(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(0.85),
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeechBubbleSection(NotebookPage page) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Rabbit poking up from the left
        SvgPicture.string(
          rabbitMemoSvg,
          width: 50,
          height: 50,
        ),
        const SizedBox(width: 8),
        // Speech Bubble
        Expanded(
          child: CustomPaint(
            painter: DoodleSpeechBubblePainter(),
            child: Container(
              padding: const EdgeInsets.only(left: 18, right: 14, top: 12, bottom: 20),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  page.notes.isEmpty ? '오늘 하루도 몽글몽글하고 소중했어. 🐰' : page.notes,
                  style: GoogleFonts.gaegu(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
                if (page.images.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: page.images.length,
                      itemBuilder: (context, idx) {
                        final imgStr = page.images[idx];
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Container(
                            width: 60,
                            height: 60,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 1.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: Image.memory(
                                base64Decode(imgStr.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '')),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ]
              ],
            ),
          ),
        ),
      )
    ],
  );
  }

  // View 4 & 5: Add / Edit page entry screen
  Widget _buildAddPageView({required bool isEdit}) {
    if (_selectedNotebook == null) return const SizedBox();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        GestureDetector(
          onTap: () {
            _resetPageForm();
            setState(() => _currentView = 'notebook');
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              isEdit ? '← 수정 취소하고 돌려놓기' : '← 일기장 속지로 돌아가기',
              style: GoogleFonts.gaegu(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
        ),

        // Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              isEdit ? '📝 하루의 잉크 고쳐쓰기' : '✍️ Day ${_selectedNotebook!.pages.length + 1} 기억 긋기',
              style: GoogleFonts.gaegu(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              color: isEdit ? Colors.grey.shade800 : Colors.black,
              child: Text(
                isEdit ? 'EDIT' : 'ADD',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),

        const SizedBox(height: 20),

        // Date
        Text('언 제', style: GoogleFonts.gaegu(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
        TextField(
          controller: _pageDateController,
          readOnly: true,
          onTap: () => _pickDate(_pageDateController),
          style: GoogleFonts.gaegu(fontSize: 20, color: Colors.black),
          decoration: InputDecoration(
            hintText: '탭하여 날짜 선택',
            hintStyle: GoogleFonts.gaegu(fontSize: 18, color: Colors.grey.shade400),
            suffixIcon: const Icon(Icons.calendar_today, size: 20, color: Colors.black54),
            border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.5)),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black54, width: 1.5)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2.5)),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),

        const SizedBox(height: 20),

        // Place / Who
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('어 디', style: GoogleFonts.gaegu(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
                  TextField(
                    controller: _pagePlaceController,
                    style: GoogleFonts.gaegu(fontSize: 20, color: Colors.black),
                    decoration: InputDecoration(
                      hintText: '예) 아라시야마',
                      hintStyle: GoogleFonts.gaegu(fontSize: 18, color: Colors.grey.shade400),
                      border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.5)),
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black54, width: 1.5)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2.5)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('누구랑', style: GoogleFonts.gaegu(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
                  TextField(
                    controller: _pagePeopleController,
                    style: GoogleFonts.gaegu(fontSize: 20, color: Colors.black),
                    decoration: InputDecoration(
                      hintText: '예) 나 혼자서',
                      hintStyle: GoogleFonts.gaegu(fontSize: 18, color: Colors.grey.shade400),
                      border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.5)),
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black54, width: 1.5)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2.5)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),

        // Dashed line separator
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(15, (index) {
              return Container(
                width: 12,
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              );
            }),
          ),
        ),

        // 한 것
        Text('한 것', style: GoogleFonts.gaegu(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
        TextField(
          controller: _pageDoneController,
          maxLines: null,
          maxLength: 120,
          style: GoogleFonts.gaegu(fontSize: 20, color: Colors.black),
          decoration: InputDecoration(
            hintText: '오늘 한 일을 적어주세요',
            hintStyle: GoogleFonts.gaegu(fontSize: 18, color: Colors.grey.shade400),
            border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.5)),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black54, width: 1.5)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2.5)),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            counterStyle: GoogleFonts.gaegu(fontSize: 11, color: Colors.grey),
          ),
        ),

        const SizedBox(height: 16),

        // 먹은 것
        Text('먹은 것', style: GoogleFonts.gaegu(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
        TextField(
          controller: _pageEatenController,
          maxLines: null,
          maxLength: 120,
          style: GoogleFonts.gaegu(fontSize: 20, color: Colors.black),
          decoration: InputDecoration(
            hintText: '오늘 먹은 것을 적어주세요',
            hintStyle: GoogleFonts.gaegu(fontSize: 18, color: Colors.grey.shade400),
            border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.5)),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black54, width: 1.5)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2.5)),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            counterStyle: GoogleFonts.gaegu(fontSize: 11, color: Colors.grey),
          ),
        ),

        const SizedBox(height: 16),

        // 산 것
        Text('산 것', style: GoogleFonts.gaegu(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
        TextField(
          controller: _pageBoughtController,
          maxLines: null,
          maxLength: 120,
          style: GoogleFonts.gaegu(fontSize: 20, color: Colors.black),
          decoration: InputDecoration(
            hintText: '오늘 산 것을 적어주세요',
            hintStyle: GoogleFonts.gaegu(fontSize: 18, color: Colors.grey.shade400),
            border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.5)),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black54, width: 1.5)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2.5)),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            counterStyle: GoogleFonts.gaegu(fontSize: 11, color: Colors.grey),
          ),
        ),

        const SizedBox(height: 16),

        // 여행별점 — inline row matching reading view
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('여행별점', style: GoogleFonts.gaegu(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(width: 12),
            _buildStars(_pageRating, onChange: (val) => setState(() => _pageRating = val), size: 28),
          ],
        ),

        const SizedBox(height: 20),

        // 💬 더 하고 싶은 말
        Text('💬 더 하고 싶은 말', style: GoogleFonts.gaegu(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
        TextField(
          controller: _pageNotesController,
          maxLines: null,
          maxLength: 150,
          style: GoogleFonts.gaegu(fontSize: 20, color: Colors.black),
          decoration: InputDecoration(
            hintText: '이 날의 특별한 감상을 적어주세요',
            hintStyle: GoogleFonts.gaegu(fontSize: 18, color: Colors.grey.shade400),
            border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.5)),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black54, width: 1.5)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2.5)),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            counterStyle: GoogleFonts.gaegu(fontSize: 11, color: Colors.grey),
          ),
        ),

        const SizedBox(height: 20),

        // 📸 사진 보관
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('📸 사진 보관', style: GoogleFonts.gaegu(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
            Text('${_pageImages.length}/3장', style: GoogleFonts.gaegu(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ...List.generate(_pageImages.length, (idx) {
              final imgStr = _pageImages[idx];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.memory(
                          base64Decode(imgStr.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '')),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _removeSelectedImage(idx),
                          child: Container(
                            color: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            child: const Text('X', style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
            if (_pageImages.length < 3)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt_outlined, size: 20, color: Colors.grey),
                      Text('추가', style: GoogleFonts.gaegu(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
          ],
        ),

        const SizedBox(height: 28),

        // Save button
        GestureDetector(
          onTap: isEdit ? _handleUpdatePage : _handleCreatePage,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              isEdit ? '기록 수정 완료하기 ✏️' : '하루 스케치 저장하기 🖋️',
              style: GoogleFonts.gaegu(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  // Footer Widget
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black12, style: BorderStyle.none)), // handled by margin
      ),
      child: const Center(
        child: Text(
          '© 2026 MONGLE NOTE. ILLUSTRATED BY @INAPSQUARE STYLE',
          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ),
    );
  }

  // View 6: Custom Dialog matching the hand-drawn sketch theme
  Widget _buildCustomDialog() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.4),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(5, 5))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Shaky exclamation circle
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 10),

              Text(
                _dialogMsg,
                style: GoogleFonts.gaegu(fontSize: 16, fontWeight: FontWeight.bold, height: 1.2),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_dialogType == 'confirm') ...[
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_dialogOnConfirm != null) _dialogOnConfirm!();
                          setState(() => _dialogShow = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '확인',
                            style: GoogleFonts.gaegu(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _dialogShow = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '취소',
                            style: GoogleFonts.gaegu(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                      ),
                    )
                  ] else
                    GestureDetector(
                      onTap: () => setState(() => _dialogShow = false),
                      child: Container(
                        width: 120,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '확인',
                          style: GoogleFonts.gaegu(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DoodleBoxPainter extends CustomPainter {
  final Color strokeColor;
  final Color fillColor;
  final double strokeWidth;

  DoodleBoxPainter({
    this.strokeColor = Colors.black,
    this.fillColor = Colors.white,
    this.strokeWidth = 2.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, w - 4, h - 4),
      const Radius.circular(8),
    );
    canvas.drawRRect(rrect, fillPaint);

    final path = Path();
    path.moveTo(4, 3);
    path.quadraticBezierTo(w * 0.5, 1, w - 3, 4);
    path.quadraticBezierTo(w - 1, h * 0.5, w - 4, h - 3);
    path.quadraticBezierTo(w * 0.5, h - 1, 3, h - 4);
    path.quadraticBezierTo(1, h * 0.5, 4, 3);
    canvas.drawPath(path, strokePaint);

    // Secondary overlap line to enhance hand-drawn feel
    final path2 = Path();
    path2.moveTo(6, 4);
    path2.quadraticBezierTo(w * 0.5, 2, w - 4, 3.5);
    path2.quadraticBezierTo(w - 2, h * 0.5, w - 3, h - 5);
    canvas.drawPath(path2, strokePaint..strokeWidth = strokeWidth * 0.6);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DoodleSpeechBubblePainter extends CustomPainter {
  final Color strokeColor;
  final Color fillColor;
  final double strokeWidth;

  DoodleSpeechBubblePainter({
    this.strokeColor = Colors.black,
    this.fillColor = Colors.white,
    this.strokeWidth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(14, 4);
    path.quadraticBezierTo(w * 0.5, 1, w - 10, 5);
    path.quadraticBezierTo(w - 2, 4, w - 4, 14);
    path.quadraticBezierTo(w - 1, h * 0.5, w - 5, h - 14);
    path.quadraticBezierTo(w - 3, h - 10, w - 14, h - 12);
    path.quadraticBezierTo(w * 0.5, h - 9, 24, h - 12);
    path.lineTo(6, h - 2); // tail tip pointing down-left
    path.lineTo(16, h - 22);
    path.quadraticBezierTo(10, h * 0.5, 14, 4);

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Secondary sketch line
    final path2 = Path();
    path2.moveTo(16, 6);
    path2.quadraticBezierTo(w * 0.5, 3, w - 12, 7);
    path2.quadraticBezierTo(w - 4, h * 0.5, w - 7, h - 16);
    canvas.drawPath(path2, strokePaint..strokeWidth = strokeWidth * 0.6);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

