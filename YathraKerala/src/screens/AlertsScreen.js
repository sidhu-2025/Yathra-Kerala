import { View, Text, StyleSheet } from 'react-native';
import { typography } from '../theme/typography';

export default function AlertsScreen() {
  return (
    <View style={styles.container}>
      <Text style={typography.h1}>Disruptions</Text>
      <Text style={typography.body}>Active weather alerts will go here.</Text>
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
