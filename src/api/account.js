/**
 * 账号密码管理 - API 接口层
 */

import { request } from './request';

// 分类枚举
export const CATEGORIES = {
  all: { key: 'all', label: '全部' },
  social: { key: 'social', label: '社交' },
  work: { key: 'work', label: '工作' },
  finance: { key: 'finance', label: '金融' },
  other: { key: 'other', label: '其他' },
};

/**
 * 获取账号列表
 * GET /api/accounts?pageNum=1&pageSize=10&title=xxx&category=xxx
 * @param {Object} params - { keyword?: string, category?: string, pageNum?: number, pageSize?: number }
 * @returns {Promise<{ code: number, data: Account[], total?: number }>}
 */
export async function getAccountList(params = {}) {
  const query = new URLSearchParams();
  if (params.pageNum) {
    query.append('pageNum', params.pageNum);
  }
  if (params.pageSize) {
    query.append('pageSize', params.pageSize);
  }
  if (params.keyword) {
    query.append('title', params.keyword);
  }
  if (params.category && params.category !== 'all') {
    query.append('category', params.category);
  }
  const qs = query.toString();
  const url = `/api/accounts${qs ? '?' + qs : ''}`;
  return request(url);
}

/**
 * 获取账号详情
 * GET /api/accounts/:id
 * @param {string} id
 * @returns {Promise<{ code: number, data: Account }>}
 */
export async function getAccountDetail(id) {
  return request(`/api/accounts/${id}`);
}

/**
 * 新增账号
 * POST /api/accounts
 * @param {Object} data - { title, username, password, url?, remark?, category? }
 * @returns {Promise<{ code: number, data: Account }>}
 */
export async function createAccount(data) {
  return request('/api/accounts', {
    method: 'POST',
    body: JSON.stringify(data),
  });
}

/**
 * 更新账号
 * PUT /api/accounts/:id
 * @param {string} id
 * @param {Object} data - 同 createAccount 参数
 * @returns {Promise<{ code: number, data: Account }>}
 */
export async function updateAccount(id, data) {
  return request(`/api/accounts/${id}`, {
    method: 'PUT',
    body: JSON.stringify(data),
  });
}

/**
 * 删除账号
 * DELETE /api/accounts/:id
 * @param {string} id
 * @returns {Promise<{ code: number, data: null }>}
 */
export async function deleteAccount(id) {
  return request(`/api/accounts/${id}`, {
    method: 'DELETE',
  });
}
