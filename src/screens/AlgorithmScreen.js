import {useEffect} from "react";
import {View, StyleSheet, Text, FlatList, TouchableOpacity} from "react-native";

const AlgorithmScreen = ({navigation}) => {
    const data = _generateData();

    useEffect(() => {

    }, []);

    return (
        <View style={styles.container}>
            <Text style={styles.title}>AlgorithmScreen</Text>
            <FlatList data={
                data
            } renderItem={
                // ({item}) => _renderItem.call(this, item) //call会立即执行 结尾不需要处理
                ({item}) => _renderItem.bind(this, item)() //bind并不会立即执行，结尾需要加()
            } keyExtractor={
                item => item.id
            }
            />
        </View>
    )
}

function _generateData() {
    const data = []
    data.push({
        id: 1,
        title: '01背包'
    })
    return data
}

function _renderItem(item) {
    return (
        <TouchableOpacity style={styles.item} onPress={_onItemClick.bind(this, item)}>
            <Text>{item.title}</Text>
        </TouchableOpacity>
    )
}

//策略模式
const algorithms = {
    backpack01: (weight, value, W) => {
        // 01背包算法实现
        return _process(weight, value, W);
    }
    // 可以添加更多算法
};

function _onItemClick(item) {
    console.log(JSON.stringify(item))
    const algorithmHandlers = {
        1: () => {
            const weight = [1, 2, 3, 4];
            const value = [2, 4, 4, 5];
            const W = 5;
            let number = algorithms.backpack01(weight, value, W);
            console.log(number);
        }
    };

    const handler = algorithmHandlers[item.id];
    if (handler) {
        handler();
    }
}

/**
 *
 * @param weight
 * @param value
 * @param W
 * @returns {number}
 */
function _process(weight, value, W) {
    if (W === 0) return 0
    if (weight == null || weight.length === 0) return 0
    let dp = []
    for (let j = 0; j <= W; j++) {
        dp[j] = new Array(weight.length).fill(0)
    }
    for (let j = 0; j <= W; j++) {
        dp[0][j] = (j >= weight[0]) ? value[0] : 0
    }

    for (let i = 1; i < weight.length; i++) {
        for (let j = 0; j <= W; j++) {
            if (weight[i] > j) {
                dp[i][j] = dp[i - 1][j]
            } else {
                dp[i][j] = Math.max(dp[i - 1][j], value[i] + dp[i - 1][j - weight[i]])
            }
        }
    }
    return dp[weight.length - 1][W]
}


const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#f5f5f5'
    },
    title: {
        fontSize: 20,
        fontWeight: 'bold',
        textAlign: 'center',
        marginVertical: 16
    },
    item: {
        backgroundColor: '#fff',
        padding: 20,
        marginVertical: 8,
        marginHorizontal: 16
    },
});

export default AlgorithmScreen;
