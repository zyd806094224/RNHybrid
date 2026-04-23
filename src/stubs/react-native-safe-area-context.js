import React, { createContext, useContext } from 'react';
import { View } from 'react-native';

const defaultInsets = { top: 0, bottom: 0, left: 0, right: 0 };
const defaultFrame = { x: 0, y: 0, width: 0, height: 0 };

// 导出 react-navigation 需要的 Context 对象
export const SafeAreaInsetsContext = createContext(defaultInsets);
export const SafeAreaFrameContext = createContext(defaultFrame);

export const SafeAreaProvider = ({ children, style }) => {
  return (
    <SafeAreaInsetsContext.Provider value={defaultInsets}>
      <SafeAreaFrameContext.Provider value={defaultFrame}>
        <View style={[{ flex: 1 }, style]}>{children}</View>
      </SafeAreaFrameContext.Provider>
    </SafeAreaInsetsContext.Provider>
  );
};

export const SafeAreaView = ({ children, style, ...props }) => {
  return <View style={style} {...props}>{children}</View>;
};

export const useSafeAreaInsets = () => useContext(SafeAreaInsetsContext);
export const useSafeAreaFrame = () => useContext(SafeAreaFrameContext);

export const initialWindowMetrics = {
  frame: defaultFrame,
  insets: defaultInsets,
};

export default {
  SafeAreaProvider,
  SafeAreaView,
  SafeAreaInsetsContext,
  SafeAreaFrameContext,
  useSafeAreaInsets,
  useSafeAreaFrame,
  initialWindowMetrics,
};
