/**
 * 登录鉴权 - API 接口层
 *
 * Token 由原生端注入，RN 侧仅负责存储和携带
 * 401 时通知原生端跳转原生登录页
 *
 * 支持两种使用方式：
 * 1. 函数式调用：getToken() / setAuthFromNative()（供 request.js 等非组件使用）
 * 2. Context 调用：useAppContext()（供 React 组件使用）
 */

import { NativeModules, Platform, TurboModuleRegistry } from 'react-native';

const store = {};

// ==================== Token 管理（函数式，供非组件使用）====================

export function getToken() {
  return store.token || '';
}

export function getUsername() {
  return store.username || '';
}

/**
 * 接收原生侧注入的 token（通过 initialProps 传入）
 */
export function setAuthFromNative(token, username) {
  if (token) {
    store.token = token;
    store.username = username || '';
  }
}

export function clearAuth() {
  delete store.token;
  delete store.username;
}

/**
 * 由 AuthProvider 调用，同步 Context 状态到模块级 store
 * 确保 request.js 中的 getToken() 能拿到最新值
 */
export function syncAuthFromContext(token, username) {
  store.token = token;
  store.username = username || '';
}

// ==================== Token 过期处理 ====================

function getNativeAuthModule() {
  if (NativeModules.AuthModule) {
    return NativeModules.AuthModule;
  }

  try {
    // Android exposes AuthModule through NativeModules. Harmony RNOH custom
    // modules are registered as TurboModules, so they must be resolved through
    // TurboModuleRegistry instead.
    return TurboModuleRegistry.get('AuthModule');
  } catch {
    return null;
  }
}

/**
 * token 过期时通知原生侧跳转原生登录页
 */
export function handleTokenExpired() {
  if (Platform.OS !== 'android' && Platform.OS !== 'harmony' && Platform.OS !== 'ios') {
    return false;
  }

  const authModule = getNativeAuthModule();
  const hasHandler = typeof authModule?.onTokenExpired === 'function';
  try {
    if (!hasHandler) {
      return false;
    }
    authModule.onTokenExpired();
    return true;
  } catch {
    return false;
  }
}
