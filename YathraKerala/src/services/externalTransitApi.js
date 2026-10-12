// YathraKerala External Transit API Service
// This module defines the API contracts and simulates live data fetching for:
// 1. Indian Railways (NTES/IRCTC) Live Status & Seat Availability
// 2. KSRTC & Private Bus Schedules/Tracking
// 3. Kochi Metro routes and transfers

// Simulated Network Latency Helper
const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));

export const externalTransitApi = {
  /**
   * Search for multi-modal routes between two points
   * @param {string} from - Origin name
   * @param {string} to - Destination name
   * @param {string} departureTime - Time of travel
   */
  searchRoutes: async (from, to, departureTime = 'Now') => {
    await delay(1200); // Simulate network delay

    const normalizedFrom = from.toLowerCase().trim();
    const normalizedTo = to.toLowerCase().trim();

    // Custom simulated routes for the popular Kochi-Alappuzha corridor
    if (
      (normalizedFrom.includes('kochi') || normalizedFrom.includes('ernakulam') || normalizedFrom.includes('ekm') || normalizedFrom.includes('ers')) &&
      (normalizedTo.includes('alappuzha') || normalizedTo.includes('allp') || normalizedTo.includes('alleppey'))
    ) {
      return [
        {
          id: 'train_venad_16341',
          mode: 'Train',
          title: 'Train · Venad Express (16341)',
          duration: '1h 15m',
          fare: '₹60',
          departure: '3:05 PM',
          arrival: '4:20 PM',
          transfers: 0,
          recommended: true,
          liveStatus: 'On Time. Next stop: Cherthala (3:45 PM)',
          seatAvailability: 'General: Available | Sleeper: Available (WL 5) | AC: Available (12)',
          platform: 'Platform 3 (Ernakulam Jn)'
        },
        {
          id: 'bus_ksrtc_sf_101',
          mode: 'Bus',
          title: 'Bus · KSRTC Super Fast',
          duration: '1h 45m',
          fare: '₹95',
          departure: '2:45 PM',
          arrival: '4:30 PM',
          transfers: 0,
          recommended: false,
          liveStatus: 'Delayed 10 mins due to NH66 traffic at Kundannoor.',
          seatAvailability: '42 Seats Available',
          platform: 'Platform 2 (KSRTC Stand Ernakulam)'
        },
        {
          id: 'combined_metro_train_auto',
          mode: 'Combined',
          title: 'Metro + Train + Auto Rickshaw',
          duration: '1h 30m',
          fare: '₹115',
          departure: '3:00 PM',
          arrival: '4:30 PM',
          transfers: 2,
          recommended: false,
          liveStatus: 'Metro: Running normally. Train: On Time.',
          seatAvailability: 'Multi-leg trip. Seat booking recommended for Train segment.',
          platform: 'Vyttila Hub -> Ernakulam South Metro -> Ernakulam Jn'
        }
      ];
    }

    // Dynamic fallback builder for any other searched route in Kerala
    return [
      {
        id: `bus_generic_${Date.now()}`,
        mode: 'Bus',
        title: `KSRTC Ordinary (via Local highway)`,
        duration: '2h 15m',
        fare: '₹85',
        departure: '4:00 PM',
        arrival: '6:15 PM',
        transfers: 0,
        recommended: true,
        liveStatus: 'Running normally.',
        seatAvailability: 'Unreserved seating',
        platform: 'Local Bus Stop'
      },
      {
        id: `combined_generic_${Date.now()}`,
        mode: 'Combined',
        title: 'Local Bus + Auto Rickshaw connection',
        duration: '1h 55m',
        fare: '₹140',
        departure: '4:15 PM',
        arrival: '6:10 PM',
        transfers: 1,
        recommended: false,
        liveStatus: 'Bus running normally. Local auto stand active.',
        seatAvailability: 'No booking required',
        platform: 'Transfer at town center stand'
      }
    ];
  },

  /**
   * Get real-time updates for a specific transit leg/vehicle
   * @param {string} id - Route/Vehicle ID
   */
  getLiveUpdate: async (id) => {
    await delay(500); // Quick check
    if (id.includes('train')) {
      return {
        delayMinutes: 0,
        nextStation: 'Cherthala',
        etaNextStation: '3:45 PM',
        currentLocation: 'Passing Kumbalam',
        crowdFactor: 'Medium (60% occupied)',
      };
    } else if (id.includes('bus')) {
      return {
        delayMinutes: 10,
        nextStation: 'Aroor Junction',
        etaNextStation: '3:10 PM',
        currentLocation: 'Kundannoor flyover',
        crowdFactor: 'High (Standing space only)',
      };
    }
    return {
      delayMinutes: 0,
      nextStation: 'Unknown',
      etaNextStation: '--:--',
      currentLocation: 'GPS signal lost',
      crowdFactor: 'Unknown',
    };
  }
};
