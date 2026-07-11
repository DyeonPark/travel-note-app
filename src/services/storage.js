import AsyncStorage from '@react-native-async-storage/async-storage';

const STORAGE_KEY = '@travel_notes_key';

// Sample initial notes to populate the database when it's first loaded
const initialNotes = [
  {
    id: 'sample-1',
    when: '2026.05.10',
    where: '제주도 애월읍',
    who: '고등학교 친구들',
    activities: '바다 보며 해안도로 드라이브하기\n유채꽃 밭에서 예쁜 인생사진 남기기\n밤하늘 은하수랑 별 구경하기!',
    food: '두툼한 흑돼지 오겹살 구이\n뜨끈한 고기국수 & 칼칼한 갈치조림\n디저트로 달콤 시원한 한라봉 에이드 🍊',
    shopping: '감귤 초콜릿 & 오메기떡 한 박스\n소품샵에서 산 귀여운 돌하르방 귤 모자 키링',
    rating: 5,
    memo: '날씨가 정말 맑고 따뜻해서 완벽했던 제주 여행! 바람 부는 바다를 걷는 것만으로도 완전 힐링이었다. 다음에는 우도에도 꼭 들어가 봐야지! 🌊☀️',
    createdAt: Date.now() - 100000
  },
  {
    id: 'sample-2',
    when: '2026.06.20',
    where: '경주 황리단길',
    who: '가족이랑 다 함께',
    activities: '대릉원 돌담길 걷고 첨성대 야경 투어하기\n대여한 자전거로 유적지 구석구석 돌기\n황리단길 예쁜 한옥 카페에서 쉬어가기',
    food: '고소하고 달달한 황남 십원빵 🧀\n정갈하게 나오는 쌈밥 한정식\n로컬 크래프트 맥주 한 잔',
    shopping: '쫀득한 경주 찰보리빵이랑 경주빵\n동궁과 월지 풍경이 담긴 감성 엽서 세트',
    rating: 4,
    memo: '첨성대 핑크뮬리랑 밤에 불 켜진 풍경은 정말 아름다웠다. 낮에는 조금 더웠지만 시원한 바람이 불어서 걷기 참 좋은 주말이었다. 🌙✨',
    createdAt: Date.now()
  }
];

/**
 * Loads all travel notes from local storage.
 * If no notes exist, populates storage with initial sample notes.
 */
export const loadNotes = async () => {
  try {
    const jsonValue = await AsyncStorage.getItem(STORAGE_KEY);
    if (jsonValue !== null) {
      return JSON.parse(jsonValue);
    } else {
      // First time loading - initialize with sample data
      await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(initialNotes));
      return initialNotes;
    }
  } catch (error) {
    console.error('Failed to load notes from storage:', error);
    // Return sample notes as fallback
    return initialNotes;
  }
};

/**
 * Saves a single note. If it has an existing id, updates it.
 * Otherwise, creates a new note with a unique id.
 */
export const saveNote = async (noteToSave, currentNotes = []) => {
  try {
    let updatedNotes;
    
    if (noteToSave.id) {
      // Update existing note
      updatedNotes = currentNotes.map(n => n.id === noteToSave.id ? noteToSave : n);
    } else {
      // Create new note
      const newNote = {
        ...noteToSave,
        id: `note-${Date.now()}`,
        createdAt: Date.now()
      };
      updatedNotes = [newNote, ...currentNotes];
    }
    
    await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(updatedNotes));
    return updatedNotes;
  } catch (error) {
    console.error('Failed to save note to storage:', error);
    throw error;
  }
};

/**
 * Deletes a note by its unique ID.
 */
export const deleteNote = async (id, currentNotes = []) => {
  try {
    const updatedNotes = currentNotes.filter(n => n.id !== id);
    await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(updatedNotes));
    return updatedNotes;
  } catch (error) {
    console.error('Failed to delete note from storage:', error);
    throw error;
  }
};
