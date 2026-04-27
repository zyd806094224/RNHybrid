import React from 'react';
import { View } from 'react-native';

// react-native-screens stub for harmony - minimal implementation
export function Screen({ children }) {
  return <View style={{ flex: 1 }}>{children}</View>;
}

export function ScreenContainer({ children }) {
  return <View style={{ flex: 1 }}>{children}</View>;
}

export function ScreenStack({ children }) {
  return <View style={{ flex: 1 }}>{children}</View>;
}

export function ScreenStackItem({ children }) {
  return <View style={{ flex: 1 }}>{children}</View>;
}

export const ScreenStackHeaderConfig = () => null;
export const ScreenStackHeaderSubview = () => null;

export function useHeaderHeight() {
  return 0;
}

export const enableScreens = () => {};
export const screensEnabled = () => true;
