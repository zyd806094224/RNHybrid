import React, {useState, useEffect, useCallback} from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
  Alert,
  TextInput,
  ActivityIndicator,
} from 'react-native';
import SafeContainer from '../components/SafeContainer';
import {
  getReminderDetail,
  deleteReminder,
  renewReminder,
  completeReminder,
  closeReminder,
  sendReminder,
  getReminderCategory,
  getReminderStatus,
} from '../api/reminder';

const MS_PER_DAY = 24 * 60 * 60 * 1000;
const TERMINAL_STATUS = ['3', '4'];

function parseLocalDate(value) {
  if (!value) return null;
  const dateText = String(value).split(' ')[0];
  const parts = dateText.split('-').map(Number);
  if (parts.length !== 3 || parts.some(Number.isNaN)) {
    return null;
  }
  return new Date(parts[0], parts[1] - 1, parts[2]);
}

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

function calculateDays(dueDate) {
  const due = parseLocalDate(dueDate);
  if (!due) return 0;
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  return Math.round((due.getTime() - today.getTime()) / MS_PER_DAY);
}

function getDaysText(dueDate) {
  const days = calculateDays(dueDate);
  if (days > 0) return `还有${days}天`;
  if (days === 0) return '今天到期';
  return `已过期${Math.abs(days)}天`;
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

function formatValue(value) {
  if (value === undefined || value === null || value === '') {
    return '-';
  }
  return String(value);
}

const ReminderDetailScreen = ({navigation, route}) => {
  const reminderId = route.params?.reminderId;
  const [detail, setDetail] = useState(null);
  const [loading, setLoading] = useState(false);
  const [activePanel, setActivePanel] = useState(null);
  const [renewDate, setRenewDate] = useState('');
  const [sendContent, setSendContent] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const loadDetail = useCallback(async () => {
    if (!reminderId) return;
    setLoading(true);
    try {
      const res = await getReminderDetail(reminderId);
      if (res.code === 401) return;
      if (res.code === 0) {
        setDetail(res.data);
      } else {
        Alert.alert('错误', res.message || '加载提醒事项失败');
      }
    } finally {
      setLoading(false);
    }
  }, [reminderId]);

  useEffect(() => {
    loadDetail();
  }, [loadDetail]);

  useEffect(() => {
    const unsubscribe = navigation.addListener('focus', () => {
      loadDetail();
    });
    return unsubscribe;
  }, [navigation, loadDetail]);

  const refreshAfterAction = async () => {
    setActivePanel(null);
    await loadDetail();
  };

  const handleDelete = () => {
    if (!detail) return;
    Alert.alert('确认删除', `确定要删除「${detail.title}」吗？`, [
      {text: '取消', style: 'cancel'},
      {
        text: '删除',
        style: 'destructive',
        onPress: async () => {
          const res = await deleteReminder(detail.reminderId);
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

  const handleComplete = () => {
    if (!detail) return;
    Alert.alert('确认完成', '确定将该提醒事项标记为已完成吗？', [
      {text: '取消', style: 'cancel'},
      {
        text: '完成',
        onPress: async () => {
          const res = await completeReminder(detail.reminderId);
          if (res.code === 401) return;
          if (res.code !== 0) {
            Alert.alert('错误', res.message || '操作失败');
            return;
          }
          refreshAfterAction();
        },
      },
    ]);
  };

  const handleClose = () => {
    if (!detail) return;
    Alert.alert('确认关闭', '关闭后该事项将不再自动提醒，确定关闭吗？', [
      {text: '取消', style: 'cancel'},
      {
        text: '关闭',
        style: 'destructive',
        onPress: async () => {
          const res = await closeReminder(detail.reminderId);
          if (res.code === 401) return;
          if (res.code !== 0) {
            Alert.alert('错误', res.message || '关闭失败');
            return;
          }
          refreshAfterAction();
        },
      },
    ]);
  };

  const submitRenew = async () => {
    if (!renewDate.trim()) {
      Alert.alert('提示', '请输入新的到期日期');
      return;
    }
    if (!isValidDateText(renewDate.trim())) {
      Alert.alert('提示', '日期格式应为 YYYY-MM-DD');
      return;
    }

    setSubmitting(true);
    try {
      const res = await renewReminder(detail.reminderId, renewDate.trim());
      if (res.code === 401) return;
      if (res.code !== 0) {
        Alert.alert('错误', res.message || '续期失败');
        return;
      }
      setRenewDate('');
      refreshAfterAction();
    } finally {
      setSubmitting(false);
    }
  };

  const submitSend = async () => {
    setSubmitting(true);
    try {
      const res = await sendReminder(detail.reminderId, sendContent.trim());
      if (res.code === 401) return;
      if (res.code !== 0) {
        Alert.alert('错误', res.message || '发送失败');
        return;
      }
      Alert.alert('提示', res.data || '提醒邮件已发送');
      setSendContent('');
      setActivePanel(null);
    } finally {
      setSubmitting(false);
    }
  };

  const openRenewPanel = () => {
    setRenewDate('');
    setActivePanel(activePanel === 'renew' ? null : 'renew');
  };

  const openSendPanel = () => {
    setSendContent('');
    setActivePanel(activePanel === 'send' ? null : 'send');
  };

  const renderInfoRow = (label, value, valueStyle) => (
    <View style={styles.infoRow}>
      <Text style={styles.infoLabel}>{label}</Text>
      <Text style={[styles.infoValue, valueStyle]}>{formatValue(value)}</Text>
    </View>
  );

  const renderDivider = () => <View style={styles.infoDivider} />;

  if (!detail) {
    return (
      <SafeContainer style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity onPress={() => navigation.goBack()}>
            <Text style={styles.headerBack}>{'< 返回'}</Text>
          </TouchableOpacity>
          <Text style={styles.headerTitle}>提醒详情</Text>
          <View style={{width: 50}} />
        </View>
        <View style={styles.loadingWrap}>
          {loading ? (
            <ActivityIndicator size="small" color="#2196F3" />
          ) : (
            <Text style={styles.emptyText}>暂无数据</Text>
          )}
        </View>
      </SafeContainer>
    );
  }

  const category = getReminderCategory(detail.category);
  const status = getReminderStatus(detail.status);
  const isTerminal = TERMINAL_STATUS.includes(detail.status);
  const daysColor = getDaysColor(detail.dueDate);

  return (
    <SafeContainer style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()}>
          <Text style={styles.headerBack}>{'< 返回'}</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle} numberOfLines={1}>
          {detail.title}
        </Text>
        <TouchableOpacity
          onPress={() =>
            navigation.navigate('ReminderEdit', {
              reminderId: detail.reminderId,
              reminder: detail,
            })
          }
        >
          <Text style={styles.headerEdit}>编辑</Text>
        </TouchableOpacity>
      </View>

      <ScrollView
        style={styles.scrollContent}
        keyboardShouldPersistTaps="handled"
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.heroCard}>
          <View style={styles.heroTitleRow}>
            <Text style={styles.heroTitle}>{detail.title}</Text>
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
          {detail.description ? (
            <Text style={styles.heroDesc}>{detail.description}</Text>
          ) : null}
          <View style={styles.dueBlock}>
            <Text style={styles.dueLabel}>到期日期</Text>
            <Text style={styles.dueDate}>{detail.dueDate}</Text>
            <Text style={[styles.dueText, {color: daysColor}]}>
              {getDaysText(detail.dueDate)}
            </Text>
          </View>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>操作</Text>
          <View style={styles.actionCard}>
            {!isTerminal ? (
              <TouchableOpacity
                style={styles.actionButton}
                onPress={openRenewPanel}
              >
                <Text style={styles.actionText}>续期</Text>
              </TouchableOpacity>
            ) : null}
            {detail.status !== '3' ? (
              <TouchableOpacity
                style={styles.actionButton}
                onPress={handleComplete}
              >
                <Text style={styles.actionText}>完成</Text>
              </TouchableOpacity>
            ) : null}
            {!isTerminal ? (
              <TouchableOpacity
                style={styles.actionButton}
                onPress={handleClose}
              >
                <Text style={styles.actionText}>关闭提醒</Text>
              </TouchableOpacity>
            ) : null}
            <TouchableOpacity
              style={styles.actionButton}
              onPress={openSendPanel}
            >
              <Text style={styles.actionText}>发送提醒</Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[styles.actionButton, styles.actionDanger]}
              onPress={handleDelete}
            >
              <Text style={[styles.actionText, styles.actionDangerText]}>
                删除
              </Text>
            </TouchableOpacity>
          </View>
        </View>

        {activePanel === 'renew' ? (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>续期</Text>
            <View style={styles.panelCard}>
              <Text style={styles.panelLabel}>新的到期日期</Text>
              <TextInput
                style={styles.input}
                value={renewDate}
                onChangeText={setRenewDate}
                placeholder="YYYY-MM-DD"
                placeholderTextColor="#bbb"
                keyboardType="numbers-and-punctuation"
                maxLength={10}
              />
              <View style={styles.panelActions}>
                <TouchableOpacity
                  style={styles.panelCancel}
                  onPress={() => setActivePanel(null)}
                >
                  <Text style={styles.panelCancelText}>取消</Text>
                </TouchableOpacity>
                <TouchableOpacity
                  style={[
                    styles.panelSubmit,
                    submitting && styles.panelSubmitDisabled,
                  ]}
                  onPress={submitRenew}
                  disabled={submitting}
                >
                  <Text style={styles.panelSubmitText}>
                    {submitting ? '提交中...' : '确认续期'}
                  </Text>
                </TouchableOpacity>
              </View>
            </View>
          </View>
        ) : null}

        {activePanel === 'send' ? (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>发送提醒</Text>
            <View style={styles.panelCard}>
              <Text style={styles.panelLabel}>自定义内容</Text>
              <TextInput
                style={[styles.input, styles.textArea]}
                value={sendContent}
                onChangeText={setSendContent}
                placeholder="可输入额外的提醒内容（可选）"
                placeholderTextColor="#bbb"
                multiline
                numberOfLines={4}
                textAlignVertical="top"
                maxLength={500}
              />
              <View style={styles.panelActions}>
                <TouchableOpacity
                  style={styles.panelCancel}
                  onPress={() => setActivePanel(null)}
                >
                  <Text style={styles.panelCancelText}>取消</Text>
                </TouchableOpacity>
                <TouchableOpacity
                  style={[
                    styles.panelSubmit,
                    submitting && styles.panelSubmitDisabled,
                  ]}
                  onPress={submitSend}
                  disabled={submitting}
                >
                  <Text style={styles.panelSubmitText}>
                    {submitting ? '发送中...' : '发送提醒'}
                  </Text>
                </TouchableOpacity>
              </View>
            </View>
          </View>
        ) : null}

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>基本信息</Text>
          <View style={styles.infoCard}>
            {renderInfoRow('分类', category.label, {color: category.color})}
            {renderDivider()}
            {renderInfoRow('到期日期', detail.dueDate)}
            {renderDivider()}
            {renderInfoRow('剩余/过期', getDaysText(detail.dueDate), {
              color: daysColor,
            })}
            {renderDivider()}
            {renderInfoRow('当前状态', status.label, {color: status.color})}
            {renderDivider()}
            {renderInfoRow(
              '提醒规则',
              `提前${detail.remindBeforeDays ?? 7}天，${formatTime(
                detail.remindTime,
              )}提醒`,
            )}
            {renderDivider()}
            {renderInfoRow('过期频率', `${detail.overdueFrequency ?? 1}天/次`)}
          </View>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>通知信息</Text>
          <View style={styles.infoCard}>
            {renderInfoRow('收件邮箱', detail.recipientEmail)}
            {renderDivider()}
            {renderInfoRow('下次提醒', detail.nextRemindTime)}
            {renderDivider()}
            {renderInfoRow('最后提醒', detail.lastRemindTime)}
          </View>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>续期记录</Text>
          <View style={styles.infoCard}>
            {renderInfoRow('续期次数', `${detail.renewalCount ?? 0}次`)}
            {renderDivider()}
            {renderInfoRow('原始到期日', detail.originalDueDate)}
            {renderDivider()}
            {renderInfoRow('最后续期', detail.lastRenewalDate)}
          </View>
        </View>

        {detail.remark ? (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>备注</Text>
            <View style={styles.infoCard}>
              <Text style={styles.remarkText}>{detail.remark}</Text>
            </View>
          </View>
        ) : null}

        <View style={{height: 40}} />
      </ScrollView>
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
    flex: 1,
    textAlign: 'center',
  },
  headerEdit: {
    fontSize: 15,
    color: '#2196F3',
    fontWeight: '600',
  },
  loadingWrap: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  emptyText: {
    fontSize: 15,
    color: '#999',
  },
  scrollContent: {
    flex: 1,
    paddingHorizontal: 16,
    paddingTop: 16,
  },
  heroCard: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 18,
    marginBottom: 18,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 1},
    shadowOpacity: 0.08,
    shadowRadius: 4,
  },
  heroTitleRow: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    justifyContent: 'space-between',
  },
  heroTitle: {
    flex: 1,
    fontSize: 20,
    lineHeight: 27,
    color: '#222',
    fontWeight: '700',
    paddingRight: 10,
  },
  heroDesc: {
    marginTop: 10,
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
  },
  statusBadge: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 10,
  },
  statusBadgeText: {
    fontSize: 12,
    fontWeight: '600',
  },
  dueBlock: {
    marginTop: 16,
    paddingTop: 16,
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: '#eee',
  },
  dueLabel: {
    fontSize: 12,
    color: '#999',
    marginBottom: 4,
  },
  dueDate: {
    fontSize: 24,
    color: '#333',
    fontWeight: '700',
  },
  dueText: {
    marginTop: 4,
    fontSize: 14,
    fontWeight: '600',
  },
  section: {
    marginBottom: 18,
  },
  sectionTitle: {
    fontSize: 14,
    color: '#999',
    marginBottom: 8,
    fontWeight: '500',
  },
  actionCard: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 10,
    elevation: 1,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 1},
    shadowOpacity: 0.05,
    shadowRadius: 2,
  },
  actionButton: {
    minWidth: 88,
    paddingHorizontal: 12,
    paddingVertical: 9,
    borderRadius: 18,
    backgroundColor: '#f0f7ff',
    marginRight: 8,
    marginBottom: 8,
    alignItems: 'center',
  },
  actionText: {
    fontSize: 13,
    color: '#2196F3',
    fontWeight: '600',
  },
  actionDanger: {
    backgroundColor: '#fff5f5',
  },
  actionDangerText: {
    color: '#F44336',
  },
  panelCard: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    elevation: 1,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 1},
    shadowOpacity: 0.05,
    shadowRadius: 2,
  },
  panelLabel: {
    fontSize: 14,
    color: '#555',
    marginBottom: 8,
    fontWeight: '500',
  },
  input: {
    backgroundColor: '#f7f7f7',
    borderRadius: 10,
    paddingHorizontal: 14,
    paddingVertical: 12,
    fontSize: 15,
    color: '#333',
  },
  textArea: {
    minHeight: 96,
    paddingTop: 12,
  },
  panelActions: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    marginTop: 14,
  },
  panelCancel: {
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 20,
    backgroundColor: '#f5f5f5',
    marginRight: 10,
  },
  panelCancelText: {
    fontSize: 14,
    color: '#666',
  },
  panelSubmit: {
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 20,
    backgroundColor: '#2196F3',
  },
  panelSubmitDisabled: {
    backgroundColor: '#b0d8f7',
  },
  panelSubmitText: {
    fontSize: 14,
    color: '#fff',
    fontWeight: '600',
  },
  infoCard: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    elevation: 1,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 1},
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
    width: 86,
    fontSize: 14,
    color: '#999',
  },
  infoValue: {
    flex: 1,
    fontSize: 14,
    color: '#333',
    textAlign: 'right',
    lineHeight: 20,
  },
  infoDivider: {
    height: StyleSheet.hairlineWidth,
    backgroundColor: '#eee',
  },
  remarkText: {
    fontSize: 14,
    color: '#333',
    lineHeight: 21,
  },
});

export default ReminderDetailScreen;
