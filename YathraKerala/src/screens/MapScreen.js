import { View, Text, StyleSheet } from 'react-native';
import { typography } from '../theme/typography';

export default function MapScreen() {
  return (
    <View style={styles.container}>
      <Text style={typography.h1}>Explore Map</Text>
      <Text style={typography.body}>Interactive transit map will go here.</Text>
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
