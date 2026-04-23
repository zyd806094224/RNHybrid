import React from 'react';
import { View } from 'react-native';

// NavigationContainer stub - 不依赖 SafeAreaProvider
export function NavigationContainer({ children }) {
  return <View style={{ flex: 1 }}>{children}</View>;
}

export function useNavigation() {
  return { navigate: () => {}, goBack: () => {}, reset: () => {} };
}

export function useRoute() {
  return { params: {} };
}

export function useFocusEffect() {}
export function useIsFocused() { return true; }
export function createNavigationContainerRef() { return { current: null }; }

export const DarkTheme = { dark: true, colors: {} };
export const DefaultTheme = { dark: false, colors: {} };
