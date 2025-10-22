import React from 'react';
import {
  View,
  Text,
  Button,
  StyleSheet,
  SafeAreaView,
} from 'react-native';

const ProfileScreen = ({navigation}) => {
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Profile Screen</Text>
        <Text style={styles.description}>This is your profile page.</Text>
        <View style={styles.buttonContainer}>
          <Button
            title="Go to Home"
            onPress={() => navigation.navigate('Home')}
          />
          <View style={styles.spacer} />
          <Button
            title="Go to Details"
            onPress={() => navigation.navigate('Details')}
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