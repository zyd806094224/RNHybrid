import React from 'react';
import {
    View,
    Text,
    StyleSheet,
} from 'react-native';
import CustomButton from '../components/Button';
import SafeContainer from '../components/SafeContainer';

const HomeScreen = ({navigation}) => {
    return (
        <SafeContainer style={styles.container}>
            <View style={styles.content}>
                <Text style={styles.title}>Home Screen</Text>
                <Text style={styles.description}>Welcome to the React Native App!</Text>
                <Text style={styles.hotUpdateTag}>Pushy 热更新测试 - 2026.04.24 17:30</Text>
                <View style={styles.buttonContainer}>
                    <CustomButton
                        title="Go to Details"
                        onPress={() => navigation.navigate('Details')}
                    />
                    <View style={styles.spacer}/>
                    <CustomButton
                        title="Go to Profile"
                        onPress={() => navigation.navigate('ProfileScreen', {
                            testId: 123
                        })}
                        style={{backgroundColor: '#FF9800'}}
                    />
                    <View style={styles.spacer}/>
                    <CustomButton
                        title="Go to FlatList"
                        onPress={() => navigation.navigate('FlatListScreen')}
                        style={{backgroundColor: '#9C27B0'}}
                    />
                    <View style={styles.spacer}/>
                    <CustomButton
                        title="Go to AlgorithmScreen"
                        onPress={() => navigation.navigate('AlgorithmScreen')}
                        style={{backgroundColor: '#9C27B0'}}
                    />
                    <View style={styles.spacer}/>
                    <CustomButton
                        title="Go to TypeScriptScreen"
                        onPress={() => navigation.navigate('TypeScriptScreen', {message: 'Hello from HomeScreen!'})}
                        style={{backgroundColor: '#007AFF'}}
                    />
                </View>
            </View>
        </SafeContainer>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#f5f5f5',
    },
    content: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        padding: 20,
    },
    title: {
        fontSize: 24,
        fontWeight: 'bold',
        marginBottom: 10,
        color: '#333',
    },
    description: {
        fontSize: 16,
        marginBottom: 30,
        color: '#666',
        textAlign: 'center',
    },
    hotUpdateTag: {
        fontSize: 14,
        marginBottom: 20,
        color: '#4CAF50',
        fontWeight: 'bold',
    },
    buttonContainer: {
        width: '80%',
    },
    spacer: {
        height: 10,
    },
});

export default HomeScreen;
