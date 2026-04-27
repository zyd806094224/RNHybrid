import React, { createContext, useContext, useState, useCallback, useEffect, useRef } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, BackHandler } from 'react-native';

// 简易 JS 导航栈，不依赖任何原生组件（SafeAreaView/Screen 等）
const StackContext = createContext(null);

function StackProvider({ children, initialRouteName }) {
  const [stack, setStack] = useState([{ name: initialRouteName, params: {} }]);
  const stackRef = useRef(stack);
  stackRef.current = stack;

  const navigate = useCallback((name, params) => {
    setStack(prev => [...prev, { name, params: params || {} }]);
  }, []);

  const goBack = useCallback(() => {
    setStack(prev => prev.length > 1 ? prev.slice(0, -1) : prev);
  }, []);

  useEffect(() => {
    const subscription = BackHandler.addEventListener('hardwareBackPress', () => {
      if (stackRef.current.length > 1) {
        setStack(prev => prev.slice(0, -1));
        return true;
      }
      // RN 导航栈已到根页面，通知原生侧返回上一页
      BackHandler.exitApp();
      return true;
    });
    return () => subscription.remove();
  }, []);

  const current = stack[stack.length - 1];

  return (
    <StackContext.Provider value={{ navigate, goBack, current, stack }}>
      {children}
    </StackContext.Provider>
  );
}

function Screen({ component: Component, name }) {
  const ctx = useContext(StackContext);
  if (!ctx || ctx.current.name !== name) return null;
  return <Component navigation={{ navigate: ctx.navigate, goBack: ctx.goBack }} route={{ params: ctx.current.params || {} }} />;
}

function Navigator({ initialRouteName, screenOptions, children }) {
  return (
    <StackProvider initialRouteName={initialRouteName}>
      <View style={styles.container}>
        {children}
      </View>
    </StackProvider>
  );
}

function createNativeStackNavigator() {
  return {
    Navigator,
    Screen,
    Group: ({ children }) => <>{children}</>,
  };
}

// NavigationContainer 的替代 - 不依赖 SafeAreaProvider
function NavigationContainerCompat({ children }) {
  return <View style={{ flex: 1 }}>{children}</View>;
}

export { createNativeStackNavigator, Navigator, Screen, NavigationContainerCompat };
export default { createNativeStackNavigator, Navigator, Screen, NavigationContainerCompat };

const styles = StyleSheet.create({
  container: { flex: 1 },
});
