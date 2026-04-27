import React from 'react';
import { View, SafeAreaView, Platform } from 'react-native';

// 鸿蒙的 SafeAreaView 使用 padding 模拟安全区域，存在时序问题导致 paddingBottom 计算异常，
// 内容被挤到顶部。鸿蒙的安全区域已由原生侧处理，直接使用 View。
const Container = Platform.OS === 'harmony' ? View : SafeAreaView;

const SafeContainer = (props) => {
    const { children, ...rest } = props;
    return <Container {...rest}>{children}</Container>;
};

export default SafeContainer;
