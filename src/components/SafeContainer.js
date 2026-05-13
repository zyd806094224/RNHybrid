import React from 'react';
import { View, Platform, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

/**
 * 安全区域容器
 * - iOS/Android: useSafeAreaInsets 精确获取刘海/状态栏高度，手动设置 paddingTop
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

    return (
        <View style={[styles.safeContainer, { paddingTop: insets.top }, style]} {...rest}>
            {children}
        </View>
    );
};

const styles = StyleSheet.create({
    safeContainer: {
        flex: 1,
    },
});

export default SafeContainer;
