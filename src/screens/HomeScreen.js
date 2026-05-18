/*
 * @Author: zhaoyudong
 * @Date: 2026-05-18 16:49:00
 * @LastEditors: zhaoyudong
 * @LastEditTime: 2026-05-18 16:49:00
 * @Description: ----
 *
 * 页面功能：
 *   ----
 */
import React from 'react';
import {
    View,
    Text,
    StyleSheet,
    TouchableOpacity,
    ScrollView,
} from 'react-native';
import SafeContainer from '../components/SafeContainer';

// 模块配置 - 新增模块时在此数组添加即可
const MODULES = [
    {
        id: 'password',
        title: '密码管理',
        description: '安全管理你的各类账号密码',
        icon: '\uD83D\uDD10',
        color: '#4CAF50',
        screen: 'AccountList',
    },
    {
      id: 'memo',
      title: '备忘录',
      description: '自定义分类，记录家人、房产等重要信息',
      icon: '\uD83D\uDCDD',
      color: '#2196F3',
      screen: 'MemoList',
    },
];

const HomeScreen = ({navigation}) => {
    const renderModuleCard = (module, index) => (
        <TouchableOpacity
            key={module.id}
            style={[styles.card, {borderLeftColor: module.color}]}
            onPress={() => navigation.navigate(module.screen)}
            activeOpacity={0.7}>
            <View style={styles.cardContent}>
                <View style={styles.cardLeft}>
                    <View style={[styles.iconWrap, {backgroundColor: module.color + '15'}]}>
                        <Text style={styles.icon}>{module.icon}</Text>
                    </View>
                    <View style={styles.cardText}>
                        <Text style={styles.cardTitle}>{module.title}</Text>
                        <Text style={styles.cardDesc}>{module.description}</Text>
                    </View>
                </View>
                <Text style={styles.cardArrow}> {">"} </Text>
            </View>
        </TouchableOpacity>
    );

    return (
        <SafeContainer style={styles.container}>
            <ScrollView
                contentContainerStyle={styles.scrollContent}
                showsVerticalScrollIndicator={false}>
                <View style={styles.header}>
                    <Text style={styles.greeting}>工具箱</Text>
                    <Text style={styles.subtitle}>选择一个功能模块开始使用</Text>
                </View>
                <View style={styles.moduleList}>
                    {MODULES.map((module, index) => renderModuleCard(module, index))}
                </View>
            </ScrollView>
        </SafeContainer>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#f5f6fa',
    },
    scrollContent: {
        paddingBottom: 30,
    },
    header: {
        paddingHorizontal: 20,
        paddingTop: 30,
        paddingBottom: 20,
    },
    greeting: {
        fontSize: 28,
        fontWeight: '700',
        color: '#1a1a2e',
        marginBottom: 6,
    },
    subtitle: {
        fontSize: 15,
        color: '#888',
    },
    moduleList: {
        paddingHorizontal: 16,
    },
    card: {
        backgroundColor: '#fff',
        borderRadius: 14,
        marginBottom: 14,
        borderLeftWidth: 4,
        elevation: 2,
        shadowColor: '#000',
        shadowOffset: {width: 0, height: 2},
        shadowOpacity: 0.06,
        shadowRadius: 6,
    },
    cardContent: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        padding: 18,
    },
    cardLeft: {
        flexDirection: 'row',
        alignItems: 'center',
        flex: 1,
    },
    iconWrap: {
        width: 48,
        height: 48,
        borderRadius: 14,
        alignItems: 'center',
        justifyContent: 'center',
        marginRight: 14,
    },
    icon: {
        fontSize: 24,
    },
    cardText: {
        flex: 1,
    },
    cardTitle: {
        fontSize: 17,
        fontWeight: '600',
        color: '#1a1a2e',
        marginBottom: 3,
    },
    cardDesc: {
        fontSize: 13,
        color: '#999',
    },
    cardArrow: {
        fontSize: 18,
        color: '#ccc',
        fontWeight: '300',
        marginLeft: 10,
    },
});

export default HomeScreen;