import React, { useEffect } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';

// 为导航器定义参数类型
type RootStackParamList = {
  TypeScriptScreen: { message: string };
  // 如果您的导航栈还有其他带参数的页面，也在这里定义
};

// 定义此屏幕组件的 props 类型
type Props = NativeStackScreenProps<RootStackParamList, 'TypeScriptScreen'>;

const TypeScriptScreen: React.FC<Props> = ({ route }) => {
  // 从路由参数中获取 message
  const { message } = route.params;

  useEffect(() => {
    // 打印日志
    console.log('路由接收参数:', message);
  }, [message]);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>This is a TypeScript Screen</Text>
      <Text style={styles.text}>TypeScript support is now enabled.</Text>
      <Text style={styles.paramText}>Received Message: {message}</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  title: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  text: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
  paramText: {
    marginTop: 15,
    fontSize: 16,
    color: '#27ae60',
    fontWeight: 'bold',
  },
});

export default TypeScriptScreen;
