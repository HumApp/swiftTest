/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */
import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  NativeModules
} from 'react-native';
// NativeModules.SayHello.greetings('Theo', (name) => {console.log(name);});
NativeModules.AuthorizationManager.requestCloudServiceAuthorization('test String', (stuff) => {console.log(stuff);});
NativeModules.AuthorizationManager.requestMediaLibraryAuthorization(stuff => console.log('medialib', stuff));
NativeModules.AuthorizationManager.requestUserToken(stuff => console.log(stuff));
// console.dir(NativeModules);
export default class swiftTest extends Component {
  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          Welcome to React Native!
        </Text>
        <Text style={styles.instructions}>
          To get started, edit index.ios.js
        </Text>
        <Text style={styles.instructions}>
          Press Cmd+R to reload,{'\n'}
          Cmd+D or shake for dev menu
        </Text>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});

AppRegistry.registerComponent('swiftTest', () => swiftTest);
