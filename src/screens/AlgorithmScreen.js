import {useEffect} from "react";
import {View,StyleSheet,Text} from "react-native";

const AlgorithmScreen = ({navigation}) => {
    useEffect(() => {

    }, []);

    return (
        <View style={styles.container}>
            <Text>AlgorithmScreen</Text>
            <Text>AlgorithmScreen2</Text>
        </View>
    )
}


const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#f5f5f5'
    }
});

export default AlgorithmScreen;
