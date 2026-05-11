import React, {useState, useEffect} from 'react';
import {NavigationContainer} from '@react-navigation/native';
import {createNativeStackNavigator} from '@react-navigation/native-stack';
import {ActivityIndicator, View} from 'react-native';
import {isLoggedIn, setAuthFromNative} from '../api/auth';
import LoginScreen from '../screens/LoginScreen';
import HomeScreen from '../screens/HomeScreen';
import DetailsScreen from '../screens/DetailsScreen';
import ProfileScreen from '../screens/ProfileScreen';
import FlatListScreen from '../screens/FlatListScreen';
import AlgorithmScreen from "../screens/AlgorithmScreen";
import TypeScriptScreen from '../screens/TypeScriptScreen';
import AccountListScreen from '../screens/AccountListScreen';
import AccountEditScreen from '../screens/AccountEditScreen';

const Stack = createNativeStackNavigator();

// 自定义屏幕选项，提供平滑的过渡效果
const screenOptions = {
    headerStyle: {
        backgroundColor: '#ffffff',
        elevation: 0, // Android 阴影
        shadowOpacity: 0, // iOS 阴影
        borderBottomWidth: 1,
        borderBottomColor: '#e0e0e0',
    },
    headerTintColor: '#333333',
    headerTitleStyle: {
        fontWeight: '600',
        fontSize: 17,
    },
    headerBackTitleVisible: false, // iOS 不显示返回文字
    gestureEnabled: true, // 启用手势返回
    gestureDirection: 'horizontal', // 横向手势
    animation: 'slide_from_right', // 平滑的滑入动画
    animationDuration: 300, // 动画持续时间
    presentation: 'card', // 卡片式过渡
    headerShown: false, //隐藏默认标题
};

const AppNavigator = ({nativeToken, nativeUsername}) => {
    const [loggedIn, setLoggedIn] = useState(null); // null = 加载中

    // 启动时检查登录态：优先使用原生注入的 token，降级到 JS 端存储
    useEffect(() => {
        if (nativeToken) {
            setAuthFromNative(nativeToken, nativeUsername);
            setLoggedIn(true);
        } else {
            setLoggedIn(isLoggedIn());
        }
    }, []);

    // 显示加载中
    if (loggedIn === null) {
        return (
            <View style={{flex: 1, justifyContent: 'center', alignItems: 'center'}}>
                <ActivityIndicator size="large" color="#2196F3" />
            </View>
        );
    }

    const handleLoginSuccess = () => {
        setLoggedIn(true);
    };

    return (
        <NavigationContainer>
            <Stack.Navigator
                key={loggedIn ? 'home' : 'login'}
                initialRouteName={loggedIn ? 'Home' : 'Login'}
                screenOptions={screenOptions}>
                <Stack.Screen
                    name="Login"
                    options={{headerShown: false}}>
                    {props => <LoginScreen {...props} onLoginSuccess={handleLoginSuccess} />}
                </Stack.Screen>
                <Stack.Screen
                    name="Home"
                    component={HomeScreen}
                    options={{
                        title: '主页',
                        headerLeft: () => null,
                    }}
                />
                <Stack.Screen
                    name="Details"
                    component={DetailsScreen}
                    options={{
                        title: '详情页',
                        animation: 'slide_from_right',
                    }}
                />
                <Stack.Screen
                    name="ProfileScreen"
                    component={ProfileScreen}
                    options={{
                        title: '个人资料',
                        animation: 'slide_from_right',
                    }}
                />
                <Stack.Screen
                    name="FlatListScreen"
                    component={FlatListScreen}
                    options={{
                        title: '长列表',
                        animation: 'slide_from_right',
                    }}
                />
                <Stack.Screen
                    name="AlgorithmScreen"
                    component={AlgorithmScreen}
                    options={{
                        title: 'process列表',
                        animation: 'slide_from_right',
                    }}
                />
                <Stack.Screen
                    name="TypeScriptScreen"
                    component={TypeScriptScreen}
                    options={{
                        title: 'TypeScript Screen',
                        animation: 'slide_from_right',
                    }}
                />
                <Stack.Screen
                    name="AccountList"
                    options={{
                        title: '密码管理',
                        animation: 'slide_from_right',
                    }}>
                    {props => <AccountListScreen {...props} onAuthExpired={() => setLoggedIn(false)} />}
                </Stack.Screen>
                <Stack.Screen
                    name="AccountEdit"
                    options={{
                        title: '编辑账号',
                        animation: 'slide_from_right',
                    }}>
                    {props => <AccountEditScreen {...props} onAuthExpired={() => setLoggedIn(false)} />}
                </Stack.Screen>
            </Stack.Navigator>
        </NavigationContainer>
    );
};

export default AppNavigator;
