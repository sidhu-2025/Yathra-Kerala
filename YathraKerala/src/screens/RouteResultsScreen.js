import { View, Text, StyleSheet, FlatList, TouchableOpacity, SafeAreaView } from 'react-native';
import { colors } from '../theme/colors';
import { typography } from '../theme/typography';
import { mockRoutes } from '../data/mockRoutes';

export default function RouteResultsScreen({ navigation }) {
  const renderItem = ({ item }) => (
    <TouchableOpacity 
      style={styles.card}
      onPress={() => navigation.navigate('Details', { routeId: item.id })}
    >
      <View style={styles.cardHeader}>
        <Text style={styles.cardTitle}>{item.title}</Text>
        <Text style={styles.fare}>{item.fare}</Text>
      </View>
      <View style={styles.cardBody}>
        <Text style={styles.timeText}>{item.departure} → {item.arrival}</Text>
        <Text style={styles.durationText}>{item.duration}</Text>
      </View>
      <View style={styles.cardFooter}>
        <Text style={styles.transfersText}>
          {item.transfers === 0 ? 'Direct' : `${item.transfers} Transfer(s)`}
        </Text>
        {item.recommended && <Text style={styles.recommendedBadge}>⭐ Recommended</Text>}
      </View>
    </TouchableOpacity>
  );

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()}>
          <Text style={styles.backButton}>← Back</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Kochi → Alappuzha</Text>
      </View>

      <View style={styles.comparisonBar}>
        <View style={[styles.bubble, { backgroundColor: colors.train }]}><Text style={styles.bubbleText}>🚆 1h15</Text></View>
        <View style={[styles.bubble, { backgroundColor: colors.combined }]}><Text style={styles.bubbleText}>🚌+🚆 1h30</Text></View>
        <View style={[styles.bubble, { backgroundColor: colors.bus }]}><Text style={styles.bubbleText}>🚌 1h45</Text></View>
      </View>

      <FlatList
        data={mockRoutes}
        renderItem={renderItem}
        keyExtractor={item => item.id}
        contentContainerStyle={styles.listContainer}
      />
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
  comparisonBar: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    padding: 15,
    backgroundColor: colors.surface,
    borderBottomWidth: 1,
    borderBottomColor: colors.border,
  },
  bubble: {
    paddingHorizontal: 15,
    paddingVertical: 8,
    borderRadius: 20,
  },
  bubbleText: {
    color: colors.surface,
    fontWeight: 'bold',
  },
  listContainer: {
    padding: 15,
  },
  card: {
    backgroundColor: colors.surface,
    borderRadius: 12,
    padding: 15,
    marginBottom: 15,
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 10,
  },
  cardTitle: {
    ...typography.h2,
    fontSize: 16,
  },
  fare: {
    ...typography.h2,
    color: colors.primary,
  },
  cardBody: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 10,
  },
  timeText: {
    ...typography.body,
  },
  durationText: {
    ...typography.body,
    fontWeight: 'bold',
  },
  cardFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 5,
    paddingTop: 10,
    borderTopWidth: 1,
    borderTopColor: colors.border,
  },
  transfersText: {
    ...typography.caption,
  },
  recommendedBadge: {
    ...typography.caption,
    color: colors.secondary,
    fontWeight: 'bold',
  }
});
