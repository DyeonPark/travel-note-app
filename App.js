import React, { useState, useEffect } from 'react';
import { 
  StyleSheet, 
  Text, 
  View, 
  ScrollView, 
  TextInput, 
  TouchableOpacity, 
  Modal, 
  Alert, 
  SafeAreaView, 
  StatusBar,
  KeyboardAvoidingView,
  Platform
} from 'react-native';
import { useFonts, Gaegu_400Regular, Gaegu_700Bold } from '@expo-google-fonts/gaegu';
import * as SplashScreen from 'expo-splash-screen';
import Svg, { Path, Circle, Ellipse } from 'react-native-svg';
import { loadNotes, saveNote, deleteNote } from './src/services/storage';

// Keep splash screen visible while loading fonts
SplashScreen.preventAutoHideAsync();

// Sketchy Star SVG Icon for React Native
const SketchyStar = ({ filled, onClick, size = 24 }) => {
  const path = "M12 2.5 C12.3 2.5 12.8 4.2 13 4.8 C13.3 5.7 14.8 8 15.3 8.3 C15.8 8.6 18.2 8.6 19.5 8.8 C20.8 9 22.2 9.2 21.8 10 C21.4 10.8 19.2 12.5 18.7 13 C18.2 13.5 18.3 15.2 18.5 16.5 C18.7 17.8 18.8 19.5 18 20 C17.2 20.5 15.2 19 13.8 18.2 C12.4 17.4 11.6 17.4 10.2 18.2 C8.8 19 6.8 20.5 6 20 C5.2 19.5 5.3 17.8 5.5 16.5 C5.7 15.2 5.8 13.5 5.3 13 C4.8 12.5 2.6 10.8 2.2 10 C1.8 9.2 3.2 9 4.5 8.8 C5.8 8.6 8.2 8.6 8.7 8.3 C9.2 8 10.7 5.7 11 4.8 C11.2 4.2 11.7 2.5 12 2.5 Z";
  
  if (onClick) {
    return (
      <TouchableOpacity onPress={onClick} activeOpacity={0.7} style={styles.starTouch}>
        <Svg width={size} height={size} viewBox="0 0 24 24" fill={filled ? '#1a1a1a' : 'none'}>
          <Path 
            d={path} 
            stroke="#1a1a1a" 
            strokeWidth={2.5} 
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </Svg>
      </TouchableOpacity>
    );
  }

  return (
    <View style={styles.starIcon}>
      <Svg width={size} height={size} viewBox="0 0 24 24" fill={filled ? '#1a1a1a' : 'none'}>
        <Path 
          d={path} 
          stroke="#1a1a1a" 
          strokeWidth={2.5} 
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </Svg>
    </View>
  );
};

// SVG: Rabbit Header Doodle
const RabbitHeaderDoodle = () => (
  <Svg width={42} height={42} viewBox="0 0 100 100" fill="none">
    <Path d="M 35,45 C 28,15 42,15 45,45" stroke="#1a1a1a" strokeWidth={3} strokeLinecap="round" strokeLinejoin="round" />
    <Path d="M 65,45 C 72,15 58,15 55,45" stroke="#1a1a1a" strokeWidth={3} strokeLinecap="round" strokeLinejoin="round" />
    <Path d="M 26,68 C 26,50 74,50 74,68 C 74,86 26,86 26,68 Z" stroke="#1a1a1a" strokeWidth={3} strokeLinecap="round" strokeLinejoin="round" fill="#fff" />
    <Path d="M 44,48 C 45,43 55,43 56,48 L 54,54 L 46,54 Z" fill="#ffe3e3" stroke="#1a1a1a" strokeWidth={3} strokeLinecap="round" strokeLinejoin="round" />
    <Circle cx="40" cy="65" r="2.5" fill="#1a1a1a" />
    <Circle cx="60" cy="65" r="2.5" fill="#1a1a1a" />
    <Path d="M 48,70 C 49,71 50,72 50,72 C 50,72 51,71 52,70 M 50,72 L 50,75" stroke="#1a1a1a" strokeWidth={3} strokeLinecap="round" strokeLinejoin="round" />
    <Ellipse cx="34" cy="71" rx="4" ry="2" fill="#ffb6c1" />
    <Ellipse cx="66" cy="71" rx="4" ry="2" fill="#ffb6c1" />
  </Svg>
);

