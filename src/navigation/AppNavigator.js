import React, {useEffect} from 'react';
import {NavigationContainer} from '@react-navigation/native';
import {createNativeStackNavigator} from '@react-navigation/native-stack';
import {setAuthFromNative} from '../api/auth';
import HomeScreen from '../screens/HomeScreen';
import AccountListScreen from '../screens/AccountListScreen';
import AccountEditScreen from '../screens/AccountEditScreen';

// 定义路由参数类型，解决 TypeScript 类型推断问题
const Stack = createNativeStackNavigator();

const screenOptions = {
    headerStyle: {
        backgroundColor: '#ffffff',
        elevation: 0,
        shadowOpacity: 0,
        borderBottomWidth: 1,
        borderBottomColor: '#e0e0e0',
    },
    headerTintColor: '#333333',
    headerTitleStyle: {
        fontWeight: '600',
        fontSize: 17,
    },
    headerBackTitleVisible: false,
    gestureEnabled: true,
    gestureDirection: 'horizontal',
    animation: 'slide_from_right',
    animationDuration: 300,
    presentation: 'card',
    headerShown: false,
};

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
                screenOptions={screenOptions}>
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
            </Stack.Navigator>
        </NavigationContainer>
    );
};

export default AppNavigator;
