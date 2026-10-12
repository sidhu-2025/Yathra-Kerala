import { createNativeStackNavigator } from '@react-navigation/native-stack';
import HomeScreen from '../screens/HomeScreen';
import RouteResultsScreen from '../screens/RouteResultsScreen';
import JourneyDetailScreen from '../screens/JourneyDetailScreen';

const Stack = createNativeStackNavigator();

export default function HomeStack() {
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      <Stack.Screen name="Search" component={HomeScreen} />
      <Stack.Screen name="Results" component={RouteResultsScreen} />
      <Stack.Screen name="Details" component={JourneyDetailScreen} />
    </Stack.Navigator>
  );
}
