import { View, Text, StyleSheet, SafeAreaView, TouchableOpacity, ScrollView } from 'react-native';
import { colors } from '../theme/colors';
import { typography } from '../theme/typography';
import { mockRoutes } from '../data/mockRoutes';

export default function JourneyDetailScreen({ route, navigation }) {
  const { routeId } = route.params;
  const journey = mockRoutes.find(r => r.id === routeId);

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()}>
          <Text style={styles.backButton}>← Back</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Journey Details</Text>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent}>
        <View style={styles.summaryCard}>
          <Text style={typography.h2}>{journey.title}</Text>
          <Text style={styles.timeText}>{journey.departure} → {journey.arrival}</Text>
          <Text style={styles.fareText}>Total Fare: {journey.fare}</Text>
        </View>

        <View style={styles.timeline}>
          <View style={styles.timelineStep}>
            <View style={styles.dot} />
            <View style={styles.stepContent}>
              <Text style={styles.stepTitle}>Your Location</Text>
              <Text style={styles.stepDesc}>Walk 8 min (650m) to Station</Text>
            </View>
          </View>
          
          <View style={styles.timelineLine} />

          <View style={styles.timelineStep}>
            <View style={[styles.dot, { backgroundColor: journey.mode === 'Bus' ? colors.bus : colors.train }]} />
            <View style={styles.stepContent}>
              <Text style={styles.stepTitle}>Board {journey.mode}</Text>
              <Text style={styles.stepDesc}>Departs at {journey.departure}</Text>
            </View>
          </View>

          <View style={styles.timelineLine} />

          <View style={styles.timelineStep}>
            <View style={styles.dot} />
            <View style={styles.stepContent}>
              <Text style={styles.stepTitle}>Destination</Text>
              <Text style={styles.stepDesc}>Arrive at {journey.arrival}</Text>
            </View>
          </View>
        </View>

        <TouchableOpacity style={styles.bookButton}>
          <Text style={styles.bookButtonText}>Book / Save Route</Text>
        </TouchableOpacity>
      </ScrollView>
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
    backgroundColor: colors.primary,
    flexDirection: 'row',
    alignItems: 'center',
  },
  backButton: {
    color: colors.surface,
    fontSize: 16,
    marginRight: 15,
  },
  headerTitle: {
    color: colors.surface,
    fontSize: 18,
    fontWeight: 'bold',
  },
  scrollContent: {
    padding: 20,
  },
  summaryCard: {
    backgroundColor: colors.surface,
    padding: 20,
    borderRadius: 15,
    marginBottom: 30,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 3,
  },
  timeText: {
    ...typography.body,
    marginTop: 10,
  },
  fareText: {
    ...typography.h2,
    color: colors.primary,
    marginTop: 10,
  },
  timeline: {
    paddingLeft: 10,
  },
  timelineStep: {
    flexDirection: 'row',
    alignItems: 'flex-start',
  },
  dot: {
    width: 16,
    height: 16,
    borderRadius: 8,
    backgroundColor: colors.textSecondary,
    marginTop: 5,
  },
  timelineLine: {
    width: 2,
    height: 40,
    backgroundColor: colors.border,
    marginLeft: 7,
    marginVertical: 5,
  },
  stepContent: {
    marginLeft: 15,
    flex: 1,
  },
  stepTitle: {
    ...typography.h2,
    fontSize: 16,
  },
  stepDesc: {
    ...typography.body,
    color: colors.textSecondary,
    marginTop: 5,
  },
  bookButton: {
    backgroundColor: colors.primary,
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
    marginTop: 40,
  },
  bookButtonText: {
    color: colors.surface,
    fontSize: 16,
    fontWeight: 'bold',
  }
});
