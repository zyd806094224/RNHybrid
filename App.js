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

    if (Platform.OS === 'harmony') {
        return (
            <SafeAreaView style={styles.container}>
                <AppNavigator/>
            </SafeAreaView>
        );
    }

    // Android/iOS: use pushy hot update
    const {Pushy, UpdateProvider} = require('react-native-update');
    const pushy = new Pushy({
        appKey: 'iE2tRmGMuFRkLnbsmpApZLHV',
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
