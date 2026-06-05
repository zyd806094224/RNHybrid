/**
 * 提醒事项管理 - API 接口层
 */

import {request} from './request';

export const REMINDER_CATEGORIES = {
  all: {key: 'all', label: '全部', color: '#2196F3'},
  work: {key: 'work', label: '工作', color: '#3F51B5'},
  life: {key: 'life', label: '生活', color: '#4CAF50'},
  finance: {key: 'finance', label: '财务', color: '#FF9800'},
  health: {key: 'health', label: '健康', color: '#F44336'},
  subscription: {key: 'subscription', label: '订阅', color: '#00BCD4'},
  license: {key: 'license', label: '证件', color: '#795548'},
  other: {key: 'other', label: '其他', color: '#9E9E9E'},
};

export const REMINDER_STATUS = {
  all: {key: 'all', label: '全部', color: '#2196F3'},
  pending: {key: '0', label: '待提醒', color: '#607D8B'},
  reminding: {key: '1', label: '提醒中', color: '#FF9800'},
  overdue: {key: '2', label: '已到期', color: '#F44336'},
  completed: {key: '3', label: '已完成', color: '#4CAF50'},
  closed: {key: '4', label: '已关闭', color: '#9E9E9E'},
};

export const CATEGORY_LIST = Object.values(REMINDER_CATEGORIES);
export const STATUS_LIST = Object.values(REMINDER_STATUS);

export function getReminderCategory(category) {
  return REMINDER_CATEGORIES[category] || REMINDER_CATEGORIES.other;
}

export function getReminderStatus(status) {
  return (
    STATUS_LIST.find(item => item.key === String(status ?? '')) ||
    REMINDER_STATUS.pending
  );
}

export async function getReminderList(params = {}) {
  const query = new URLSearchParams();
  if (params.pageNum) query.append('pageNum', params.pageNum);
  if (params.pageSize) query.append('pageSize', params.pageSize);
  if (params.title) query.append('title', params.title);
  if (params.category && params.category !== 'all') {
    query.append('category', params.category);
  }
  if (params.status && params.status !== 'all') {
    query.append('status', params.status);
  }
  const qs = query.toString();
  return request(`/api/reminder/list${qs ? '?' + qs : ''}`);
}

export async function getReminderDetail(reminderId) {
  return request(`/api/reminder/${reminderId}`);
}

export async function createReminder(data) {
  return request('/api/reminder', {
    method: 'POST',
    body: JSON.stringify(data),
  });
}

export async function updateReminder(reminderId, data) {
  return request(`/api/reminder/${reminderId}`, {
    method: 'PUT',
    body: JSON.stringify(data),
  });
}

export async function deleteReminder(reminderId) {
  return request(`/api/reminder/${reminderId}`, {
    method: 'DELETE',
  });
}

export async function renewReminder(reminderId, newDueDate) {
  return request(`/api/reminder/${reminderId}/renew`, {
    method: 'PUT',
    body: JSON.stringify({newDueDate}),
  });
}

export async function completeReminder(reminderId) {
  return request(`/api/reminder/${reminderId}/complete`, {
    method: 'PUT',
  });
}

export async function closeReminder(reminderId) {
  return request(`/api/reminder/${reminderId}/close`, {
    method: 'PUT',
  });
}

export async function sendReminder(reminderId, customContent) {
  return request(`/api/reminder/${reminderId}/send`, {
    method: 'POST',
    body: JSON.stringify({customContent}),
  });
}
