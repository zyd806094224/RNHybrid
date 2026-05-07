/**
 * 登录鉴权 - API 接口层
 *
 * 纯 JS 内存存储，类似浏览器 localStorage，零原生依赖，三端通用
 */

const BASE_URL = 'https://106.15.7.132:8443';

const store = {};

// ==================== Token 管理 ====================

export function saveAuth(token, username) {
  store.token = token;
  store.username = username;
}

export function getToken() {
  return store.token || '';
}

export function getUsername() {
  return store.username || '';
}

export function clearAuth() {
  delete store.token;
  delete store.username;
}

export function isLoggedIn() {
  return !!store.token;
}

// ==================== 登录接口 ====================

export async function login(username, password) {
  try {
    const response = await fetch(`${BASE_URL}/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username, password }),
    });

    const json = await response.json();

    if (json.code === 200) {
      saveAuth(json.token, username);
      return { code: 0, data: { token: json.token } };
    }

    return {
      code: json.code || -1,
      data: null,
      message: json.msg || '登录失败',
    };
  } catch (error) {
    return {
      code: -1,
      data: null,
      message: error.message || '网络异常，请检查网络连接',
    };
  }
}

export function logout() {
  clearAuth();
}