// SVG: Tiger Header Doodle
const TigerHeaderDoodle = () => (
  <Svg width={42} height={42} viewBox="0 0 100 100" fill="none">
    <Path d="M 23,60 C 23,38 77,38 77,60 C 77,82 23,82 23,60 Z" stroke="#1a1a1a" strokeWidth={3} strokeLinecap="round" strokeLinejoin="round" fill="#fff" />
    <Path d="M 28,43 C 22,35 33,26 38,40" stroke="#1a1a1a" strokeWidth={3} strokeLinecap="round" strokeLinejoin="round" fill="#fff" />
    <Path d="M 72,43 C 78,35 67,26 62,40" stroke="#1a1a1a" strokeWidth={3} strokeLinecap="round" strokeLinejoin="round" fill="#fff" />
    <Path d="M 24,58 L 32,58 M 25,64 L 31,63" stroke="#1a1a1a" strokeWidth={3} strokeLinecap="round" />
    <Path d="M 76,58 L 68,58 M 75,64 L 69,63" stroke="#1a1a1a" strokeWidth={3} strokeLinecap="round" />
    <Path d="M 45,42 L 45,47 M 50,41 L 50,48 M 55,42 L 55,47" stroke="#1a1a1a" strokeWidth={3} strokeLinecap="round" />
    <Circle cx="39" cy="58" r="2.5" fill="#1a1a1a" />
    <Circle cx="61" cy="58" r="2.5" fill="#1a1a1a" />
    <Path d="M 47,65 L 53,65 L 50,68 Z" fill="#1a1a1a" />
    <Path d="M 50,68 C 48,71 47,72 49,73 M 50,68 C 52,71 53,72 51,73" stroke="#1a1a1a" strokeWidth={3} strokeLinecap="round" />
    <Path d="M 43,76 L 57,76 L 57,86 L 43,86 Z" stroke="#1a1a1a" strokeWidth={3} strokeLinecap="round" strokeLinejoin="round" fill="#fff3c4" />
    <Circle cx="50" cy="81" r="3.5" stroke="#1a1a1a" strokeWidth={3} fill="#fff" />
    <Path d="M 46,76 L 48,72 L 52,72 L 54,76" stroke="#1a1a1a" strokeWidth={3} strokeLinecap="round" strokeLinejoin="round" />
  </Svg>
);

// SVG: Rabbit Memo Doodle
const RabbitMemoDoodle = () => (
  <Svg width={54} height={54} viewBox="0 0 100 100" fill="none">
    <Path d="M 18,85 C 18,35 82,35 82,85" stroke="#1a1a1a" strokeWidth={3} strokeLinecap="round" strokeLinejoin="round" fill="#fff" />
    <Path d="M 30,42 C 24,8 38,8 42,40" stroke="#1a1a1a" strokeWidth={3} strokeLinecap="round" strokeLinejoin="round" fill="#fff" />
    <Path d="M 70,42 C 76,8 62,8 58,40" stroke="#1a1a1a" strokeWidth={3} strokeLinecap="round" strokeLinejoin="round" fill="#fff" />
    <Path d="M 31,39 C 27,15 35,15 37,36" stroke="#1a1a1a" strokeWidth={1.5} strokeLinecap="round" />
    <Path d="M 69,39 C 73,15 65,15 63,36" stroke="#1a1a1a" strokeWidth={1.5} strokeLinecap="round" />
    <Circle cx="40" cy="62" r="3.5" fill="#1a1a1a" />
    <Circle cx="60" cy="62" r="3.5" fill="#1a1a1a" />
    <Path d="M 48,68 C 49,69 50,70 50,70 C 50,70 51,69 52,68" stroke="#1a1a1a" strokeWidth={3} strokeLinecap="round" strokeLinejoin="round" />
    <Path d="M 46,73 C 48,75 50,75 50,73 C 50,75 52,75 54,73" stroke="#1a1a1a" strokeWidth={3} strokeLinecap="round" strokeLinejoin="round" />
    <Ellipse cx="32" cy="68" rx="5" ry="2.5" fill="#ffb6c1" />
    <Ellipse cx="68" cy="68" rx="5" ry="2.5" fill="#ffb6c1" />
  </Svg>
);

