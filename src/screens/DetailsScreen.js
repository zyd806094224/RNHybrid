import React from 'react';
import {
  View,
  Text,
  Button,
  StyleSheet,
} from 'react-native';
import SafeContainer from '../components/SafeContainer';

const DetailsScreen = ({navigation}) => {
  return (
    <SafeContainer style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Details Screen</Text>
        <Text style={styles.description}>This is the details page where you can see more information.</Text>
        <View style={styles.buttonContainer}>
          <Button title="Go back" onPress={() => navigation.goBack()} />
          <View style={styles.spacer} />
          <Button
            title="Go to Home"
            onPress={() => navigation.navigate('Home')}
          />
          <View style={styles.spacer} />
          <Button
            title="Go to Profile"
            onPress={() => navigation.navigate('ProfileScreen')}
          />
          <View style={styles.spacer} />
          <Button
            title="Go to FlatList"
            onPress={() => navigation.navigate('FlatListScreen')}
          />
        </View>
      </View>
    </SafeContainer>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 10,
    color: '#333',
  },
  description: {
    fontSize: 16,
    marginBottom: 30,
    color: '#666',
    textAlign: 'center',
  },
  buttonContainer: {
    width: '80%',
  },
  spacer: {
    height: 10,
  },
});

export default DetailsScreen;
