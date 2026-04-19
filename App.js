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
    StyleSheet
} from 'react-native';
import {Pushy, UpdateProvider} from 'react-native-update';
import AppNavigator from './src/navigation/AppNavigator';

const pushy = new Pushy({
    appKey: 'iE2tRmGMuFRkLnbsmpApZLHV',
    updateStrategy: __DEV__ ? 'alwaysAlert' : 'silentAndLater',
});

const App = (props) => {
    const {param1} = props
    console.log('props', param1)
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
