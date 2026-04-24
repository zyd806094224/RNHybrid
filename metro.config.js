// metro.config.js
const { mergeConfig, getDefaultConfig } = require('@react-native/metro-config');
const {
    createHarmonyMetroConfig,
} = require('@react-native-oh/react-native-harmony/metro.config');
const path = require('path');

const harmonyConfig = createHarmonyMetroConfig({
    reactNativeHarmonyPackageName: '@react-native-oh/react-native-harmony',
});

// Harmony 平台 stub 映射 - 将没有鸿蒙原生实现的库重定向到 JS stub
const harmonyStubs = {
    'react-native-screens': path.resolve(__dirname, 'src/stubs/react-native-screens.js'),
    'react-native-safe-area-context': path.resolve(__dirname, 'src/stubs/react-native-safe-area-context.js'),
    '@react-navigation/native': path.resolve(__dirname, 'src/stubs/@react-navigation-native.js'),
    '@react-navigation/native-stack': path.resolve(__dirname, 'src/stubs/@react-navigation-native-stack.js'),
};

const originalResolveRequest = harmonyConfig.resolver.resolveRequest;
harmonyConfig.resolver.resolveRequest = (ctx, moduleName, platform) => {
    if (platform === 'harmony' && harmonyStubs[moduleName]) {
        return {
            type: 'sourceFile',
            filePath: harmonyStubs[moduleName],
        };
    }
    return originalResolveRequest(ctx, moduleName, platform);
};

/**
 * Metro配置
 * https://metrobundler.dev/docs/configuration
 *
 * @type {import("metro-config").ConfigT}
 */
const config = {
    transformer: {
        getTransformOptions: async () => ({
            transform: {
                experimentalImportSupport: false,
                inlineRequires: true
            },
        }),
    },
};
module.exports = mergeConfig(
    getDefaultConfig(__dirname),
    harmonyConfig,
    config
);
