import React from 'react';
import { View } from 'react-native';

// react-native-safe-area-context stub for harmony
export function SafeAreaProvider({ children }) {
  return <View style={{ flex: 1 }}>{children}</View>;
}

export function SafeAreaView({ children, style }) {
  return <View style={style}>{children}</View>;
}

export function useSafeAreaInsets() {
  return { top: 0, bottom: 0, left: 0, right: 0 };
}

export function initialWindowMetrics() {
  return { insets: { top: 0, bottom: 0, left: 0, right: 0 } };
}
