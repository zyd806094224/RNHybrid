/**
 * 备忘录管理 - API 接口层
 */

import { request } from './request';

// ==================== 分类 ====================

export async function getCategoryList() {
  return request('/api/memo/category/list');
}

export async function createCategory(data) {
  return request('/api/memo/category', {
    method: 'POST',
    body: JSON.stringify(data),
  });
}

export async function updateCategory(data) {
  return request('/api/memo/category', {
    method: 'PUT',
    body: JSON.stringify(data),
  });
}

export async function deleteCategory(categoryId) {
  return request(`/api/memo/category/${categoryId}`, {
    method: 'DELETE',
  });
}

// ==================== 字段定义 ====================

export async function getCategoryFields(categoryId) {
  return request(`/api/memo/category/${categoryId}/fields`);
}

// ==================== 备忘录 ====================

export async function getMemoList(params = {}) {
  const query = new URLSearchParams();
  if (params.pageNum) query.append('pageNum', params.pageNum);
  if (params.pageSize) query.append('pageSize', params.pageSize);
  if (params.memoName) query.append('memoName', params.memoName);
  if (params.categoryId) query.append('categoryId', params.categoryId);
  const qs = query.toString();
  return request(`/api/memo/info/list${qs ? '?' + qs : ''}`);
}

export async function getMemoDetail(memoId) {
  return request(`/api/memo/info/${memoId}`);
}

export async function createMemo(data) {
  return request('/api/memo/info', {
    method: 'POST',
    body: JSON.stringify(data),
  });
}

export async function updateMemo(data) {
  return request('/api/memo/info', {
    method: 'PUT',
    body: JSON.stringify(data),
  });
}

export async function deleteMemo(memoId) {
  return request(`/api/memo/info/${memoId}`, {
    method: 'DELETE',
  });
}