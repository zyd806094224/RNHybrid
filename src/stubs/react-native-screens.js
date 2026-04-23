import React from 'react';
import { View } from 'react-native';

// Disable native screens - use plain Views as stubs
export function enableScreens() {}
export function enableFreeze() {}
export function shouldUseActivityState() { return false; }

export const Screen = ({ children, ...props }) => <View {...props}>{children}</View>;
export const ScreenStack = ({ children, ...props }) => <View {...props}>{children}</View>;
export const ScreenStackHeaderConfig = (props) => null;
export const ScreenStackItem = ({ children, ...props }) => <View {...props}>{children}</View>;

export const InnerScreen = Screen;

export default {
  enableScreens,
  enableFreeze,
  shouldUseActivityState,
  Screen,
  ScreenStack,
  ScreenStackHeaderConfig,
};
