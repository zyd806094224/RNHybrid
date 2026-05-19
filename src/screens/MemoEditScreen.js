import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
  Alert,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import SafeContainer from '../components/SafeContainer';
import {
  getCategoryList,
  getCategoryFields,
  getMemoDetail,
  createMemo,
  updateMemo,
  deleteMemo,
} from '../api/memo';

const MemoEditScreen = ({ navigation, route }) => {
  const isEdit = !!(route.params && route.params.memoId);
  const memoId = route.params?.memoId;

  const [categories, setCategories] = useState([]);
  const [categoryId, setCategoryId] = useState(null);
  const [memoName, setMemoName] = useState('');
  const [memoDesc, setMemoDesc] = useState('');
  const [fieldDefs, setFieldDefs] = useState([]);
  const [fieldValues, setFieldValues] = useState({});
  const [saving, setSaving] = useState(false);

  // 加载分类列表
  useEffect(() => {
    const loadCategories = async () => {
      const res = await getCategoryList();
      if (res.code === 0) {
        setCategories(res.data || []);
        // 新增模式下自动选第一个分类
        if (!isEdit && res.data && res.data.length > 0 && !categoryId) {
          setCategoryId(res.data[0].categoryId);
        }
      }
    };
    loadCategories();
  }, []);

  // 编辑模式加载已有数据
  useEffect(() => {
    if (isEdit) {
      loadDetail();
    }
  }, []);

  const loadDetail = async () => {
    const res = await getMemoDetail(memoId);
    if (res.code === 401) return;
    if (res.code === 0) {
      const data = res.data;
      setMemoName(data.memoInfo.memoName);
      setMemoDesc(data.memoInfo.memoDesc || '');
      setCategoryId(data.memoInfo.categoryId);

      const vals = {};
      if (data.fieldValues) {
        data.fieldValues.forEach(fv => {
          vals[fv.fieldId] = fv.fieldValue;
        });
      }
      setFieldValues(vals);

      // 单独请求字段定义
      if (data.memoInfo.categoryId) {
        const fieldRes = await getCategoryFields(data.memoInfo.categoryId);
        if (fieldRes.code === 0) {
          setFieldDefs(fieldRes.data || []);
        }
      }
    }
  };

  // 分类切换时加载字段定义
  const onCategoryChange = async catId => {
    setCategoryId(catId);
    setFieldDefs([]);
    setFieldValues({});

    if (!catId) return;
    const res = await getCategoryFields(catId);
    if (res.code === 0) {
      const defs = res.data || [];
      setFieldDefs(defs);
      // 初始化默认值
      const vals = {};
      defs.forEach(f => {
        if (f.defaultValue) {
          vals[f.fieldId] = f.defaultValue;
        }
      });
      setFieldValues(vals);
    }
  };

  const setFieldValue = (fieldId, value) => {
    setFieldValues(prev => ({ ...prev, [fieldId]: value }));
  };

  const handleSave = async () => {
    if (!memoName.trim()) {
      Alert.alert('提示', '请输入名称');
      return;
    }
    if (!categoryId) {
      Alert.alert('提示', '请选择分类');
      return;
    }

    setSaving(true);
    try {
      const fvs = Object.entries(fieldValues)
        .filter(([, value]) => value !== undefined && value !== null && value !== '')
        .map(([fieldId, value]) => ({
          fieldId: Number(fieldId),
          fieldValue: String(value),
        }));

      const data = {
        memoInfo: {
          categoryId,
          memoName: memoName.trim(),
          memoDesc: memoDesc.trim(),
        },
        fieldValues: fvs,
      };

      if (isEdit) {
        data.memoInfo.memoId = memoId;
        const res = await updateMemo(data);
        if (res.code === 401) return;
        if (res.code !== 0) {
          Alert.alert('错误', res.message || '更新失败');
          return;
        }
      } else {
        const res = await createMemo(data);
        if (res.code === 401) return;
        if (res.code !== 0) {
          Alert.alert('错误', res.message || '创建失败');
          return;
        }
      }
      navigation.goBack();
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = () => {
    Alert.alert('确认删除', `确定要删除「${memoName}」吗？`, [
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

  const parseOptions = jsonStr => {
    if (!jsonStr) return [];
    try {
      return JSON.parse(jsonStr);
    } catch {
      return [];
    }
  };

  const renderDynamicField = field => {
    const value = fieldValues[field.fieldId] ?? '';
    const placeholder = field.placeholder || `请输入${field.fieldName}`;

    switch (field.fieldType) {
      case 'textarea':
        return (
          <TextInput
            style={[styles.input, styles.textArea]}
            value={value}
            onChangeText={v => setFieldValue(field.fieldId, v)}
            placeholder={placeholder}
            placeholderTextColor="#bbb"
            multiline
            numberOfLines={3}
            textAlignVertical="top"
          />
        );

      case 'number':
        return (
          <TextInput
            style={styles.input}
            value={value}
            onChangeText={v => setFieldValue(field.fieldId, v)}
            placeholder={placeholder}
            placeholderTextColor="#bbb"
            keyboardType="numeric"
          />
        );

      case 'date':
        return (
          <TextInput
            style={styles.input}
            value={value}
            onChangeText={v => setFieldValue(field.fieldId, v)}
            placeholder={placeholder || 'YYYY-MM-DD'}
            placeholderTextColor="#bbb"
          />
        );

      case 'select':
        const selectOpts = parseOptions(field.fieldOptions);
        return (
          <View style={styles.optionsRow}>
            {selectOpts.map(opt => (
              <TouchableOpacity
                key={opt}
                style={[
                  styles.optionChip,
                  value === opt && styles.optionChipActive,
                ]}
                onPress={() => setFieldValue(field.fieldId, opt)}>
                <Text
                  style={[
                    styles.optionChipText,
                    value === opt && styles.optionChipTextActive,
                  ]}>
                  {opt}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        );

      case 'radio':
        const radioOpts = parseOptions(field.fieldOptions);
        return (
          <View style={styles.optionsRow}>
            {radioOpts.map(opt => (
              <TouchableOpacity
                key={opt}
                style={[
                  styles.optionChip,
                  value === opt && styles.optionChipActive,
                ]}
                onPress={() => setFieldValue(field.fieldId, opt)}>
                <Text
                  style={[
                    styles.optionChipText,
                    value === opt && styles.optionChipTextActive,
                  ]}>
                  {opt}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        );

      default: // text
        return (
          <TextInput
            style={styles.input}
            value={value}
            onChangeText={v => setFieldValue(field.fieldId, v)}
            placeholder={placeholder}
            placeholderTextColor="#bbb"
          />
        );
    }
  };

  return (
    <SafeContainer style={styles.container}>
      <KeyboardAvoidingView
        style={styles.flex}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        {/* Header */}
        <View style={styles.header}>
          <TouchableOpacity onPress={() => navigation.goBack()}>
            <Text style={styles.headerBack}>{'< 返回'}</Text>
          </TouchableOpacity>
          <Text style={styles.headerTitle}>
            {isEdit ? '编辑备忘录' : '新增备忘录'}
          </Text>
          <TouchableOpacity
            onPress={handleSave}
            disabled={saving}
            activeOpacity={0.7}>
            <Text
              style={[styles.headerSave, saving && styles.headerSaveDisabled]}>
              {saving ? '保存中...' : '保存'}
            </Text>
          </TouchableOpacity>
        </View>

        <ScrollView
          style={styles.form}
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}>
          {/* 分类 */}
          <View style={styles.field}>
            <Text style={styles.label}>
              分类 <Text style={styles.required}>*</Text>
            </Text>
            <View style={styles.categoryRow}>
              {categories.map(cat => (
                <TouchableOpacity
                  key={cat.categoryId}
                  style={[
                    styles.categoryChip,
                    categoryId === cat.categoryId && styles.categoryChipActive,
                  ]}
                  onPress={() => {
                    if (!isEdit) {
                      onCategoryChange(cat.categoryId);
                    } else {
                      setCategoryId(cat.categoryId);
                    }
                  }}>
                  <Text
                    style={[
                      styles.categoryChipText,
                      categoryId === cat.categoryId &&
                        styles.categoryChipTextActive,
                    ]}>
                    {cat.categoryName}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>
          </View>

          {/* 名称 */}
          <View style={styles.field}>
            <Text style={styles.label}>
              名称 <Text style={styles.required}>*</Text>
            </Text>
            <TextInput
              style={styles.input}
              value={memoName}
              onChangeText={setMemoName}
              placeholder="如：父亲、我的房子"
              placeholderTextColor="#bbb"
              maxLength={200}
            />
          </View>

          {/* 描述 */}
          <View style={styles.field}>
            <Text style={styles.label}>简要描述</Text>
            <TextInput
              style={[styles.input, styles.textArea]}
              value={memoDesc}
              onChangeText={setMemoDesc}
              placeholder="简要描述..."
              placeholderTextColor="#bbb"
              multiline
              numberOfLines={2}
              textAlignVertical="top"
              maxLength={500}
            />
          </View>

          {/* 动态字段 */}
          {fieldDefs.length > 0 && (
            <View style={styles.dividerSection}>
              <Text style={styles.dividerText}>详细信息</Text>
            </View>
          )}

          {fieldDefs.map(field => (
            <View key={field.fieldId} style={styles.field}>
              <Text style={styles.label}>
                {field.fieldName}
                {field.isRequired === '1' && (
                  <Text style={styles.required}> *</Text>
                )}
              </Text>
              {renderDynamicField(field)}
            </View>
          ))}

          {/* 无字段提示 */}
          {categoryId && fieldDefs.length === 0 && (
            <View style={styles.noFields}>
              <Text style={styles.noFieldsText}>
                该分类暂无字段定义，请先在分类管理中配置
              </Text>
            </View>
          )}

          {/* 编辑模式 — 删除按钮 */}
          {isEdit && (
            <TouchableOpacity
              style={styles.deleteBtn}
              onPress={handleDelete}
              activeOpacity={0.7}>
              <Text style={styles.deleteBtnText}>删除此备忘录</Text>
            </TouchableOpacity>
          )}

          <View style={{ height: 40 }} />
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeContainer>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f0f2f5',
  },
  flex: {
    flex: 1,
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
  headerSave: {
    fontSize: 15,
    color: '#4CAF50',
    fontWeight: '600',
  },
  headerSaveDisabled: {
    color: '#aaa',
  },

  // Form
  form: {
    flex: 1,
    paddingHorizontal: 16,
    paddingTop: 16,
  },
  field: {
    marginBottom: 18,
  },
  label: {
    fontSize: 14,
    color: '#555',
    marginBottom: 8,
    fontWeight: '500',
  },
  required: {
    color: '#f44336',
  },
  input: {
    backgroundColor: '#fff',
    borderRadius: 10,
    paddingHorizontal: 14,
    paddingVertical: 12,
    fontSize: 15,
    color: '#333',
    elevation: 1,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
  },
  textArea: {
    minHeight: 80,
    paddingTop: 12,
  },

  // Category chips
  categoryRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  categoryChip: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 18,
    backgroundColor: '#fff',
    marginRight: 10,
    marginBottom: 6,
    borderWidth: 1,
    borderColor: '#e0e0e0',
  },
  categoryChipActive: {
    backgroundColor: '#2196F3',
    borderColor: '#2196F3',
  },
  categoryChipText: {
    fontSize: 14,
    color: '#666',
  },
  categoryChipTextActive: {
    color: '#fff',
    fontWeight: '500',
  },

  // Options (select/radio)
  optionsRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  optionChip: {
    paddingHorizontal: 14,
    paddingVertical: 7,
    borderRadius: 16,
    backgroundColor: '#fff',
    marginRight: 8,
    marginBottom: 6,
    borderWidth: 1,
    borderColor: '#e0e0e0',
  },
  optionChipActive: {
    backgroundColor: '#2196F3',
    borderColor: '#2196F3',
  },
  optionChipText: {
    fontSize: 13,
    color: '#666',
  },
  optionChipTextActive: {
    color: '#fff',
    fontWeight: '500',
  },

  // Divider
  dividerSection: {
    marginTop: 4,
    marginBottom: 16,
    paddingBottom: 8,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#e0e0e0',
  },
  dividerText: {
    fontSize: 14,
    color: '#999',
    fontWeight: '500',
  },

  // No fields
  noFields: {
    padding: 20,
    alignItems: 'center',
  },
  noFieldsText: {
    fontSize: 13,
    color: '#ccc',
    textAlign: 'center',
  },

  // Delete
  deleteBtn: {
    marginTop: 20,
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
});

export default MemoEditScreen;