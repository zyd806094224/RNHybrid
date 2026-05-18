/*
 * @Author: zhaoyudong
 * @Date: 2026-05-18 16:47:47
 * @LastEditors: zhaoyudong
 * @LastEditTime: 2026-05-18 16:47:47
 * @Description: ----
 *
 * 页面功能：
 *   ----
 */
/**
 * 备忘录管理 - API 接口层
 */

import { getToken, handleTokenExpired } from './auth';

const BASE_URL = 'https://106.15.7.132:8443';

async function request(url, options = {}) {
  const token = getToken();
  const headers = {
    'Content-Type': 'application/json',
    ...options.headers,
  };
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  try {
    const response = await fetch(`${BASE_URL}${url}`, {
      ...options,
      headers,
    });

    if (response.status === 401) {
      handleTokenExpired();
      return { code: 401, data: null, message: '登录已过期，请重新登录' };
    }

    const json = await response.json();

    if (json.code === 401) {
      handleTokenExpired();
      return { code: 401, data: null, message: '登录已过期，请重新登录' };
    }

    if (json.code === 200) {
      return { code: 0, data: json.data ?? json.rows ?? null, total: json.total ?? 0 };
    }

    return {
      code: json.code || -1,
      data: null,
      message: json.msg || '请求失败',
    };
  } catch (error) {
    return {
      code: -1,
      data: null,
      message: error.message || '网络异常，请检查网络连接',
    };
  }
}

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