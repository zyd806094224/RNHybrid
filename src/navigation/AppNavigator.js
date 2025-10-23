import React from 'react';
import {NavigationContainer} from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import HomeScreen from '../screens/HomeScreen';
import DetailsScreen from '../screens/DetailsScreen';
import ProfileScreen from '../screens/ProfileScreen';
import FlatListScreen from '../screens/FlatListScreen';
const Stack = createNativeStackNavigator();

const AppNavigator = () => {
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="Home">
            <Stack.Screen name="Home" component={HomeScreen} options={{ title: '主页' }} />
            <Stack.Screen name="Details" component={DetailsScreen} options={{ title: 'Details' }} />
            <Stack.Screen name="ProfileScreen" component={ProfileScreen} options={{ title: 'ProfileScreen' }} />
            <Stack.Screen name="FlatListScreen" component={FlatListScreen} options={{ title: '长列表' }} />
        </Stack.Navigator>
    </NavigationContainer>
  );
};

export default AppNavigator;