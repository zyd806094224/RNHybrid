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
import AppNavigator from './src/navigation/AppNavigator';

const App = (props) => {
    const {param1} = props
    console.log('props', param1)
    return (
        <SafeAreaView style={styles.container}>
            <AppNavigator/>
        </SafeAreaView>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
});

export default App;
