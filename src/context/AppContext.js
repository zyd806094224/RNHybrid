import { createContext, useContext } from 'react';

/**
 * 全局应用 Context
 *
 * 管理用户鉴权信息（token、username）等全局共享状态
 */
export const AppContext = createContext({
  token: '',
  username: '',
  setAuth: () => {},
  clearAuth: () => {},
});

/**
 * 自定义 Hook：便捷获取全局状态
 */
export function useAppContext() {
  return useContext(AppContext);
}