export default function App() {
  const [fontsLoaded] = useFonts({
    Gaegu_400Regular,
    Gaegu_700Bold,
  });

  const [notes, setNotes] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [activeNote, setActiveNote] = useState(null);
  const [isEditing, setIsEditing] = useState(false);
  const [editFormData, setEditFormData] = useState({
    id: '',
    when: '',
    where: '',
    who: '',
    activities: '',
    food: '',
    shopping: '',
    rating: 5,
    memo: ''
  });

  // Load notes initially
  useEffect(() => {
    async function init() {
      if (fontsLoaded) {
        const loadedNotes = await loadNotes();
        setNotes(loadedNotes);
        await SplashScreen.hideAsync();
      }
    }
    init();
  }, [fontsLoaded]);

  if (!fontsLoaded) {
    return null;
  }

  // Open note details (view mode)
  const handleViewNote = (note) => {
    setActiveNote(note);
    setIsEditing(false);
  };

  // Open new note form
  const handleNewNote = () => {
    const today = new Date();
    const formattedDate = `${today.getFullYear()}.${String(today.getMonth() + 1).padStart(2, '0')}.${String(today.getDate()).padStart(2, '0')}`;
    const newForm = {
      id: '',
      when: formattedDate,
      where: '',
      who: '',
      activities: '',
      food: '',
      shopping: '',
      rating: 5,
      memo: ''
    };
    setEditFormData(newForm);
    setActiveNote(newForm);
    setIsEditing(true);
  };

  // Open edit mode for active note
  const handleEditNote = () => {
    setEditFormData({ ...activeNote });
    setIsEditing(true);
  };

  // Save/Update note
  const handleSaveNote = async () => {
    if (!editFormData.where.trim()) {
      Alert.alert('알림', '어디로 여행을 다녀오셨는지 적어주세요! (어디)');
      return;
    }

    try {
      const updatedNotes = await saveNote(editFormData, notes);
      setNotes(updatedNotes);
      
      // Update the active note viewer
      if (editFormData.id) {
        setActiveNote(editFormData);
      } else {
        // Find the newly created note (first one in array)
        setActiveNote(updatedNotes[0]);
      }
      setIsEditing(false);
    } catch (e) {
      Alert.alert('오류', '여행기 저장에 실패했습니다.');
    }
  };

  // Delete note
  const handleDeleteNote = (id) => {
    Alert.alert(
      '여행기 삭제',
      '정말 이 여행기를 지우시겠어요? 😢',
      [
        { text: '취소', style: 'cancel' },
        { 
          text: '삭제', 
          style: 'destructive',
          onPress: async () => {
            try {
              const updated = await deleteNote(id, notes);
              setNotes(updated);
              setActiveNote(null);
            } catch (e) {
              Alert.alert('오류', '삭제에 실패했습니다.');
            }
          }
        }
      ]
    );
  };

  // Filter notes based on search query
  const filteredNotes = notes.filter(note => {
    const query = searchQuery.toLowerCase();
    return (
      note.where.toLowerCase().includes(query) ||
      note.when.toLowerCase().includes(query) ||
      (note.who && note.who.toLowerCase().includes(query)) ||
      note.activities.toLowerCase().includes(query) ||
      note.food.toLowerCase().includes(query) ||
      note.shopping.toLowerCase().includes(query) ||
      note.memo.toLowerCase().includes(query)
    );
  });

  // Utility to tilt cards slightly for shaky paper card effect
  const getCardRotation = (index) => {
    const tilts = ['-1.5deg', '1.2deg', '-1deg', '1.8deg'];
    return tilts[index % tilts.length];
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <StatusBar barStyle="dark-content" backgroundColor="#eae6db" />
      
      <View style={styles.container}>
        {/* App Title */}
        <View style={styles.header}>
          <Text style={styles.appTitle}>✈️ 나의 여행기 ✍️</Text>
          <Text style={styles.appSubtitle}>추억 가득한 소중한 기록들</Text>
        </View>

        {/* Search and Action Bar */}
        <View style={styles.controlsBar}>
          <View style={[styles.searchBox, styles.sketchyBorderThin]}>
            <TextInput 
              style={styles.searchInput}
              placeholder="돋보기: 언제, 어디로, 누구랑..." 
              placeholderTextColor="#999"
              value={searchQuery}
              onChangeText={setSearchQuery}
            />
          </View>
          <TouchableOpacity 
            style={[styles.btnAdd, styles.sketchyBorderThin]} 
            onPress={handleNewNote}
            activeOpacity={0.8}
          >
            <Text style={styles.btnAddText}>✏️ 새 여행기</Text>
          </TouchableOpacity>
        </View>

        {/* Cards Scroll List */}
        <ScrollView 
          contentContainerStyle={styles.scrollContent} 
          showsVerticalScrollIndicator={false}
        >
          {filteredNotes.length > 0 ? (
            <View style={styles.cardsContainer}>
              {filteredNotes.map((note, index) => (
                <TouchableOpacity 
                  key={note.id}
                  style={[
                    styles.noteCard, 
                    styles.sketchyBorder,
                    { transform: [{ rotate: getCardRotation(index) }] }
                  ]}
                  onPress={() => handleViewNote(note)}
                  activeOpacity={0.9}
                >
                  <View style={styles.cardHeader}>
                    <Text style={styles.cardDate}>{note.when}</Text>
                    <View style={styles.cardRating}>
                      {[1, 2, 3, 4, 5].map((star) => (
                        <SketchyStar 
                          key={star} 
                          filled={star <= note.rating} 
                          size={15} 
                        />
                      ))}
                    </View>
                  </View>
                  <Text style={styles.cardLocation} numberOfLines={1}>📍 {note.where}</Text>
                  {note.who ? <Text style={styles.cardWho} numberOfLines={1}>with. {note.who}</Text> : null}
                  <Text style={styles.cardPreview} numberOfLines={3}>{note.activities}</Text>
                  
                  <View style={styles.cardDivider} />
                  <View style={styles.cardFooter}>
                    <Text style={styles.cardTag}>여행 추억</Text>
                  </View>
                </TouchableOpacity>
              ))}
            </View>
          ) : (
            <View style={[styles.emptyState, styles.sketchyBorder]}>
              <Text style={styles.emptyText}>아직 기록된 여행기가 없어요! 😢</Text>
              <TouchableOpacity 
                style={[styles.btnAdd, styles.sketchyBorderThin, { marginTop: 15 }]} 
                onPress={handleNewNote}
              >
                <Text style={styles.btnAddText}>첫 여행기 쓰러 가기</Text>
              </TouchableOpacity>
            </View>
          )}
        </ScrollView>
      </View>

      {/* Postcard Viewer & Editor Modal */}
      {activeNote !== null && (
        <Modal
          visible={activeNote !== null}
          transparent={true}
          animationType="fade"
          onRequestClose={() => setActiveNote(null)}
        >
          <KeyboardAvoidingView 
            behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
            style={styles.modalOverlay}
          >
            <View style={[styles.postcardSheet, styles.sketchyBorder]}>
              {/* Close Button */}
              <TouchableOpacity 
                style={styles.btnCloseModal} 
                onPress={() => setActiveNote(null)}
              >
                <Text style={styles.btnCloseText}>✕</Text>
              </TouchableOpacity>

              {/* Modal Postcard Scroll View */}
              <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={styles.modalScroll}>
                
                {/* Postcard Title with Doodles */}
                <View style={styles.postcardHeader}>
                  <RabbitHeaderDoodle />
                  <Text style={styles.postcardTitleText}>여 행 기</Text>
                  <TigerHeaderDoodle />
                </View>

                {/* Info Fields: 언제, 어디, 누구랑 */}
                <View style={styles.infoRowGrid}>
                  <View style={[styles.infoGridBox, styles.sketchyBorderThin]}>
                    <Text style={styles.infoLabel}>언제</Text>
                    {isEditing ? (
                      <TextInput 
                        style={[styles.infoInput, styles.handwritten]}
                        value={editFormData.when}
                        onChangeText={(text) => setEditFormData({ ...editFormData, when: text })}
                        placeholder="2026.07.11"
                        placeholderTextColor="#ccc"
                      />
                    ) : (
                      <Text style={[styles.infoValueText, styles.handwritten]}>{activeNote.when}</Text>
                    )}
                  </View>

                  <View style={[styles.infoGridBox, styles.sketchyBorderThin]}>
                    <Text style={styles.infoLabel}>어디</Text>
                    {isEditing ? (
                      <TextInput 
                        style={[styles.infoInput, styles.handwritten]}
                        value={editFormData.where}
                        onChangeText={(text) => setEditFormData({ ...editFormData, where: text })}
                        placeholder="제주도..."
                        placeholderTextColor="#ccc"
                      />
                    ) : (
                      <Text style={[styles.infoValueText, styles.handwritten]}>{activeNote.where}</Text>
                    )}
                  </View>

                  <View style={[styles.infoGridBox, styles.sketchyBorderThin]}>
                    <Text style={styles.infoLabel}>누구랑</Text>
                    {isEditing ? (
                      <TextInput 
                        style={[styles.infoInput, styles.handwritten]}
                        value={editFormData.who}
                        onChangeText={(text) => setEditFormData({ ...editFormData, who: text })}
                        placeholder="친구랑..."
                        placeholderTextColor="#ccc"
                      />
                    ) : (
                      <Text style={[styles.infoValueText, styles.handwritten]}>{activeNote.who || '기록 없음'}</Text>
                    )}
                  </View>
                </View>

                {/* Dashed Separator */}
                <View style={styles.dashedLine} />

                {/* Section: 한 것 */}
                <View style={styles.sectionContainer}>
                  <Text style={styles.sectionLabel}>✏️ 한 것</Text>
                  <View style={[styles.sectionBox, styles.sketchyBorderThin]}>
                    {isEditing ? (
                      <TextInput 
                        style={[styles.sectionTextInput, styles.handwritten]}
                        value={editFormData.activities}
                        onChangeText={(text) => setEditFormData({ ...editFormData, activities: text })}
                        placeholder="방문한 명소나 재미있었던 놀이를 기록해 보세요."
                        placeholderTextColor="#ccc"
                        multiline
                      />
                    ) : (
                      <Text style={[styles.sectionValueText, styles.handwritten]}>
                        {activeNote.activities || '기록이 비어있어요.'}
                      </Text>
                    )}
                  </View>
                </View>

                {/* Section: 먹은 것 */}
                <View style={styles.sectionContainer}>
                  <Text style={styles.sectionLabel}>🍽️ 먹은 것</Text>
                  <View style={[styles.sectionBox, styles.sketchyBorderThin]}>
                    {isEditing ? (
                      <TextInput 
                        style={[styles.sectionTextInput, styles.handwritten]}
                        value={editFormData.food}
                        onChangeText={(text) => setEditFormData({ ...editFormData, food: text })}
                        placeholder="기억에 남는 음식이나 디저트, 맛집 목록"
                        placeholderTextColor="#ccc"
                        multiline
                      />
                    ) : (
                      <Text style={[styles.sectionValueText, styles.handwritten]}>
                        {activeNote.food || '기록이 비어있어요.'}
                      </Text>
                    )}
                  </View>
                </View>

                {/* Section: 산 것 */}
                <View style={styles.sectionContainer}>
                  <Text style={styles.sectionLabel}>🛍️ 산 것</Text>
                  <View style={[styles.sectionBox, styles.sketchyBorderThin]}>
                    {isEditing ? (
                      <TextInput 
                        style={[styles.sectionTextInput, styles.handwritten]}
                        value={editFormData.shopping}
                        onChangeText={(text) => setEditFormData({ ...editFormData, shopping: text })}
                        placeholder="기념품이나 소소한 굿즈 쇼핑 목록"
                        placeholderTextColor="#ccc"
                        multiline
                      />
                    ) : (
                      <Text style={[styles.sectionValueText, styles.handwritten]}>
                        {activeNote.shopping || '기록이 비어있어요.'}
                      </Text>
                    )}
                  </View>
                </View>

                {/* Star Rating Selection */}
                <View style={styles.ratingContainer}>
                  <Text style={styles.ratingLabelText}>⭐ 여행별점:</Text>
                  <View style={styles.ratingStarRow}>
                    {[1, 2, 3, 4, 5].map((star) => (
                      <SketchyStar 
                        key={star} 
                        filled={star <= (isEditing ? editFormData.rating : activeNote.rating)} 
                        onClick={isEditing ? () => setEditFormData({ ...editFormData, rating: star }) : null}
                        size={28}
                      />
                    ))}
                  </View>
                </View>

                {/* Bottom Memo: Speech Bubble + Cute Rabbit */}
                <View style={styles.memoContainer}>
                  <View style={[styles.memoBubble, styles.sketchyBorderThin]}>
                    {isEditing ? (
                      <TextInput 
                        style={[styles.sectionTextInput, styles.handwritten]}
                        value={editFormData.memo}
                        onChangeText={(text) => setEditFormData({ ...editFormData, memo: text })}
                        placeholder="일기나 마음 속 감상, 소중한 한 줄 평..."
                        placeholderTextColor="#ccc"
                        multiline
                      />
                    ) : (
                      <Text style={[styles.sectionValueText, styles.handwritten]}>
                        {activeNote.memo || '자유 일기 내용이 비어있어요.'}
                      </Text>
                    )}
                  </View>
                  
                  {/* Rabbit Doddle Overlapping bottom corner */}
                  <View style={styles.memoRabbitPosition}>
                    <RabbitMemoDoodle />
                  </View>
                </View>

                {/* Actions Footer */}
                <View style={styles.modalActionButtons}>
                  {isEditing ? (
                    <>
                      <TouchableOpacity 
                        style={[styles.btnAction, styles.btnSave, styles.sketchyBorderThin]} 
                        onPress={handleSaveNote}
                      >
                        <Text style={styles.btnActionText}>💾 저장</Text>
                      </TouchableOpacity>
                      <TouchableOpacity 
                        style={[styles.btnAction, styles.btnCancel, styles.sketchyBorderThin]} 
                        onPress={() => {
                          if (editFormData.id) {
                            setIsEditing(false); // Go back to view mode
                          } else {
                            setActiveNote(null); // Close modal for new note
                          }
                        }}
                      >
                        <Text style={styles.btnActionText}>✕ 취소</Text>
                      </TouchableOpacity>
                    </>
                  ) : (
                    <>
                      <TouchableOpacity 
                        style={[styles.btnAction, styles.btnEdit, styles.sketchyBorderThin]} 
                        onPress={handleEditNote}
                      >
                        <Text style={styles.btnActionText}>✏️ 수정</Text>
                      </TouchableOpacity>
                      <TouchableOpacity 
                        style={[styles.btnAction, styles.btnDelete, styles.sketchyBorderThin]} 
                        onPress={() => handleDeleteNote(activeNote.id)}
                      >
                        <Text style={styles.btnActionText}>🗑️ 삭제</Text>
                      </TouchableOpacity>
                    </>
                  )}
                </View>

              </ScrollView>
            </View>
          </KeyboardAvoidingView>
        </Modal>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  // Global Layout
  safeArea: {
    flex: 1,
    backgroundColor: '#eae6db',
  },
  container: {
    flex: 1,
    paddingHorizontal: 16,
    paddingTop: 10,
    backgroundColor: '#eae6db',
  },
  header: {
    alignItems: 'center',
    marginVertical: 15,
  },
  appTitle: {
    fontFamily: 'Gaegu_700Bold',
    fontSize: 32,
    color: '#1a1a1a',
  },
  appSubtitle: {
    fontFamily: 'Gaegu_400Regular',
    fontSize: 16,
    color: '#6e6e6e',
    marginTop: 2,
  },
  
  // Controls Bar
  controlsBar: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
    gap: 10,
  },
  searchBox: {
    flex: 1,
    backgroundColor: '#faf8f5',
    paddingHorizontal: 15,
    paddingVertical: Platform.OS === 'ios' ? 8 : 4,
    height: 42,
    justifyContent: 'center',
  },
  searchInput: {
    fontFamily: 'Gaegu_400Regular',
    fontSize: 16,
    color: '#1a1a1a',
    padding: 0,
  },
  btnAdd: {
    backgroundColor: '#fff3c4',
    paddingHorizontal: 16,
    height: 42,
    justifyContent: 'center',
    alignItems: 'center',
  },
  btnAddText: {
    fontFamily: 'Gaegu_700Bold',
    fontSize: 16,
    color: '#1a1a1a',
  },

  // Hand-drawn sketchy border helpers
  sketchyBorder: {
    borderWidth: 3,
    borderColor: '#1a1a1a',
    borderRadius: 16, // Simplifies native border rendering, looks clean but slightly organic
  },
  sketchyBorderThin: {
    borderWidth: 2,
    borderColor: '#1a1a1a',
    borderRadius: 8,
  },

  // Scroll Content
  scrollContent: {
    paddingBottom: 40,
  },
  cardsContainer: {
    gap: 20,
  },

  // Card view styling
  noteCard: {
    backgroundColor: '#faf8f5',
    padding: 16,
    shadowColor: '#000',
    shadowOffset: { width: 3, height: 3 },
    shadowOpacity: 0.08,
    shadowRadius: 0,
    elevation: 2,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  cardDate: {
    fontFamily: 'Gaegu_400Regular',
    fontSize: 14,
    color: '#6e6e6e',
  },
  cardRating: {
    flexDirection: 'row',
    gap: 1,
  },
  cardLocation: {
    fontFamily: 'Gaegu_700Bold',
    fontSize: 20,
    color: '#1a1a1a',
    marginBottom: 4,
  },
  cardWho: {
    fontFamily: 'Gaegu_400Regular',
    fontSize: 14,
    color: '#6e6e6e',
    backgroundColor: '#e3f2fd',
    alignSelf: 'flex-start',
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 10,
    marginBottom: 8,
  },
  cardPreview: {
    fontFamily: 'Gaegu_400Regular',
    fontSize: 16,
    lineHeight: 20,
    color: '#1a1a1a',
  },
  cardDivider: {
    borderTopWidth: 1.5,
    borderStyle: 'dashed',
    borderColor: '#eee',
    marginVertical: 12,
  },
  cardFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  cardTag: {
    fontFamily: 'Gaegu_400Regular',
    fontSize: 14,
    backgroundColor: '#ffe3e3',
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 4,
    color: '#1a1a1a',
  },

  // Empty State
  emptyState: {
    backgroundColor: '#faf8f5',
    padding: 40,
    alignItems: 'center',
    justifyContent: 'center',
  },
  emptyText: {
    fontFamily: 'Gaegu_400Regular',
    fontSize: 18,
    color: '#6e6e6e',
    textAlign: 'center',
  },

  // Star Layout
  starTouch: {
    padding: 2,
  },
  starIcon: {
    padding: 1,
  },

  // Modal View Postcard Sheet
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 16,
  },
  postcardSheet: {
    backgroundColor: '#faf8f5',
    width: '100%',
    maxHeight: '90%',
    borderRadius: 16,
    padding: 20,
    position: 'relative',
    shadowColor: '#000',
    shadowOffset: { width: 5, height: 5 },
    shadowOpacity: 0.15,
    shadowRadius: 5,
    elevation: 5,
  },
  modalScroll: {
    paddingBottom: 20,
  },
  btnCloseModal: {
    position: 'absolute',
    top: -12,
    right: -12,
    backgroundColor: '#ffe3e3',
    width: 32,
    height: 32,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#1a1a1a',
    zIndex: 10,
  },
  btnCloseText: {
    fontWeight: 'bold',
    fontSize: 14,
    color: '#1a1a1a',
  },
  postcardHeader: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    gap: 15,
    marginVertical: 15,
  },
  postcardTitleText: {
    fontFamily: 'Gaegu_700Bold',
    fontSize: 32,
    letterSpacing: 6,
    textAlign: 'center',
    color: '#1a1a1a',
  },

  // Info Box Grid
  infoRowGrid: {
    flexDirection: 'row',
    gap: 8,
    marginBottom: 15,
  },
  infoGridBox: {
    flex: 1,
    backgroundColor: '#fff',
    padding: 6,
    alignItems: 'center',
    minHeight: 50,
    justifyContent: 'center',
  },
  infoLabel: {
    fontFamily: 'Gaegu_400Regular',
    fontSize: 12,
    color: '#6e6e6e',
    borderBottomWidth: 1,
    borderStyle: 'dashed',
    borderColor: '#ddd',
    width: '100%',
    textAlign: 'center',
    paddingBottom: 2,
    marginBottom: 4,
  },
  infoValueText: {
    fontSize: 14,
    textAlign: 'center',
    color: '#1a1a1a',
  },
  infoInput: {
    width: '100%',
    textAlign: 'center',
    fontSize: 14,
    padding: 0,
    color: '#1a1a1a',
  },
  handwritten: {
    fontFamily: 'Gaegu_700Bold',
  },
  dashedLine: {
    borderTopWidth: 2,
    borderStyle: 'dashed',
    borderColor: '#1a1a1a',
    marginVertical: 15,
  },

  // Section Content
  sectionContainer: {
    marginBottom: 12,
  },
  sectionLabel: {
    fontFamily: 'Gaegu_700Bold',
    fontSize: 16,
    color: '#1a1a1a',
    marginBottom: 4,
  },
  sectionBox: {
    backgroundColor: '#fff',
    padding: 10,
    minHeight: 50,
    justifyContent: 'center',
  },
  sectionValueText: {
    fontSize: 15,
    lineHeight: 18,
    color: '#1a1a1a',
  },
  sectionTextInput: {
    fontSize: 15,
    lineHeight: 18,
    color: '#1a1a1a',
    padding: 0,
    textAlignVertical: 'top',
  },

  // Rating Inside Modal
  ratingContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    marginVertical: 10,
  },
  ratingLabelText: {
    fontFamily: 'Gaegu_700Bold',
    fontSize: 16,
    color: '#1a1a1a',
  },
  ratingStarRow: {
    flexDirection: 'row',
    gap: 4,
  },

  // Memo Bubble Container
  memoContainer: {
    marginTop: 15,
    position: 'relative',
    paddingBottom: 35,
  },
  memoBubble: {
    backgroundColor: '#fff',
    padding: 12,
    minHeight: 80,
    borderRadius: 16,
    borderBottomLeftRadius: 2, // Speech bubble tail feel
  },
  memoRabbitPosition: {
    position: 'absolute',
    bottom: -15,
    left: 10,
    zIndex: 5,
  },

  // Action Buttons Footer
  modalActionButtons: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    gap: 10,
    marginTop: 15,
  },
  btnAction: {
    paddingHorizontal: 18,
    paddingVertical: 8,
    alignItems: 'center',
    justifyContent: 'center',
  },
  btnActionText: {
    fontFamily: 'Gaegu_700Bold',
    fontSize: 16,
    color: '#1a1a1a',
  },
  btnSave: {
    backgroundColor: '#fff3c4',
  },
  btnCancel: {
    backgroundColor: '#ffe3e3',
  },
  btnEdit: {
    backgroundColor: '#e3f2fd',
  },
  btnDelete: {
    backgroundColor: '#ffe3e3',
  },
});
