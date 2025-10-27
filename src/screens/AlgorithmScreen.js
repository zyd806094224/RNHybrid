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
                ({item}) => _renderItem(item) //不涉及this 建议直接这样调用 下面两种方式有性能开销
                // ({item}) => _renderItem.call(this, item) //call会立即执行 结尾不需要处理
                // ({item}) => _renderItem.bind(this, item)() //bind并不会立即执行，结尾需要加()
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
    data.push({
        id: 2,
        title: '快速排序'
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
    },
    // 快排
    quickSort: (arr, left, right) => {
        quick(arr, left, right)
    }

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
        },
        2: () => {
            const arr = [23, 1, 34, 2, 343, 4]
            algorithms.quickSort(arr, 0, arr.length - 1)
            console.log(arr)
        }
    };

    const handler = algorithmHandlers[item.id];
    if (handler) {
        handler();
    }
}

function quick(arr, left, right) {
    if (left >= right) {
        return
    }
    let P = arr[right]
    let part = partition(arr, left, right, P)
    quick(arr, left, part[0] - 1)
    quick(arr, part[1] + 1, right)
}

/**
 * 返回等于区域的左右边界，可能有重复值，返回数组
 * @param arr
 * @param left
 * @param right
 * @param P
 */
function partition(arr, left, right, P) {
    let less = left - 1;
    let more = right + 1;
    while (left < more) {
        if (arr[left] > P) {
            [arr[left], arr[more - 1]] = [arr[more - 1], arr[left]]
            more--
        } else if (arr[left] < P) {
            [arr[less + 1], arr[left]] = [arr[left], arr[less + 1]]
            left++
            less++
        } else {
            left++
        }
    }
    return [less + 1, more - 1]
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
