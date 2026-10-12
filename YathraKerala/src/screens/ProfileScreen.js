import { View, Text, StyleSheet } from 'react-native';
import { typography } from '../theme/typography';

export default function ProfileScreen() {
  return (
    <View style={styles.container}>
      <Text style={typography.h1}>My Profile</Text>
      <Text style={typography.body}>User settings and saved routes.</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});
