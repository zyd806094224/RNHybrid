/**
 * 账号密码管理 - API 接口层
 *
 * 对接后端 REST API，后端返回格式：{ code: 200, msg: "...", data: T }
 * 前端统一转换为：{ code: 0, data: T, message: string }
 *
 * 自动从 AsyncStorage 读取 token 添加到请求头
 * 接口返回 401 时自动清除登录状态
 */

import { getToken, handleTokenExpired } from './auth';

// ==================== 配置 ====================

// 后端服务地址
const BASE_URL = 'https://106.15.7.132:8443';

// ==================== 数据模型 ====================

// Account: { id, title, category, username, password, url, remark, createdAt, updatedAt }

// 分类枚举
export const CATEGORIES = {
  all: { key: 'all', label: '全部' },
  social: { key: 'social', label: '社交' },
  work: { key: 'work', label: '工作' },
  finance: { key: 'finance', label: '金融' },
  other: { key: 'other', label: '其他' },
};

// ==================== HTTP 工具函数 ====================

/**
 * 通用请求方法
 * - 自动携带 token
 * - 后端 { code: 200, msg, data } 转为前端 { code: 0, data, message }
 * - 检测 401/token 过期自动清除登录态
 */
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

    // HTTP 401 表示 token 过期或无效，通知原生端跳转登录页
    if (response.status === 401) {
      handleTokenExpired();
      return { code: 401, data: null, message: '登录已过期，请重新登录' };
    }

    const json = await response.json();

    // 后端业务层也返回了未认证错误码
    if (json.code === 401) {
      handleTokenExpired();
      return { code: 401, data: null, message: '登录已过期，请重新登录' };
    }

    // 后端成功 code 为 200，前端统一为 0
    if (json.code === 200) {
      return { code: 0, data: json.data ?? json.rows ?? null };
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

// ==================== 接口实现 ====================

/**
 * 获取账号列表
 * GET /api/accounts?keyword=xxx&category=xxx
 * @param {Object} params - { keyword?: string, category?: string }
 * @returns {Promise<{ code: number, data: Account[] }>}
 */
export async function getAccountList(params = {}) {
  const query = new URLSearchParams();
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
