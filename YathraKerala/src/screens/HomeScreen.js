import { View, Text, StyleSheet, SafeAreaView, TextInput, TouchableOpacity } from 'react-native';
import { colors } from '../theme/colors';
import { typography } from '../theme/typography';

export default function HomeScreen({ navigation }) {
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.weatherText}>🌤️ Kochi · 28°C</Text>
      </View>
      
      <View style={styles.searchCard}>
        <TextInput 
          style={styles.input} 
          placeholder="📍 Where from?" 
          placeholderTextColor={colors.textSecondary}
        />
        <View style={styles.divider} />
        <TextInput 
          style={styles.input} 
          placeholder="📍 Where to?" 
          placeholderTextColor={colors.textSecondary}
        />
        
        <TouchableOpacity 
          style={styles.button}
          onPress={() => navigation.navigate('Results')}
        >
          <Text style={styles.buttonText}>Find Routes</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.section}>
        <Text style={typography.h2}>Nearby Departures</Text>
        <View style={styles.departureItem}>
          <Text style={styles.departureMode}>🚌 Bus 101 → Kollam</Text>
          <Text style={styles.departureTime}>5 min</Text>
        </View>
        <View style={styles.departureItem}>
          <Text style={styles.departureMode}>🚆 Train → ERS</Text>
          <Text style={styles.departureTime}>18 min</Text>
        </View>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  header: {
    padding: 20,
    paddingTop: 40,
    backgroundColor: colors.primary,
    borderBottomLeftRadius: 20,
    borderBottomRightRadius: 20,
  },
  weatherText: {
    color: colors.surface,
    fontSize: 16,
    fontWeight: '600',
  },
  searchCard: {
    backgroundColor: colors.surface,
    margin: 20,
    padding: 15,
    borderRadius: 15,
    elevation: 5,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    marginTop: -20,
  },
  input: {
    height: 50,
    fontSize: 16,
    color: colors.text,
  },
  divider: {
    height: 1,
    backgroundColor: colors.border,
    marginVertical: 5,
  },
  button: {
    backgroundColor: colors.primary,
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
    marginTop: 15,
  },
  buttonText: {
    color: colors.surface,
    fontSize: 16,
    fontWeight: 'bold',
  },
  section: {
    padding: 20,
  },
  departureItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 15,
    borderBottomWidth: 1,
    borderBottomColor: colors.border,
  },
  departureMode: {
    ...typography.body,
  },
  departureTime: {
    ...typography.body,
    color: colors.success,
    fontWeight: 'bold',
  }
});
