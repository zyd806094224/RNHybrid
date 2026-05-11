/**
 * 登录鉴权 - API 接口层
 *
 * 纯 JS 内存存储，类似浏览器 localStorage，零原生依赖，三端通用
 */

import { NativeModules, Platform } from 'react-native';

const BASE_URL = 'https://106.15.7.132:8443';

const store = {};

// 标记 token 是否由原生侧注入（决定 401 时走原生登录还是 JS 端登录）
let nativeAuth = false;

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

// ==================== 原生 token 注入 ====================

/**
 * 接收原生侧注入的 token（通过 initialProps 传入）
 * 鸿蒙/iOS/Android 统一通过此方法注入，RN 侧无需感知平台差异
 */
export function setAuthFromNative(token, username) {
  if (token) {
    store.token = token;
    store.username = username || '';
    nativeAuth = true;
  }
}

// ==================== Token 过期处理 ====================

/**
 * token 过期处理
 * - 原生注入的 token：通知原生侧跳转原生登录页
 * - JS 端自行登录：返回 true 由 JS 端自行处理（显示 LoginScreen）
 */
export function handleTokenExpired() {
  if (nativeAuth && Platform.OS === 'android') {
    NativeModules.AuthModule.onTokenExpired();
    return true; // 已由原生处理
  }
  return false; // JS 端自行处理
}

/**
 * 判断是否为原生注入的登录态
 */
export function isNativeAuth() {
  return nativeAuth;
}
