import React, {useState, useEffect, useCallback, useRef} from 'react';
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
  ActivityIndicator,
} from 'react-native';
import SafeContainer from '../components/SafeContainer';
import {
  getReminderList,
  deleteReminder,
  CATEGORY_LIST,
  STATUS_LIST,
  getReminderCategory,
  getReminderStatus,
} from '../api/reminder';

const PAGE_SIZE = 10;
const MS_PER_DAY = 24 * 60 * 60 * 1000;

function parseLocalDate(value) {
  if (!value) return null;
  const dateText = String(value).split(' ')[0];
  const parts = dateText.split('-').map(Number);
  if (parts.length !== 3 || parts.some(Number.isNaN)) {
    return null;
  }
  return new Date(parts[0], parts[1] - 1, parts[2]);
}

function calculateDays(dueDate) {
  const due = parseLocalDate(dueDate);
  if (!due) return 0;
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  return Math.round((due.getTime() - today.getTime()) / MS_PER_DAY);
}

function getDaysText(dueDate) {
  const days = calculateDays(dueDate);
  if (days > 0) return `${days}天`;
  if (days === 0) return '今天到期';
  return `过期${Math.abs(days)}天`;
}

function getDaysColor(dueDate) {
  const days = calculateDays(dueDate);
  if (days > 7) return '#4CAF50';
  if (days > 0) return '#FF9800';
  return '#F44336';
}

function formatTime(value) {
  if (!value) return '-';
  return String(value).slice(0, 5);
}

