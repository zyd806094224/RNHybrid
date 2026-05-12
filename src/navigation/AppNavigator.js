import React from 'react';
import {NavigationContainer} from '@react-navigation/native';
import {createNativeStackNavigator} from '@react-navigation/native-stack';
import {setAuthFromNative} from '../api/auth';
import HomeScreen from '../screens/HomeScreen';
import AccountListScreen from '../screens/AccountListScreen';
import AccountEditScreen from '../screens/AccountEditScreen';
import {useEffect} from 'react';

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
                    options={{
                        title: '密码管理',
                        animation: 'slide_from_right',
                    }}>
                    {props => <AccountListScreen {...props} />}
                </Stack.Screen>
                <Stack.Screen
                    name="AccountEdit"
                    options={{
                        title: '编辑账号',
                        animation: 'slide_from_right',
                    }}>
                    {props => <AccountEditScreen {...props} />}
                </Stack.Screen>
            </Stack.Navigator>
        </NavigationContainer>
    );
};

export default AppNavigator;
