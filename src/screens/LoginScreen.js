import React, {useState} from 'react';
import {
  View,
  Text,
  TextInput,
  StyleSheet,
  ActivityIndicator,
  KeyboardAvoidingView,
  Platform,
  Alert,
} from 'react-native';
import CustomButton from '../components/Button';
import SafeContainer from '../components/SafeContainer';
import {login} from '../api/auth';

const LoginScreen = ({onLoginSuccess}) => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLogin = async () => {
    if (!username.trim()) {
      Alert.alert('提示', '请输入用户名');
      return;
    }
    if (!password.trim()) {
      Alert.alert('提示', '请输入密码');
      return;
    }

    setLoading(true);
    try {
      const result = await login(username.trim(), password);
      if (result.code === 0) {
        onLoginSuccess && onLoginSuccess();
      } else {
        Alert.alert('登录失败', result.message || '用户名或密码错误');
      }
    } catch (error) {
      Alert.alert('登录失败', error.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <SafeContainer style={styles.container}>
      <KeyboardAvoidingView
        style={styles.inner}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        <View style={styles.header}>
          <Text style={styles.appName}>RNHybrid</Text>
          <Text style={styles.subtitle}>账号登录</Text>
        </View>

        <View style={styles.form}>
          <TextInput
            style={styles.input}
            placeholder="请输入用户名"
            placeholderTextColor="#999"
            value={username}
            onChangeText={setUsername}
            autoCapitalize="none"
            editable={!loading}
            returnKeyType="next"
          />
          <TextInput
            style={styles.input}
            placeholder="请输入密码"
            placeholderTextColor="#999"
            value={password}
            onChangeText={setPassword}
            secureTextEntry
            editable={!loading}
            returnKeyType="done"
            onSubmitEditing={handleLogin}
          />

          <View style={styles.buttonWrapper}>
            {loading ? (
              <ActivityIndicator size="large" color="#2196F3" />
            ) : (
              <CustomButton
                title="登 录"
                onPress={handleLogin}
                style={styles.loginButton}
              />
            )}
          </View>
        </View>
      </KeyboardAvoidingView>
    </SafeContainer>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  inner: {
    flex: 1,
    justifyContent: 'center',
    paddingHorizontal: 30,
  },
  header: {
    alignItems: 'center',
    marginBottom: 40,
  },
  appName: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
  },
  form: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 20,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: {width: 0, height: 2},
        shadowOpacity: 0.1,
        shadowRadius: 8,
      },
      android: {
        elevation: 4,
      },
    }),
  },
  input: {
    height: 48,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    paddingHorizontal: 14,
    fontSize: 16,
    color: '#333',
    marginBottom: 16,
    backgroundColor: '#fafafa',
  },
  buttonWrapper: {
    marginTop: 8,
  },
  loginButton: {
    backgroundColor: '#2196F3',
  },
});

export default LoginScreen;
