import React, {useState, useEffect} from 'react';
import {NavigationContainer} from '@react-navigation/native';
import {createNativeStackNavigator} from '@react-navigation/native-stack';
import {ActivityIndicator, View} from 'react-native';
import {isLoggedIn, setAuthFromNative} from '../api/auth';
import LoginScreen from '../screens/LoginScreen';
import HomeScreen from '../screens/HomeScreen';
import AccountListScreen from '../screens/AccountListScreen';
import AccountEditScreen from '../screens/AccountEditScreen';

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
    const [loggedIn, setLoggedIn] = useState(null);

    useEffect(() => {
        if (nativeToken) {
            setAuthFromNative(nativeToken, nativeUsername);
            setLoggedIn(true);
        } else {
            setLoggedIn(isLoggedIn());
        }
    }, []);

    if (loggedIn === null) {
        return (
            <View style={{flex: 1, justifyContent: 'center', alignItems: 'center'}}>
                <ActivityIndicator size="large" color="#2196F3"/>
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
                    {props => <LoginScreen {...props} onLoginSuccess={handleLoginSuccess}/>}
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
                    name="AccountList"
                    options={{
                        title: '密码管理',
                        animation: 'slide_from_right',
                    }}>
                    {props => <AccountListScreen {...props} onAuthExpired={() => setLoggedIn(false)}/>}
                </Stack.Screen>
                <Stack.Screen
                    name="AccountEdit"
                    options={{
                        title: '编辑账号',
                        animation: 'slide_from_right',
                    }}>
                    {props => <AccountEditScreen {...props} onAuthExpired={() => setLoggedIn(false)}/>}
                </Stack.Screen>
            </Stack.Navigator>
        </NavigationContainer>
    );
};

export default AppNavigator;
