import React, {useState, useEffect, useCallback} from 'react';
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
  ActivityIndicator,
} from 'react-native';
import SafeContainer from '../components/SafeContainer';
import {
  createReminder,
  updateReminder,
  deleteReminder,
  getReminderDetail,
  CATEGORY_LIST,
} from '../api/reminder';

const EDIT_CATEGORIES = CATEGORY_LIST.filter(item => item.key !== 'all');

function isValidDateText(value) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) return false;
  const [year, month, day] = value.split('-').map(Number);
  const date = new Date(year, month - 1, day);
  return (
    date.getFullYear() === year &&
    date.getMonth() === month - 1 &&
    date.getDate() === day
  );
}

function normalizeTimeText(value) {
  if (!value) return '';
  const text = String(value).trim();
  if (/^\d{2}:\d{2}$/.test(text)) {
    return `${text}:00`;
  }
  return text;
}

function isValidTimeText(value) {
  const match = /^(\d{2}):(\d{2})(?::(\d{2}))?$/.exec(value);
  if (!match) return false;
  const hour = Number(match[1]);
  const minute = Number(match[2]);
  const second = match[3] === undefined ? 0 : Number(match[3]);
  return (
    hour >= 0 &&
    hour <= 23 &&
    minute >= 0 &&
    minute <= 59 &&
    second >= 0 &&
    second <= 59
  );
}

function isIntegerInRange(value, min, max) {
  if (!/^\d+$/.test(value)) return false;
  const num = Number(value);
  return num >= min && num <= max;
}

