import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  FlatList,
  StyleSheet,
  Alert,
} from 'react-native';
import SafeContainer from '../components/SafeContainer';
import { getAccountList, deleteAccount, CATEGORIES } from '../api/account';

const CATEGORY_LIST = Object.values(CATEGORIES);

const AccountListScreen = ({ navigation }) => {
  const [accounts, setAccounts] = useState([]);
  const [keyword, setKeyword] = useState('');
  const [activeCategory, setActiveCategory] = useState('all');
  const [visiblePasswords, setVisiblePasswords] = useState({});
  const [loading, setLoading] = useState(false);

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const res = await getAccountList({
        keyword: keyword.trim(),
        category: activeCategory,
      });
      if (res.code === 401) {
        return;
      }
      if (res.code === 0) {
        setAccounts(res.data);
      }
    } finally {
      setLoading(false);
    }
  }, [keyword, activeCategory]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  // 从编辑页返回时刷新列表
  useEffect(() => {
    const unsubscribe = navigation.addListener('focus', () => {
      fetchData();
    });
    return unsubscribe;
  }, [navigation, fetchData]);

  const togglePassword = id => {
    setVisiblePasswords(prev => ({ ...prev, [id]: !prev[id] }));
  };

  const handleDelete = item => {
    Alert.alert('确认删除', `确定要删除「${item.title}」吗？`, [
      { text: '取消', style: 'cancel' },
      {
        text: '删除',
        style: 'destructive',
        onPress: async () => {
          const res = await deleteAccount(item.accountId);
          if (res.code === 401) {
            return;
          }
          fetchData();
        },
      },
    ]);
  };

  const getCategoryColor = category => {
    const map = {
      social: '#4CAF50',
      work: '#2196F3',
      finance: '#FF9800',
      other: '#9E9E9E',
    };
    return map[category] || '#9E9E9E';
  };

  const getCategoryLabel = category => {
    const found = CATEGORY_LIST.find(c => c.key === category);
    return found ? found.label : '其他';
  };

  const renderItem = ({ item }) => (
    <TouchableOpacity
      style={styles.card}
      onPress={() =>
        navigation.navigate('AccountEdit', {
          accountId: item.accountId,
          account: item,
        })
      }
      onLongPress={() => handleDelete(item)}
      activeOpacity={0.7}>
      <View style={styles.cardHeader}>
        <View style={styles.cardTitleRow}>
          <View
            style={[
              styles.categoryDot,
              { backgroundColor: getCategoryColor(item.category) },
            ]}
          />
          <Text style={styles.cardTitle}>{item.title}</Text>
          <View
            style={[
              styles.categoryBadge,
              { backgroundColor: getCategoryColor(item.category) + '20' },
            ]}>
            <Text
              style={[
                styles.categoryBadgeText,
                { color: getCategoryColor(item.category) },
              ]}>
              {getCategoryLabel(item.category)}
            </Text>
          </View>
        </View>
        {item.url ? (
          <Text style={styles.cardUrl} numberOfLines={1}>
            {item.url}
          </Text>
        ) : null}
      </View>
      <View style={styles.cardBody}>
        <View style={styles.cardInfoRow}>
          <Text style={styles.cardLabel}>账号</Text>
          <Text style={styles.cardValue}>{item.username}</Text>
        </View>
        <View style={styles.cardInfoRow}>
          <Text style={styles.cardLabel}>密码</Text>
          <TouchableOpacity
            onPress={() => togglePassword(item.accountId)}
            style={styles.passwordRow}>
            <Text style={styles.cardValue}>
              {visiblePasswords[item.accountId] ? item.password : '••••••••'}
            </Text>
            <Text style={styles.eyeIcon}>
              {visiblePasswords[item.accountId] ? '隐藏' : '显示'}
            </Text>
          </TouchableOpacity>
        </View>
      </View>
      {item.remark ? (
        <View style={styles.cardFooter}>
          <Text style={styles.cardRemark} numberOfLines={1}>
            {item.remark}
          </Text>
        </View>
      ) : null}
    </TouchableOpacity>
  );

  const renderEmpty = () => (
    <View style={styles.emptyContainer}>
      <Text style={styles.emptyIcon}>📋</Text>
      <Text style={styles.emptyText}>
        {keyword || activeCategory !== 'all'
          ? '没有找到匹配的账号'
          : '还没有记录，点击右下角 + 添加'}
      </Text>
    </View>
  );

  return (
    <SafeContainer style={styles.container}>
      {/* 自定义标题栏 */}
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()}>
          <Text style={styles.headerBack}>{'< 返回'}</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>密码管理</Text>
        <TouchableOpacity
          onPress={() => navigation.navigate('AccountEdit')}>
          <Text style={styles.headerAdd}>新增</Text>
        </TouchableOpacity>
      </View>

      {/* 搜索栏 */}
      <View style={styles.searchBar}>
        <TextInput
          style={styles.searchInput}
          placeholder="搜索标题或账号..."
          placeholderTextColor="#aaa"
          value={keyword}
          onChangeText={setKeyword}
          returnKeyType="search"
          clearButtonMode="while-editing"
        />
      </View>

      {/* 分类 Tab */}
      <View style={styles.tabBar}>
        {CATEGORY_LIST.map(cat => (
          <TouchableOpacity
            key={cat.key}
            style={[
              styles.tab,
              activeCategory === cat.key && styles.tabActive,
            ]}
            onPress={() => setActiveCategory(cat.key)}>
            <Text
              style={[
                styles.tabText,
                activeCategory === cat.key && styles.tabTextActive,
              ]}>
              {cat.label}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* 列表 */}
      <FlatList
        data={accounts}
        keyExtractor={item => item.accountId}
        renderItem={renderItem}
        ListEmptyComponent={renderEmpty}
        contentContainerStyle={
          accounts.length === 0 ? styles.listEmpty : styles.listContent
        }
        refreshing={loading}
        onRefresh={fetchData}
        showsVerticalScrollIndicator={false}
      />

      {/* FAB 浮动按钮 */}
      <TouchableOpacity
        style={styles.fab}
        onPress={() => navigation.navigate('AccountEdit')}
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
    flexDirection: 'row',
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
    // shadow
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.08,
    shadowRadius: 4,
  },
  cardHeader: {
    marginBottom: 10,
  },
  cardTitleRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  categoryDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: 8,
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
    marginLeft: 8,
  },
  categoryBadgeText: {
    fontSize: 11,
    fontWeight: '500',
  },
  cardUrl: {
    fontSize: 12,
    color: '#999',
    marginTop: 4,
    marginLeft: 16,
  },
  cardBody: {
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: '#f0f0f0',
    paddingTop: 10,
  },
  cardInfoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 3,
  },
  cardLabel: {
    fontSize: 13,
    color: '#999',
    width: 40,
  },
  cardValue: {
    fontSize: 14,
    color: '#333',
    flex: 1,
    textAlign: 'right',
  },
  passwordRow: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
    justifyContent: 'flex-end',
  },
  eyeIcon: {
    fontSize: 12,
    color: '#2196F3',
    marginLeft: 10,
    fontWeight: '500',
  },
  cardFooter: {
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: '#f0f0f0',
    marginTop: 8,
    paddingTop: 8,
  },
  cardRemark: {
    fontSize: 12,
    color: '#999',
    fontStyle: 'italic',
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
    backgroundColor: '#4CAF50',
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

export default AccountListScreen;
