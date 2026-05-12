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
import { createAccount, updateAccount, deleteAccount, CATEGORIES } from '../api/account';

const CATEGORY_OPTIONS = [
  CATEGORIES.social,
  CATEGORIES.work,
  CATEGORIES.finance,
  CATEGORIES.other,
];

const AccountEditScreen = ({ navigation, route }) => {
  const isEdit = !!(route.params && route.params.accountId);
  const existing = (route.params && route.params.account) || {};

  const [title, setTitle] = useState(existing.title || '');
  const [category, setCategory] = useState(existing.category || 'other');
  const [username, setUsername] = useState(existing.username || '');
  const [password, setPassword] = useState(existing.password || '');
  const [url, setUrl] = useState(existing.url || '');
  const [remark, setRemark] = useState(existing.remark || '');
  const [showPassword, setShowPassword] = useState(false);
  const [saving, setSaving] = useState(false);

  const handleSave = async () => {
    if (!title.trim()) {
      Alert.alert('提示', '请输入标题');
      return;
    }
    if (!username.trim()) {
      Alert.alert('提示', '请输入账号');
      return;
    }
    if (!password.trim()) {
      Alert.alert('提示', '请输入密码');
      return;
    }

    setSaving(true);
    try {
      const data = {
        title: title.trim(),
        category,
        username: username.trim(),
        password: password.trim(),
        url: url.trim(),
        remark: remark.trim(),
      };

      if (isEdit) {
        const res = await updateAccount(existing.accountId, data);
        if (res.code === 401) {
          return;
        }
        if (res.code !== 0) {
          Alert.alert('错误', res.message || '更新失败');
          return;
        }
      } else {
        const res = await createAccount(data);
        if (res.code === 401) {
          return;
        }
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
    Alert.alert('确认删除', `确定要删除「${title}」吗？此操作不可恢复。`, [
      { text: '取消', style: 'cancel' },
      {
        text: '删除',
        style: 'destructive',
        onPress: async () => {
          const res = await deleteAccount(existing.accountId);
          if (res.code === 401) {
            // 401 已由 API 层通知原生端处理
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
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        {/* Header */}
        <View style={styles.header}>
          <TouchableOpacity onPress={() => navigation.goBack()}>
            <Text style={styles.headerBack}>{'< 返回'}</Text>
          </TouchableOpacity>
          <Text style={styles.headerTitle}>
            {isEdit ? '编辑账号' : '新增账号'}
          </Text>
          <TouchableOpacity
            onPress={handleSave}
            disabled={saving}
            activeOpacity={0.7}>
            <Text
              style={[
                styles.headerSave,
                saving && styles.headerSaveDisabled,
              ]}>
              {saving ? '保存中...' : '保存'}
            </Text>
          </TouchableOpacity>
        </View>

        <ScrollView
          style={styles.form}
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}>
          {/* 标题 */}
          <View style={styles.field}>
            <Text style={styles.label}>
              标题 <Text style={styles.required}>*</Text>
            </Text>
            <TextInput
              style={styles.input}
              value={title}
              onChangeText={setTitle}
              placeholder="如：微信、GitHub"
              placeholderTextColor="#bbb"
              maxLength={50}
            />
          </View>

          {/* 分类 */}
          <View style={styles.field}>
            <Text style={styles.label}>分类</Text>
            <View style={styles.categoryRow}>
              {CATEGORY_OPTIONS.map(cat => (
                <TouchableOpacity
                  key={cat.key}
                  style={[
                    styles.categoryChip,
                    category === cat.key && styles.categoryChipActive,
                  ]}
                  onPress={() => setCategory(cat.key)}>
                  <Text
                    style={[
                      styles.categoryChipText,
                      category === cat.key && styles.categoryChipTextActive,
                    ]}>
                    {cat.label}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>
          </View>

          {/* 账号 */}
          <View style={styles.field}>
            <Text style={styles.label}>
              账号 <Text style={styles.required}>*</Text>
            </Text>
            <TextInput
              style={styles.input}
              value={username}
              onChangeText={setUsername}
              placeholder="手机号/邮箱/用户名"
              placeholderTextColor="#bbb"
              autoCapitalize="none"
              autoCorrect={false}
              keyboardType="email-address"
              maxLength={100}
            />
          </View>

          {/* 密码 */}
          <View style={styles.field}>
            <Text style={styles.label}>
              密码 <Text style={styles.required}>*</Text>
            </Text>
            <View style={styles.passwordWrapper}>
              <TextInput
                style={styles.passwordInput}
                value={password}
                onChangeText={setPassword}
                placeholder="输入密码"
                placeholderTextColor="#bbb"
                secureTextEntry={!showPassword}
                autoCapitalize="none"
                autoCorrect={false}
                maxLength={100}
              />
              <TouchableOpacity
                style={styles.toggleBtn}
                onPress={() => setShowPassword(!showPassword)}>
                <Text style={styles.toggleText}>
                  {showPassword ? '隐藏' : '显示'}
                </Text>
              </TouchableOpacity>
            </View>
          </View>

          {/* 网址 */}
          <View style={styles.field}>
            <Text style={styles.label}>网址</Text>
            <TextInput
              style={styles.input}
              value={url}
              onChangeText={setUrl}
              placeholder="https://example.com"
              placeholderTextColor="#bbb"
              autoCapitalize="none"
              autoCorrect={false}
              keyboardType="url"
              maxLength={200}
            />
          </View>

          {/* 备注 */}
          <View style={styles.field}>
            <Text style={styles.label}>备注</Text>
            <TextInput
              style={[styles.input, styles.textArea]}
              value={remark}
              onChangeText={setRemark}
              placeholder="备注信息..."
              placeholderTextColor="#bbb"
              multiline
              numberOfLines={3}
              textAlignVertical="top"
              maxLength={500}
            />
          </View>

          {/* 编辑模式 — 删除按钮 */}
          {isEdit && (
            <TouchableOpacity
              style={styles.deleteBtn}
              onPress={handleDelete}
              activeOpacity={0.7}>
              <Text style={styles.deleteBtnText}>删除此账号</Text>
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

  // Password
  passwordWrapper: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    borderRadius: 10,
    paddingRight: 4,
    elevation: 1,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
  },
  passwordInput: {
    flex: 1,
    paddingHorizontal: 14,
    paddingVertical: 12,
    fontSize: 15,
    color: '#333',
  },
  toggleBtn: {
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  toggleText: {
    fontSize: 13,
    color: '#2196F3',
    fontWeight: '500',
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

export default AccountEditScreen;
