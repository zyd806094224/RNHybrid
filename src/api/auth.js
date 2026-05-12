/**
 * 登录鉴权 - API 接口层
 *
 * Token 由原生端注入，RN 侧仅负责存储和携带
 * 401 时通知原生端跳转原生登录页
 */

import { NativeModules, Platform } from 'react-native';

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

// ==================== 原生 token 注入 ====================

/**
 * 接收原生侧注入的 token（通过 initialProps 传入）
 */
export function setAuthFromNative(token, username) {
  if (token) {
    store.token = token;
    store.username = username || '';
  }
}

// ==================== Token 过期处理 ====================

/**
 * token 过期时通知原生侧跳转原生登录页
 */
export function handleTokenExpired() {
  if (Platform.OS === 'android') {
    NativeModules.AuthModule.onTokenExpired();
    return true;
  }
  return false;
}
