import React from 'react';
import { View, SafeAreaView, Platform, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

/**
 * 安全区域容器
 * - iOS/Android: useSafeAreaInsets 精确获取刘海/状态栏高度
 * - 鸿蒙: 安全区域由原生侧处理，直接使用 View
 */
const SafeContainer = (props) => {
    const { children, style, ...rest } = props;

    if (Platform.OS === 'harmony') {
        return <View style={style} {...rest}>{children}</View>;
    }

    return <SafeContainerInner style={style} {...rest}>{children}</SafeContainerInner>;
};

const SafeContainerInner = (props) => {
    const { children, style, ...rest } = props;
    const insets = useSafeAreaInsets();

    if (Platform.OS === 'ios') {
        return <SafeAreaView style={style} {...rest}>{children}</SafeAreaView>;
    }

    return (
        <View style={[styles.androidContainer, { paddingTop: insets.top }, style]} {...rest}>
            {children}
        </View>
    );
};

const styles = StyleSheet.create({
    androidContainer: {
        flex: 1,
    },
});

export default SafeContainer;
