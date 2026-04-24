/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */

import React from 'react';
import {
    SafeAreaView,
    StyleSheet,
    Platform
} from 'react-native';
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
        <UpdateProvider client={pushy}>
            <SafeAreaView style={styles.container}>
                <AppNavigator/>
            </SafeAreaView>
        </UpdateProvider>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
});

export default App;
