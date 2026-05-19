import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  FlatList,
  ScrollView,
  StyleSheet,
  Alert,
  RefreshControl,
} from 'react-native';
import SafeContainer from '../components/SafeContainer';
import { getMemoList, deleteMemo, getCategoryList } from '../api/memo';
import { useAppContext } from '../context/AppContext';

const MemoListScreen = ({ navigation }) => {
  const { username } = useAppContext();
  const [memos, setMemos] = useState([]);
  const [categories, setCategories] = useState([]);
  const [activeCategory, setActiveCategory] = useState(null);
  const [keyword, setKeyword] = useState('');
  const [loading, setLoading] = useState(false);

  const fetchCategories = async () => {
    const res = await getCategoryList();
    if (res.code === 0) {
      setCategories(res.data || []);
    }
  };

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const params = { pageNum: 1, pageSize: 100 };
      if (activeCategory) {
        params.categoryId = activeCategory;
      }
      if (keyword.trim()) {
        params.memoName = keyword.trim();
      }
      const res = await getMemoList(params);
      if (res.code === 401) return;
      if (res.code === 0) {
        setMemos(res.data || []);
      }
    } finally {
      setLoading(false);
    }
  }, [activeCategory, keyword]);

  useEffect(() => {
    fetchCategories();
  }, []);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  useEffect(() => {
    const unsubscribe = navigation.addListener('focus', () => {
      fetchCategories();
      fetchData();
    });
    return unsubscribe;
  }, [navigation, fetchData]);

  const getCategoryName = categoryId => {
    const cat = categories.find(c => c.categoryId === categoryId);
    return cat ? cat.categoryName : '';
  };

  const handleDelete = item => {
    Alert.alert('确认删除', `确定要删除「${item.memoName}」吗？`, [
      { text: '取消', style: 'cancel' },
      {
        text: '删除',
        style: 'destructive',
        onPress: async () => {
          const res = await deleteMemo(item.memoId);
          if (res.code === 401) return;
          fetchData();
        },
      },
    ]);
  };

  const renderItem = ({ item }) => (
    <TouchableOpacity
      style={styles.card}
      onPress={() =>
        navigation.navigate('MemoDetail', {
          memoId: item.memoId,
        })
      }
      onLongPress={() => handleDelete(item)}
      activeOpacity={0.7}>
      <View style={styles.cardHeader}>
        <Text style={styles.cardTitle}>{item.memoName}</Text>
        <View style={styles.categoryBadge}>
          <Text style={styles.categoryBadgeText}>
            {getCategoryName(item.categoryId)}
          </Text>
        </View>
      </View>
      {item.memoDesc ? (
        <Text style={styles.cardDesc} numberOfLines={2}>
          {item.memoDesc}
        </Text>
      ) : null}
      <Text style={styles.cardTime}>{item.createTime}</Text>
    </TouchableOpacity>
  );

  const renderEmpty = () => (
    <View style={styles.emptyContainer}>
      <Text style={styles.emptyIcon}>📝</Text>
      <Text style={styles.emptyText}>
        {keyword || activeCategory
          ? '没有找到匹配的备忘录'
          : '还没有记录，点击右下角 + 添加'}
      </Text>
    </View>
  );

  return (
    <SafeContainer style={styles.container}>
      {/* 标题栏 */}
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()}>
          <Text style={styles.headerBack}>{'< 返回'}</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>备忘录</Text>
        <TouchableOpacity
          onPress={() => navigation.navigate('MemoEdit')}>
          <Text style={styles.headerAdd}>新增</Text>
        </TouchableOpacity>
      </View>

      {/* 用户信息 */}
      {username ? (
        <View style={styles.userBar}>
          <Text style={styles.userGreeting}>{username}，你好</Text>
        </View>
      ) : null}

      {/* 搜索栏 */}
      <View style={styles.searchBar}>
        <TextInput
          style={styles.searchInput}
          placeholder="搜索备忘录..."
          placeholderTextColor="#aaa"
          value={keyword}
          onChangeText={setKeyword}
          returnKeyType="search"
          clearButtonMode="while-editing"
        />
      </View>

      {/* 分类 Tab */}
      <View style={styles.tabBar}>
        <ScrollView horizontal showsHorizontalScrollIndicator={false}>
          <TouchableOpacity
            style={[styles.tab, !activeCategory && styles.tabActive]}
            onPress={() => setActiveCategory(null)}>
            <Text
              style={[styles.tabText, !activeCategory && styles.tabTextActive]}>
              全部
            </Text>
          </TouchableOpacity>
          {categories.map(cat => (
            <TouchableOpacity
              key={cat.categoryId}
              style={[
                styles.tab,
                activeCategory === cat.categoryId && styles.tabActive,
              ]}
              onPress={() => setActiveCategory(cat.categoryId)}>
              <Text
                style={[
                  styles.tabText,
                  activeCategory === cat.categoryId && styles.tabTextActive,
                ]}>
                {cat.categoryName}
              </Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>

      {/* 列表 */}
      <FlatList
        data={memos}
        keyExtractor={item => String(item.memoId)}
        renderItem={renderItem}
        ListEmptyComponent={renderEmpty}
        contentContainerStyle={
          memos.length === 0 ? styles.listEmpty : styles.listContent
        }
        refreshControl={
          <RefreshControl refreshing={loading} onRefresh={fetchData} />
        }
        showsVerticalScrollIndicator={false}
      />

      {/* FAB */}
      <TouchableOpacity
        style={styles.fab}
        onPress={() => navigation.navigate('MemoEdit')}
        activeOpacity={0.8}>
        <Text style={styles.fabText}>+</Text>
      </TouchableOpacity>
    </SafeContainer>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f0f2f5',
  },

  // Header
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 14,
    backgroundColor: '#fff',
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#e0e0e0',
  },
  headerBack: {
    fontSize: 15,
    color: '#2196F3',
    fontWeight: '500',
  },
  headerTitle: {
    fontSize: 17,
    fontWeight: '600',
    color: '#333',
  },
  headerAdd: {
    fontSize: 15,
    color: '#4CAF50',
    fontWeight: '600',
  },

  // User
  userBar: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    backgroundColor: '#fff',
  },
  userGreeting: {
    fontSize: 13,
    color: '#999',
  },

  // Search
  searchBar: {
    paddingHorizontal: 16,
    paddingVertical: 10,
    backgroundColor: '#fff',
  },
  searchInput: {
    backgroundColor: '#f5f5f5',
    borderRadius: 8,
    paddingHorizontal: 14,
    paddingVertical: 10,
    fontSize: 15,
    color: '#333',
  },

  // Tabs
  tabBar: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    backgroundColor: '#fff',
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#e0e0e0',
  },
  tab: {
    paddingHorizontal: 14,
    paddingVertical: 7,
    borderRadius: 16,
    marginRight: 8,
    backgroundColor: '#f5f5f5',
  },
  tabActive: {
    backgroundColor: '#2196F3',
  },
  tabText: {
    fontSize: 13,
    color: '#666',
  },
  tabTextActive: {
    color: '#fff',
    fontWeight: '600',
  },

  // List
  listContent: {
    paddingHorizontal: 16,
    paddingTop: 12,
    paddingBottom: 80,
  },
  listEmpty: {
    flexGrow: 1,
  },

  // Card
  card: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 10,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.08,
    shadowRadius: 4,
  },
  cardHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  cardTitle: {
    fontSize: 17,
    fontWeight: '600',
    color: '#333',
    flex: 1,
  },
  categoryBadge: {
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 10,
    backgroundColor: '#2196F320',
  },
  categoryBadgeText: {
    fontSize: 11,
    fontWeight: '500',
    color: '#2196F3',
  },
  cardDesc: {
    fontSize: 13,
    color: '#999',
    marginTop: 8,
    lineHeight: 18,
  },
  cardTime: {
    fontSize: 12,
    color: '#ccc',
    marginTop: 8,
  },

  // Empty
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  emptyIcon: {
    fontSize: 48,
    marginBottom: 12,
  },
  emptyText: {
    fontSize: 15,
    color: '#999',
  },

  // FAB
  fab: {
    position: 'absolute',
    right: 24,
    bottom: 30,
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: '#2196F3',
    alignItems: 'center',
    justifyContent: 'center',
    elevation: 6,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.2,
    shadowRadius: 6,
  },
  fabText: {
    fontSize: 28,
    color: '#fff',
    fontWeight: '300',
    marginTop: -2,
  },
});

export default MemoListScreen;