const ReminderEditScreen = ({navigation, route}) => {
  const routeReminder = route.params?.reminder || {};
  const reminderId = route.params?.reminderId || routeReminder.reminderId;
  const isEdit = !!reminderId;

  const [title, setTitle] = useState(routeReminder.title || '');
  const [description, setDescription] = useState(
    routeReminder.description || '',
  );
  const [category, setCategory] = useState(routeReminder.category || 'other');
  const [dueDate, setDueDate] = useState(routeReminder.dueDate || '');
  const [remindBeforeDays, setRemindBeforeDays] = useState(
    String(routeReminder.remindBeforeDays ?? 7),
  );
  const [remindTime, setRemindTime] = useState(
    normalizeTimeText(routeReminder.remindTime || '09:00:00'),
  );
  const [overdueFrequency, setOverdueFrequency] = useState(
    String(routeReminder.overdueFrequency ?? 1),
  );
  const [recipientEmail, setRecipientEmail] = useState(
    routeReminder.recipientEmail || '',
  );
  const [remark, setRemark] = useState(routeReminder.remark || '');
  const [saving, setSaving] = useState(false);
  const [loading, setLoading] = useState(false);

  const applyReminder = useCallback(item => {
    setTitle(item.title || '');
    setDescription(item.description || '');
    setCategory(item.category || 'other');
    setDueDate(item.dueDate || '');
    setRemindBeforeDays(String(item.remindBeforeDays ?? 7));
    setRemindTime(normalizeTimeText(item.remindTime || '09:00:00'));
    setOverdueFrequency(String(item.overdueFrequency ?? 1));
    setRecipientEmail(item.recipientEmail || '');
    setRemark(item.remark || '');
  }, []);

  useEffect(() => {
    if (!isEdit) return;

    const loadDetail = async () => {
      setLoading(true);
      try {
        const res = await getReminderDetail(reminderId);
        if (res.code === 401) return;
        if (res.code === 0) {
          applyReminder(res.data || {});
        }
      } finally {
        setLoading(false);
      }
    };

    loadDetail();
  }, [isEdit, reminderId, applyReminder]);

  const validate = () => {
    if (!title.trim()) {
      Alert.alert('提示', '请输入事项标题');
      return false;
    }
    if (!dueDate.trim()) {
      Alert.alert('提示', '请输入到期日期');
      return false;
    }
    if (!isValidDateText(dueDate.trim())) {
      Alert.alert('提示', '到期日期格式应为 YYYY-MM-DD');
      return false;
    }
    const nextRemindTime = normalizeTimeText(remindTime.trim());
    if (!nextRemindTime || !isValidTimeText(nextRemindTime)) {
      Alert.alert('提示', '提醒时间格式应为 HH:mm 或 HH:mm:ss');
      return false;
    }
    if (!isIntegerInRange(remindBeforeDays.trim(), 0, 365)) {
      Alert.alert('提示', '提前天数应为 0-365 的整数');
      return false;
    }
    if (!isIntegerInRange(overdueFrequency.trim(), 0, 365)) {
      Alert.alert('提示', '过期频率应为 0-365 的整数');
      return false;
    }
    return true;
  };

  const buildPayload = () => ({
    title: title.trim(),
    description: description.trim(),
    category,
    dueDate: dueDate.trim(),
    remindBeforeDays: Number(remindBeforeDays.trim()),
    remindTime: normalizeTimeText(remindTime.trim()),
    overdueFrequency: Number(overdueFrequency.trim()),
    recipientEmail: recipientEmail.trim(),
    remark: remark.trim(),
  });

  const handleSave = async () => {
    if (!validate()) {
      return;
    }

    setSaving(true);
    try {
      const data = buildPayload();
      const res = isEdit
        ? await updateReminder(reminderId, data)
        : await createReminder(data);
      if (res.code === 401) return;
      if (res.code !== 0) {
        Alert.alert('错误', res.message || (isEdit ? '更新失败' : '创建失败'));
        return;
      }
      navigation.goBack();
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = () => {
    Alert.alert('确认删除', `确定要删除「${title}」吗？`, [
      {text: '取消', style: 'cancel'},
      {
        text: '删除',
        style: 'destructive',
        onPress: async () => {
          const res = await deleteReminder(reminderId);
          if (res.code === 401) return;
          if (res.code !== 0) {
            Alert.alert('错误', res.message || '删除失败');
            return;
          }
          navigation.goBack();
        },
      },
    ]);
  };

  return (
    <SafeContainer style={styles.container}>
      <KeyboardAvoidingView
        style={styles.flex}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <View style={styles.header}>
          <TouchableOpacity onPress={() => navigation.goBack()}>
            <Text style={styles.headerBack}>{'< 返回'}</Text>
          </TouchableOpacity>
          <Text style={styles.headerTitle}>
            {isEdit ? '编辑提醒事项' : '新增提醒事项'}
          </Text>
          <TouchableOpacity
            onPress={handleSave}
            disabled={saving}
            activeOpacity={0.7}
          >
            <Text
              style={[styles.headerSave, saving && styles.headerSaveDisabled]}
            >
              {saving ? '保存中...' : '保存'}
            </Text>
          </TouchableOpacity>
        </View>

        {loading ? (
          <View style={styles.loadingBar}>
            <ActivityIndicator size="small" color="#2196F3" />
            <Text style={styles.loadingText}>加载中...</Text>
          </View>
        ) : null}

        <ScrollView
          style={styles.form}
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
        >
          <View style={styles.field}>
            <Text style={styles.label}>
              事项标题 <Text style={styles.required}>*</Text>
            </Text>
            <TextInput
              style={styles.input}
              value={title}
              onChangeText={setTitle}
              placeholder="如：证件到期、订阅续费"
              placeholderTextColor="#bbb"
              maxLength={200}
            />
          </View>

          <View style={styles.field}>
            <Text style={styles.label}>事项描述</Text>
            <TextInput
              style={[styles.input, styles.textArea]}
              value={description}
              onChangeText={setDescription}
              placeholder="请输入事项描述"
              placeholderTextColor="#bbb"
              multiline
              numberOfLines={3}
              textAlignVertical="top"
              maxLength={1000}
            />
          </View>

          <View style={styles.field}>
            <Text style={styles.label}>分类</Text>
            <View style={styles.categoryRow}>
              {EDIT_CATEGORIES.map(item => (
                <TouchableOpacity
                  key={item.key}
                  style={[
                    styles.categoryChip,
                    category === item.key && styles.categoryChipActive,
                  ]}
                  onPress={() => setCategory(item.key)}
                >
                  <Text
                    style={[
                      styles.categoryChipText,
                      category === item.key && styles.categoryChipTextActive,
                    ]}
                  >
                    {item.label}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>
          </View>

          <View style={styles.field}>
            <Text style={styles.label}>
              到期日期 <Text style={styles.required}>*</Text>
            </Text>
            <TextInput
              style={styles.input}
              value={dueDate}
              onChangeText={setDueDate}
              placeholder="YYYY-MM-DD"
              placeholderTextColor="#bbb"
              keyboardType="numbers-and-punctuation"
              maxLength={10}
            />
          </View>

          <View style={styles.twoColumn}>
            <View style={[styles.field, styles.columnField]}>
              <Text style={styles.label}>提前天数</Text>
              <TextInput
                style={styles.input}
                value={remindBeforeDays}
                onChangeText={setRemindBeforeDays}
                placeholder="7"
                placeholderTextColor="#bbb"
                keyboardType="number-pad"
                maxLength={3}
              />
            </View>
            <View style={[styles.field, styles.columnField]}>
              <Text style={styles.label}>过期频率(天)</Text>
              <TextInput
                style={styles.input}
                value={overdueFrequency}
                onChangeText={setOverdueFrequency}
                placeholder="1"
                placeholderTextColor="#bbb"
                keyboardType="number-pad"
                maxLength={3}
              />
            </View>
          </View>

          <View style={styles.field}>
            <Text style={styles.label}>提醒时间</Text>
            <TextInput
              style={styles.input}
              value={remindTime}
              onChangeText={setRemindTime}
              placeholder="09:00:00"
              placeholderTextColor="#bbb"
              keyboardType="numbers-and-punctuation"
              maxLength={8}
            />
            <Text style={styles.helpText}>支持 HH:mm 或 HH:mm:ss</Text>
          </View>

          <View style={styles.field}>
            <Text style={styles.label}>收件邮箱</Text>
            <TextInput
              style={styles.input}
              value={recipientEmail}
              onChangeText={setRecipientEmail}
              placeholder="为空则使用默认邮箱"
              placeholderTextColor="#bbb"
              autoCapitalize="none"
              autoCorrect={false}
              keyboardType="email-address"
              maxLength={200}
            />
          </View>

          <View style={styles.field}>
            <Text style={styles.label}>备注</Text>
            <TextInput
              style={[styles.input, styles.textArea]}
              value={remark}
              onChangeText={setRemark}
              placeholder="请输入备注"
              placeholderTextColor="#bbb"
              multiline
              numberOfLines={3}
              textAlignVertical="top"
              maxLength={500}
            />
          </View>

          {isEdit ? (
            <TouchableOpacity
              style={styles.deleteBtn}
              onPress={handleDelete}
              activeOpacity={0.7}
            >
              <Text style={styles.deleteBtnText}>删除此提醒事项</Text>
            </TouchableOpacity>
          ) : null}

          <View style={{height: 40}} />
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
  loadingBar: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 8,
    backgroundColor: '#fff',
  },
  loadingText: {
    fontSize: 12,
    color: '#999',
    marginLeft: 6,
  },
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
    shadowOffset: {width: 0, height: 1},
    shadowOpacity: 0.05,
    shadowRadius: 2,
  },
  textArea: {
    minHeight: 86,
    paddingTop: 12,
  },
  helpText: {
    fontSize: 12,
    color: '#aaa',
    marginTop: 6,
  },
  categoryRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  categoryChip: {
    paddingHorizontal: 15,
    paddingVertical: 8,
    borderRadius: 18,
    backgroundColor: '#fff',
    marginRight: 9,
    marginBottom: 8,
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
  twoColumn: {
    flexDirection: 'row',
    marginHorizontal: -5,
  },
  columnField: {
    flex: 1,
    marginHorizontal: 5,
  },
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

export default ReminderEditScreen;
