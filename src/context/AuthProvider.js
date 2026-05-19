import React, { useState, useCallback } from 'react';
import { AppContext, useAppContext } from './AppContext';

export { useAppContext };

/**
 * 鉴权 Provider
 *
 * 管理全局 token / username 状态，替代 auth.js 中的模块级 store 对象
 * 同时保留与 auth.js 的兼容（通过 setAuthFromNative 注入）
 */
export function AuthProvider({ children }) {
  const [token, setToken] = useState('');
  const [username, setUsername] = useState('');

  const setAuth = useCallback((newToken, newUsername) => {
    if (newToken) {
      setToken(newToken);
      setUsername(newUsername || '');
    }
  }, []);

  const clearAuth = useCallback(() => {
    setToken('');
    setUsername('');
  }, []);

  return (
    <AppContext.Provider value={{ token, username, setAuth, clearAuth }}>
      {children}
    </AppContext.Provider>
  );
}
