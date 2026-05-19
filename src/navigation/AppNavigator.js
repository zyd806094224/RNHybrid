import React, { useEffect } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { AuthProvider, useAppContext } from '../context/AuthProvider';
import ErrorBoundary from '../components/ErrorBoundary';
import { setAuthFromNative, syncAuthFromContext } from '../api/auth';
import HomeScreen from '../screens/HomeScreen';
import AccountListScreen from '../screens/AccountListScreen';
import AccountEditScreen from '../screens/AccountEditScreen';
import MemoListScreen from '../screens/MemoListScreen';
import MemoDetailScreen from '../screens/MemoDetailScreen';
import MemoEditScreen from '../screens/MemoEditScreen';

const Stack = createNativeStackNavigator();

/**
 * 内层导航器，消费 Context 并同步 token 到模块级 store
 */
const AppNavigatorInner = ({ nativeToken, nativeUsername }) => {
  const { setAuth } = useAppContext();

  useEffect(() => {
    if (nativeToken) {
      // 同时写入 Context 和模块级 store，确保两套机制都能拿到 token
      setAuth(nativeToken, nativeUsername);
      setAuthFromNative(nativeToken, nativeUsername);
      syncAuthFromContext(nativeToken, nativeUsername);
    }
  }, [nativeToken, nativeUsername, setAuth]);

  return (
    <NavigationContainer>
      <Stack.Navigator
        initialRouteName="Home"
        screenOptions={{
          headerShown: false,
          headerBackTitleVisible: false,
          gestureEnabled: true,
          gestureDirection: 'horizontal',
          animation: 'slide_from_right',
          animationDuration: 300,
          presentation: 'card',
        }}>
        <Stack.Screen
          name="Home"
          component={HomeScreen}
          options={{
            title: '主页',
            headerLeft: () => null,
          }}
        />
        <Stack.Screen
          name="AccountList"
          component={AccountListScreen}
          options={{
            title: '密码管理',
          }}
        />
        <Stack.Screen
          name="AccountEdit"
          component={AccountEditScreen}
          options={{
            title: '编辑账号',
          }}
        />
        <Stack.Screen
          name="MemoList"
          component={MemoListScreen}
          options={{
            title: '备忘录',
          }}
        />
        <Stack.Screen
          name="MemoDetail"
          component={MemoDetailScreen}
          options={{
            title: '备忘录详情',
          }}
        />
        <Stack.Screen
          name="MemoEdit"
          component={MemoEditScreen}
          options={{
            title: '编辑备忘录',
          }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
};

/**
 * 导出组件：AuthProvider 包裹导航器，提供全局状态
 */
const AppNavigator = (props) => (
  <ErrorBoundary>
    <AuthProvider>
      <AppNavigatorInner {...props} />
    </AuthProvider>
  </ErrorBoundary>
);

export default AppNavigator;