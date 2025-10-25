import React from 'react';
import {
    View,
    Text,
    StyleSheet,
    SafeAreaView,
    FlatList,
    TouchableOpacity,
} from 'react-native';

// 生成100条假数据
const generateData = () => {
    const data = [];
    for (let i = 1; i <= 1000; i++) {
        data.push({
            id: i.toString(),
            title: `Item ${i}`,
            description: `条目 ${i}`,
        });
    }
    return data;
};

const FlatListScreen = ({navigation}) => {
    const data = generateData();

    const renderItem = ({item}) => (
        <TouchableOpacity style={styles.itemContainer} onPress={() => console.log('Pressed item', item.id)}>
            <Text style={styles.itemTitle}>{item.title}</Text>
            <Text style={styles.itemDescription}>{item.description}</Text>
        </TouchableOpacity>
    );

    return (
        <SafeAreaView style={styles.container}>
            <FlatList
                data={data}
                renderItem={renderItem}
                keyExtractor={item => item.id}
                contentContainerStyle={styles.listContainer}
                // 性能优化配置
                initialNumToRender={10}           // 初始渲染数量
                maxToRenderPerBatch={10}          // 每批渲染最大数量
                windowSize={5}                    // 渲染窗口大小
                removeClippedSubviews={true}      // 移除视窗外的子视图(Android)
                updateCellsBatchingPeriod={50}    // 更新批次间隔
                showsVerticalScrollIndicator={false} // 隐藏滚动条提升性能
            />
        </SafeAreaView>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#f5f5f5',
    },
    listContainer: {
        padding: 10,
    },
    itemContainer: {
        backgroundColor: 'white',
        padding: 15,
        marginBottom: 10,
        borderRadius: 8,
        elevation: 2, // Android阴影
        shadowColor: '#000', // iOS阴影
        shadowOffset: {width: 0, height: 2},
        shadowOpacity: 0.1,
        shadowRadius: 2,
    },
    itemTitle: {
        fontSize: 18,
        fontWeight: 'bold',
        color: '#333',
        marginBottom: 5,
    },
    itemDescription: {
        fontSize: 14,
        color: '#666',
    },
});

export default FlatListScreen;
