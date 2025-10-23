import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
} from 'react-native';
import CustomButton from '../components/Button';

const ProfileScreen = ({navigation}) => {
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Profile Screen</Text>
        <Text style={styles.description}>This is the profile page where you can see user information.</Text>
        <View style={styles.buttonContainer}>
          <CustomButton
            title="Go back"
            onPress={() => navigation.goBack()}
          />
          <View style={styles.spacer} />
          <CustomButton
            title="Go to Home"
            onPress={() => navigation.navigate('Home')}
            style={{backgroundColor: '#FF9800'}}
          />
          <View style={styles.spacer} />
          <CustomButton
            title="Go to Details"
            onPress={() => navigation.navigate('Details')}
            style={{backgroundColor: '#2196F3'}}
          />
          <View style={styles.spacer} />
          <CustomButton
            title="Go to FlatList"
            onPress={() => navigation.navigate('FlatListScreen')}
            style={{backgroundColor: '#9C27B0'}}
          />
        </View>
      </View>
    </SafeAreaView>
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

export default ProfileScreen;