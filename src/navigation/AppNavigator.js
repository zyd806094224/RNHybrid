/*
 * @Author: zhaoyudong
 * @Date: 2026-05-18 16:48:17
 * @LastEditors: zhaoyudong 
 * @LastEditTime: 2026-05-18 16:48:39
 * @Description: ----
 *
 * 页面功能：
 *   ----
 */
import React, {useEffect} from 'react';
import {NavigationContainer} from '@react-navigation/native';
import {createNativeStackNavigator} from '@react-navigation/native-stack';
import {setAuthFromNative} from '../api/auth';
import HomeScreen from '../screens/HomeScreen';
import AccountListScreen from '../screens/AccountListScreen';
import AccountEditScreen from '../screens/AccountEditScreen';
import MemoListScreen from '../screens/MemoListScreen';
import MemoDetailScreen from '../screens/MemoDetailScreen';
import MemoEditScreen from '../screens/MemoEditScreen';

// 定义路由参数类型，解决 TypeScript 类型推断问题
const Stack = createNativeStackNavigator();

const AppNavigator = ({nativeToken, nativeUsername}) => {
    useEffect(() => {
        if (nativeToken) {
            setAuthFromNative(nativeToken, nativeUsername);
        }
    }, []);

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

export default AppNavigator;