const ReminderListScreen = ({navigation}) => {
  const [reminders, setReminders] = useState([]);
  const [keyword, setKeyword] = useState('');
  const [activeCategory, setActiveCategory] = useState('all');
  const [activeStatus, setActiveStatus] = useState('all');
  const [loading, setLoading] = useState(false);
  const [loadingMore, setLoadingMore] = useState(false);
  const [pageNum, setPageNum] = useState(1);
  const [total, setTotal] = useState(0);
  const [hasMore, setHasMore] = useState(false);
  const loadingMoreRef = useRef(false);
  const listRequestIdRef = useRef(0);

  const fetchPage = useCallback(
    async (nextPage, append) => {
      if (append && loadingMoreRef.current) {
        return;
      }

      const requestId = append
        ? listRequestIdRef.current
        : listRequestIdRef.current + 1;
      if (!append) {
        listRequestIdRef.current = requestId;
        setLoading(true);
      } else {
        loadingMoreRef.current = true;
        setLoadingMore(true);
      }

      try {
        const res = await getReminderList({
          pageNum: nextPage,
          pageSize: PAGE_SIZE,
          title: keyword.trim(),
          category: activeCategory,
          status: activeStatus,
        });
        if (requestId !== listRequestIdRef.current) {
          return;
        }
        if (res.code === 401) return;
        if (res.code === 0) {
          const list = Array.isArray(res.data) ? res.data : [];
          const totalCount = Number(res.total) || 0;
          setReminders(prev => (append ? [...prev, ...list] : list));
          setPageNum(nextPage);
          setTotal(totalCount);
          setHasMore(
            totalCount > 0
              ? nextPage * PAGE_SIZE < totalCount
              : list.length === PAGE_SIZE,
          );
        } else {
          Alert.alert('错误', res.message || '加载提醒事项失败');
        }
      } finally {
        if (append) {
          loadingMoreRef.current = false;
          setLoadingMore(false);
        } else if (requestId === listRequestIdRef.current) {
          setLoading(false);
        }
      }
    },
    [activeCategory, activeStatus, keyword],
  );

  const fetchData = useCallback(() => {
    return fetchPage(1, false);
  }, [fetchPage]);

  const loadMore = useCallback(() => {
    if (loading || loadingMore || !hasMore) {
      return;
    }
    fetchPage(pageNum + 1, true);
  }, [loading, loadingMore, hasMore, pageNum, fetchPage]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  useEffect(() => {
    const unsubscribe = navigation.addListener('focus', () => {
      fetchData();
    });
    return unsubscribe;
  }, [navigation, fetchData]);

  const handleDelete = item => {
    Alert.alert('确认删除', `确定要删除「${item.title}」吗？`, [
      {text: '取消', style: 'cancel'},
      {
        text: '删除',
        style: 'destructive',
        onPress: async () => {
          const res = await deleteReminder(item.reminderId);
          if (res.code === 401) return;
          if (res.code !== 0) {
            Alert.alert('错误', res.message || '删除失败');
            return;
          }
          fetchData();
        },
      },
    ]);
  };

  const renderItem = ({item}) => {
    const category = getReminderCategory(item.category);
    const status = getReminderStatus(item.status);
    const dueColor = getDaysColor(item.dueDate);

    return (
      <TouchableOpacity
        style={styles.card}
        onPress={() =>
          navigation.navigate('ReminderDetail', {
            reminderId: item.reminderId,
          })
        }
        onLongPress={() => handleDelete(item)}
        activeOpacity={0.7}
      >
        <View style={styles.cardHeader}>
          <View style={styles.titleWrap}>
            <Text style={styles.cardTitle} numberOfLines={1}>
              {item.title}
            </Text>
            <View
              style={[
                styles.statusBadge,
                {backgroundColor: status.color + '18'},
              ]}
            >
              <Text style={[styles.statusBadgeText, {color: status.color}]}>
                {status.label}
              </Text>
            </View>
          </View>
          <View
            style={[
              styles.categoryBadge,
              {backgroundColor: category.color + '18'},
            ]}
          >
            <Text style={[styles.categoryBadgeText, {color: category.color}]}>
              {category.label}
            </Text>
          </View>
        </View>

        {item.description ? (
          <Text style={styles.cardDesc} numberOfLines={2}>
            {item.description}
          </Text>
        ) : null}

        <View style={styles.cardMeta}>
          <View style={styles.metaItem}>
            <Text style={styles.metaLabel}>到期</Text>
            <Text style={styles.metaValue}>{item.dueDate || '-'}</Text>
          </View>
          <View style={styles.metaItem}>
            <Text style={styles.metaLabel}>剩余</Text>
            <Text style={[styles.metaValue, {color: dueColor}]}>
              {getDaysText(item.dueDate)}
            </Text>
          </View>
          <View style={styles.metaItem}>
            <Text style={styles.metaLabel}>提醒</Text>
            <Text style={styles.metaValue}>{formatTime(item.remindTime)}</Text>
          </View>
        </View>

        <View style={styles.cardFooter}>
          <Text style={styles.footerNote}>
            提前{item.remindBeforeDays ?? 7}天 · 续期{item.renewalCount ?? 0}次
          </Text>
          <Text style={styles.cardArrow}>{'>'}</Text>
        </View>
      </TouchableOpacity>
    );
  };

  const renderEmpty = () => (
    <View style={styles.emptyContainer}>
      <Text style={styles.emptyIcon}>⏰</Text>
      <Text style={styles.emptyText}>
        {keyword || activeCategory !== 'all' || activeStatus !== 'all'
          ? '没有找到匹配的提醒事项'
          : '还没有记录，点击右下角 + 添加'}
      </Text>
    </View>
  );

  const renderFooter = () => {
    if (loadingMore) {
      return (
        <View style={styles.footer}>
          <ActivityIndicator size="small" color="#2196F3" />
          <Text style={styles.footerText}>加载更多...</Text>
        </View>
      );
    }

    if (!hasMore && reminders.length > 0) {
      return (
        <View style={styles.footer}>
          <Text style={styles.footerText}>
            {total > 0 ? `已加载全部 ${total} 条` : '没有更多了'}
          </Text>
        </View>
      );
    }

    return null;
  };

  return (
    <SafeContainer style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()}>
          <Text style={styles.headerBack}>{'< 返回'}</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>提醒事项</Text>
        <TouchableOpacity onPress={() => navigation.navigate('ReminderEdit')}>
          <Text style={styles.headerAdd}>新增</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.searchBar}>
        <TextInput
          style={styles.searchInput}
          placeholder="搜索提醒事项..."
          placeholderTextColor="#aaa"
          value={keyword}
          onChangeText={setKeyword}
          returnKeyType="search"
          clearButtonMode="while-editing"
        />
      </View>

      <View style={styles.filterBar}>
        <ScrollView horizontal showsHorizontalScrollIndicator={false}>
          {CATEGORY_LIST.map(category => (
            <TouchableOpacity
              key={category.key}
              style={[
                styles.tab,
                activeCategory === category.key && styles.tabActive,
              ]}
              onPress={() => setActiveCategory(category.key)}
            >
              <Text
                style={[
                  styles.tabText,
                  activeCategory === category.key && styles.tabTextActive,
                ]}
              >
                {category.label}
              </Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>

      <View style={styles.filterBarSecondary}>
        <ScrollView horizontal showsHorizontalScrollIndicator={false}>
          {STATUS_LIST.map(status => (
            <TouchableOpacity
              key={status.key}
              style={[
                styles.statusTab,
                activeStatus === status.key && styles.statusTabActive,
              ]}
              onPress={() => setActiveStatus(status.key)}
            >
              <Text
                style={[
                  styles.statusTabText,
                  activeStatus === status.key && styles.statusTabTextActive,
                ]}
              >
                {status.label}
              </Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>

      <FlatList
        data={reminders}
        keyExtractor={item => String(item.reminderId)}
        renderItem={renderItem}
        ListEmptyComponent={renderEmpty}
        ListFooterComponent={renderFooter}
        contentContainerStyle={
          reminders.length === 0 ? styles.listEmpty : styles.listContent
        }
        refreshControl={
          <RefreshControl refreshing={loading} onRefresh={fetchData} />
        }
        onEndReached={loadMore}
        onEndReachedThreshold={0.35}
        showsVerticalScrollIndicator={false}
      />

      <TouchableOpacity
        style={styles.fab}
        onPress={() => navigation.navigate('ReminderEdit')}
        activeOpacity={0.8}
      >
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
  filterBar: {
    paddingHorizontal: 16,
    paddingTop: 8,
    paddingBottom: 6,
    backgroundColor: '#fff',
  },
  filterBarSecondary: {
    paddingHorizontal: 16,
    paddingTop: 2,
    paddingBottom: 8,
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
  statusTab: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 14,
    marginRight: 8,
    backgroundColor: '#f7f7f7',
  },
  statusTabActive: {
    backgroundColor: '#333',
  },
  statusTabText: {
    fontSize: 12,
    color: '#777',
  },
  statusTabTextActive: {
    color: '#fff',
    fontWeight: '600',
  },
  listContent: {
    paddingHorizontal: 16,
    paddingTop: 12,
    paddingBottom: 80,
  },
  listEmpty: {
    flexGrow: 1,
  },
  footer: {
    minHeight: 42,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  footerText: {
    fontSize: 12,
    color: '#999',
    marginLeft: 6,
  },
  card: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 10,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 1},
    shadowOpacity: 0.08,
    shadowRadius: 4,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
  },
  titleWrap: {
    flex: 1,
    paddingRight: 8,
  },
  cardTitle: {
    fontSize: 17,
    fontWeight: '600',
    color: '#333',
    marginBottom: 6,
  },
  statusBadge: {
    alignSelf: 'flex-start',
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 10,
  },
  statusBadgeText: {
    fontSize: 11,
    fontWeight: '600',
  },
  categoryBadge: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 10,
  },
  categoryBadgeText: {
    fontSize: 11,
    fontWeight: '600',
  },
  cardDesc: {
    fontSize: 13,
    color: '#777',
    lineHeight: 18,
    marginTop: 10,
  },
  cardMeta: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 14,
    paddingVertical: 10,
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: '#eee',
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#eee',
  },
  metaItem: {
    flex: 1,
  },
  metaLabel: {
    fontSize: 11,
    color: '#aaa',
    marginBottom: 4,
  },
  metaValue: {
    fontSize: 13,
    color: '#333',
    fontWeight: '500',
  },
  cardFooter: {
    marginTop: 10,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  footerNote: {
    fontSize: 12,
    color: '#999',
  },
  cardArrow: {
    fontSize: 18,
    color: '#ccc',
  },
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
  fab: {
    position: 'absolute',
    right: 20,
    bottom: 30,
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: '#4CAF50',
    alignItems: 'center',
    justifyContent: 'center',
    elevation: 6,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 3},
    shadowOpacity: 0.25,
    shadowRadius: 5,
  },
  fabText: {
    fontSize: 30,
    color: '#fff',
    lineHeight: 34,
    fontWeight: '300',
  },
});

export default ReminderListScreen;
