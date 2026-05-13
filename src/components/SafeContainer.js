import React from 'react';
import { View, SafeAreaView, Platform, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

/**
 * @typedef {import('react').PropsWithChildren<import('react-native').ViewProps>} SafeContainerProps
 */

/**
 * 安全区域容器
 * - iOS/Android: useSafeAreaInsets 精确获取刘海/状态栏高度
 * - 鸿蒙: 安全区域由原生侧处理，直接使用 View
 */
/** @param {SafeContainerProps} props */
const SafeContainer = (props) => {
    const { children, style, ...rest } = props;

    if (Platform.OS === 'harmony') {
        return React.createElement(View, { ...rest, style }, children);
    }

    return React.createElement(SafeContainerInner, { ...rest, style }, children);
};

/** @param {SafeContainerProps} props */
const SafeContainerInner = (props) => {
    const { children, style, ...rest } = props;
    const insets = useSafeAreaInsets();

    if (Platform.OS === 'ios') {
        return React.createElement(SafeAreaView, { ...rest, style }, children);
    }

    return React.createElement(
        View,
        { ...rest, style: [styles.androidContainer, { paddingTop: insets.top }, style] },
        children
    );
};

const styles = StyleSheet.create({
    androidContainer: {
        flex: 1,
    },
});

export default SafeContainer;
