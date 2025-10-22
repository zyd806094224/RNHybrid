import React from 'react';
import {NavigationContainer} from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import HomeScreen from '../screens/HomeScreen';
import DetailsScreen from '../screens/DetailsScreen';
import ProfileScreen from '../screens/ProfileScreen';
const Stack = createNativeStackNavigator();

const AppNavigator = () => {
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="Home">
            <Stack.Screen name="Home" component={HomeScreen} options={{ title: '主页' }} />
            <Stack.Screen name="Details" component={DetailsScreen} options={{ title: 'Details' }} />
            <Stack.Screen name="ProfileScreen" component={ProfileScreen} options={{ title: 'ProfileScreen' }} />
        </Stack.Navigator>
    </NavigationContainer>
  );
};

export default AppNavigator;
