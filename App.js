/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */

import React from 'react';
import {
    StyleSheet,
    Platform,
    View
} from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import AppNavigator from './src/navigation/AppNavigator';

const App = (props) => {
    const {param1} = props
    console.log('props', param1)

    // Pushy hot update for all platforms
    const {Pushy, UpdateProvider} = require('react-native-update');
    const appKeys = {
        android: 'iE2tRmGMuFRkLnbsmpApZLHV',
        ios: 'AJougFK8VqPUQV5VGX23Xs7B',
        harmony: 'vqqcPSQlhd3ln-M7QRu4J3m1',
    };
    const pushy = new Pushy({
        appKey: appKeys[Platform.OS],
        updateStrategy: __DEV__ ? 'alwaysAlert' : 'silentAndLater',
    });

    return (
        <SafeAreaProvider>
            <UpdateProvider client={pushy}>
                <View style={styles.container}>
                    <AppNavigator/>
                </View>
            </UpdateProvider>
        </SafeAreaProvider>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
});

export default App;
