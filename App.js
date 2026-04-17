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
import {Pushy, PushyProvider} from 'react-native-update';
import AppNavigator from './src/navigation/AppNavigator';

const pushy = new Pushy({
    appKey: 'iE2tRmGMuFRkLnbsmpApZLHV',
});

const App = (props) => {
    const {param1} = props
    console.log('props', param1)
    return (
        <PushyProvider client={pushy}>
            <SafeAreaView style={styles.container}>
                <AppNavigator/>
            </SafeAreaView>
        </PushyProvider>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
});

export default App;
