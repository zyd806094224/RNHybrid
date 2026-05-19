import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
  Alert,
} from 'react-native';
import SafeContainer from '../components/SafeContainer';
import { getMemoDetail, deleteMemo, getCategoryFields } from '../api/memo';

const MemoDetailScreen = ({ navigation, route }) => {
  const memoId = route.params?.memoId;
  const [detail, setDetail] = useState(null);
  const [fieldDefs, setFieldDefs] = useState([]);
  const [fieldValues, setFieldValues] = useState({});

  useEffect(() => {
    loadDetail();
  }, []);

  const loadDetail = async () => {
    const res = await getMemoDetail(memoId);
    if (res.code === 401) return;
    if (res.code === 0) {
      const data = res.data;
      setDetail(data.memoInfo);

      // 字段值映射
      const vals = {};
      if (data.fieldValues) {
        data.fieldValues.forEach(fv => {
          vals[fv.fieldId] = fv.fieldValue;
        });
      }
      setFieldValues(vals);

      // 单独请求字段定义（request() 只返回 data，fieldDefs 会被丢弃）
      if (data.memoInfo && data.memoInfo.categoryId) {
        const fieldRes = await getCategoryFields(data.memoInfo.categoryId);
        if (fieldRes.code === 0) {
          setFieldDefs(fieldRes.data || []);
        }
      }
    }
  };

  const handleDelete = () => {
    if (!detail) return;
    Alert.alert('确认删除', `确定要删除「${detail.memoName}」吗？`, [
      { text: '取消', style: 'cancel' },
      {
        text: '删除',
        style: 'destructive',
        onPress: async () => {
          const res = await deleteMemo(memoId);
          if (res.code === 401) return;
          navigation.goBack();
        },
      },
    ]);
  };

  if (!detail) {
    return (
      <SafeContainer style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity onPress={() => navigation.goBack()}>
            <Text style={styles.headerBack}>{'< 返回'}</Text>
          </TouchableOpacity>
          <Text style={styles.headerTitle}>备忘录详情</Text>
          <View style={{ width: 50 }} />
        </View>
        <View style={styles.emptyContainer}>
          <Text style={styles.emptyText}>加载中...</Text>
        </View>
      </SafeContainer>
    );
  }

  const renderFieldValue = field => {
    const value = fieldValues[field.fieldId];
    if (!value) return <Text style={styles.valueEmpty}>-</Text>;

    if (field.fieldType === 'textarea') {
      return <Text style={styles.valueText}>{value}</Text>;
    }
    return <Text style={styles.valueText}>{value}</Text>;
  };

  return (
    <SafeContainer style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()}>
          <Text style={styles.headerBack}>{'< 返回'}</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>{detail.memoName}</Text>
        <TouchableOpacity
          onPress={() =>
            navigation.navigate('MemoEdit', {
              memoId: detail.memoId,
            })
          }>
          <Text style={styles.headerEdit}>编辑</Text>
        </TouchableOpacity>
      </View>

      <ScrollView
        style={styles.scrollContent}
        showsVerticalScrollIndicator={false}>
        {/* 基本信息 */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>基本信息</Text>
          <View style={styles.infoCard}>
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>名称</Text>
              <Text style={styles.infoValue}>{detail.memoName}</Text>
            </View>
            <View style={styles.infoDivider} />
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>描述</Text>
              <Text style={styles.infoValue}>
                {detail.memoDesc || '-'}
              </Text>
            </View>
            <View style={styles.infoDivider} />
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>创建时间</Text>
              <Text style={styles.infoValue}>{detail.createTime}</Text>
            </View>
          </View>
        </View>

        {/* 动态字段 */}
        {fieldDefs.length > 0 && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>详细信息</Text>
            <View style={styles.infoCard}>
              {fieldDefs.map((field, index) => (
                <View key={field.fieldId}>
                  <View style={styles.infoRow}>
                    <Text style={styles.infoLabel}>{field.fieldName}</Text>
                    <View style={styles.infoValueWrap}>
                      {renderFieldValue(field)}
                    </View>
                  </View>
                  {index < fieldDefs.length - 1 && (
                    <View style={styles.infoDivider} />
                  )}
                </View>
              ))}
            </View>
          </View>
        )}

        {/* 删除按钮 */}
        <TouchableOpacity
          style={styles.deleteBtn}
          onPress={handleDelete}
          activeOpacity={0.7}>
          <Text style={styles.deleteBtnText}>删除此备忘录</Text>
        </TouchableOpacity>

        <View style={{ height: 40 }} />
      </ScrollView>
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
    flex: 1,
    textAlign: 'center',
  },
  headerEdit: {
    fontSize: 15,
    color: '#2196F3',
    fontWeight: '600',
  },

  scrollContent: {
    flex: 1,
    paddingHorizontal: 16,
    paddingTop: 16,
  },

  // Section
  section: {
    marginBottom: 20,
  },
  sectionTitle: {
    fontSize: 14,
    color: '#999',
    marginBottom: 8,
    fontWeight: '500',
  },

  // Info Card
  infoCard: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    elevation: 1,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
  },
  infoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    paddingVertical: 8,
  },
  infoLabel: {
    fontSize: 14,
    color: '#999',
    width: 80,
  },
  infoValue: {
    fontSize: 14,
    color: '#333',
    flex: 1,
    textAlign: 'right',
  },
  infoValueWrap: {
    flex: 1,
    alignItems: 'flex-end',
  },
  valueText: {
    fontSize: 14,
    color: '#333',
  },
  valueEmpty: {
    fontSize: 14,
    color: '#ccc',
  },
  infoDivider: {
    height: StyleSheet.hairlineWidth,
    backgroundColor: '#f0f0f0',
  },

  // Delete
  deleteBtn: {
    marginTop: 10,
    backgroundColor: '#fff',
    borderRadius: 10,
    paddingVertical: 14,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#ffcdd2',
  },
  deleteBtnText: {
    fontSize: 15,
    color: '#f44336',
    fontWeight: '500',
  },

  // Empty
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  emptyText: {
    fontSize: 15,
    color: '#999',
  },
});

export default MemoDetailScreen;