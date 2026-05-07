import React, {useState} from 'react';
import {
    View,
    Text,
    StyleSheet,
    ScrollView,
    Alert,
} from 'react-native';
import CustomButton from '../components/Button';
import SafeContainer from '../components/SafeContainer';

const HomeScreen = ({navigation}) => {
    const [loading, setLoading] = useState(false);
    const [userList, setUserList] = useState(null);

    const fetchUserList = async () => {
        setLoading(true);
        try {
            const response = await fetch('https://106.15.7.132:8443/test/user/list', {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json',
                },
            });
            const json = await response.json();
            setUserList(json);
        } catch (error) {
            Alert.alert('请求失败', error.message);
        } finally {
            setLoading(false);
        }
    };

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
                    <View style={styles.spacer}/>
                    <CustomButton
                        title="密码管理"
                        onPress={() => navigation.navigate('AccountList')}
                        style={{backgroundColor: '#4CAF50'}}
                    />
                    <View style={styles.spacer}/>
                    <CustomButton
                        title={loading ? '请求中...' : '获取用户列表'}
                        onPress={fetchUserList}
                        style={{backgroundColor: '#E91E63'}}
                    />
                </View>
                {userList && (
                    <ScrollView style={styles.resultContainer}>
                        <Text style={styles.resultTitle}>接口返回：</Text>
                        <Text style={styles.resultText}>{JSON.stringify(userList, null, 2)}</Text>
                    </ScrollView>
                )}
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
    resultContainer: {
        marginTop: 20,
        width: '100%',
        maxHeight: 200,
        backgroundColor: '#fff',
        borderRadius: 8,
        padding: 12,
        borderWidth: 1,
        borderColor: '#ddd',
    },
    resultTitle: {
        fontSize: 14,
        fontWeight: 'bold',
        color: '#333',
        marginBottom: 6,
    },
    resultText: {
        fontSize: 12,
        color: '#666',
    },
});

export default HomeScreen;
