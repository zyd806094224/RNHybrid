/**
 * 统一 HTTP 客户端
 *
 * - 自动携带 token
 * - 后端 { code: 200, msg, data } 转为前端 { code: 0, data, message }
 * - 检测 401/token 过期自动清除登录态
 */

import { getToken, handleTokenExpired } from './auth';
import { BASE_URL } from '../config';

export async function request(url, options = {}) {
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
      return {
        code: 0,
        data: json.data ?? json.rows ?? null,
        total: json.total ?? 0,
      };
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
