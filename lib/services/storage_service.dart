import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notebook.dart';

class StorageService {
  static const String _storageKey = 'mongle_notebooks_key';

  // Sample initial notebooks from the canvas demo
  static final List<Notebook> _initialNotebooks = [
    Notebook(
      id: 'jeju-2026',
      title: '제주바람 🌴',
      startDate: '2026-05-12',
      endDate: '2026-05-14',
      coverColor: '#FFFFFF', // 흰 수첩
      coverEmoji: '🌴',
      rating: 5,
      pages: [
        NotebookPage(
          id: 'p1',
          dayNum: 1,
          date: '2026-05-12',
          place: '함덕 해변 & 델문도',
          people: '가족들과',
          rating: 5,
          done: '첫날 도착하자마자 에메랄드빛 바다로 달려갔다! 파도가 부드럽게 발을 감싸안아 주어 참 푸근했다.',
          eaten: '제주 흑돼지 구이를 먹었다. 짭조름한 멜젓에 콕 찍어 두툼한 고기를 씹으니 육즙이 퍼졌다.',
          bought: '아기자기한 동네 소품샵에 들러 귤 모양이 달린 귀여운 털모자 볼펜을 한 자루 데려왔다.',
          notes: '첫날이라 긴장 반 설렘 반으로 출발했는데, 공항에서 나오자마자 불어온 제주 바람에 모든 피로가 싹 씻겨 나갔다. 정말 행복하다!',
          images: [],
        ),
        NotebookPage(
          id: 'p2',
          dayNum: 2,
          date: '2026-05-13',
          place: '비자림 숲',
          people: '가족들과',
          rating: 4,
          done: '아침 일찍 피톤치드 가득한 비자림을 천천히 산책했다. 비 온 뒤라 촉촉하고 향기로운 숲이었다.',
          eaten: '평대 바다를 내다보며 고소한 전복돌솥밥을 싹싹 비볐다. 마지막 숭늉까지 아주 훌륭했다.',
          bought: '제주 한라봉으로 직접 만든 수제 달콤 잼을 한 병 샀다. 아침 빵 식사에 발라 먹을 생각이다.',
          notes: '촉촉한 숲 향이 가득했던 비자림 산책은 잊을 수 없을 것 같다. 가족들과 도란도란 나눈 이야기도 가슴 한구석에 깊이 새겨졌다.',
          images: [],
        )
      ]
    ),
    Notebook(
      id: 'kyoto-2025',
      title: '교토 산책 🍵',
      startDate: '2025-11-03',
      endDate: '2025-11-05',
      coverColor: '#FFFDF0', // 바나나 크림
      coverEmoji: '🍵',
      rating: 4,
      pages: [
        NotebookPage(
          id: 'k1',
          dayNum: 1,
          date: '2025-11-03',
          place: '대나무 숲길',
          people: '나 혼자서',
          rating: 4,
          done: '바람이 불 때마다 사락거리는 푸른 대나무 소리가 귀를 간지럽혔다. 아주 차분하고 평화로웠다.',
          eaten: '소박하고 아담한 찻집에서 따뜻한 연두빛 말차와 쫀득쫀득하고 달달한 당고를 맛있게 맛봤다.',
          bought: '은은한 은빛이 도는 대나무로 세밀하게 엮어 만든 가벼운 미니 책갈피를 선물용으로 구입했다.',
          notes: '대나무 숲은 신비로운 초록색 터널 같았다. 바람 소리밖에 들리지 않는 고요함 속에서 오랜만에 깊은 내면의 여유를 가질 수 있었다.',
          images: [],
        )
      ]
    ),
    Notebook(
      id: 'busan-2026',
      title: '부산 일기 🌊',
      startDate: '2026-03-01',
      endDate: '2026-03-03',
      coverColor: '#FFFFFF',
      coverEmoji: '🌊',
      rating: 5,
      pages: []
    ),
    Notebook(
      id: 'camping-2026',
      title: '불멍 캠핑 🏕️',
      startDate: '2026-04-10',
      endDate: '2026-04-12',
      coverColor: '#F4F2EE', // 미색 갱지
      coverEmoji: '🏕️',
      rating: 5,
      pages: []
    )
  ];

  /// Loads all notebooks. Initializes with mock data if storage is empty.
  Future<List<Notebook>> loadNotebooks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonValue = prefs.getString(_storageKey);
      if (jsonValue != null && jsonValue.isNotEmpty) {
        final List<dynamic> decoded = json.decode(jsonValue);
        return decoded.map((x) => Notebook.fromMap(x)).toList();
      } else {
        // Initialize storage with sample data on first launch
        await saveAllNotebooks(_initialNotebooks);
        return _initialNotebooks;
      }
    } catch (e) {
      print('Error loading notebooks: $e');
      return _initialNotebooks;
    }
  }

  /// Overwrites the entire list of notebooks in storage.
  Future<void> saveAllNotebooks(List<Notebook> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(list.map((x) => x.toMap()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      print('Error saving notebooks: $e');
      rethrow;
    }
  }
}
