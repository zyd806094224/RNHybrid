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
  for (let i = 1; i <= 100; i++) {
    data.push({
      id: i.toString(),
      title: `Item ${i}`,
      description: `This is the description for item ${i}. It can contain more details about the item.`,
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
    shadowOffset: { width: 0, height: 2 },
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