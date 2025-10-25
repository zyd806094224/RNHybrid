import React from 'react';
import {NavigationContainer} from '@react-navigation/native';
import {createNativeStackNavigator} from '@react-navigation/native-stack';
import HomeScreen from '../screens/HomeScreen';
import DetailsScreen from '../screens/DetailsScreen';
import ProfileScreen from '../screens/ProfileScreen';
import FlatListScreen from '../screens/FlatListScreen';
import AlgorithmScreen from "../screens/AlgorithmScreen";

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

const AppNavigator = () => {
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
                        headerLeft: () => null, // 主页不显示返回按钮
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
            </Stack.Navigator>
        </NavigationContainer>
    );
};

export default AppNavigator;
