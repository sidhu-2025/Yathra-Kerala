import os

# Complete perfected SVG generator with exact center-to-center lines clipped by white shapes

svg_content = """<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg xmlns="http://www.w3.org/2000/svg" width="1800" height="1060" viewBox="0 0 1800 1060">
  <defs>
    <style>
      .entity-rect { fill: #ffffff; stroke: #1a1a1a; stroke-width: 1.8; rx: 1.5px; ry: 1.5px; }
      .rel-diamond { fill: #ffffff; stroke: #1a1a1a; stroke-width: 1.8; }
      .attr-ellipse { fill: #ffffff; stroke: #1a1a1a; stroke-width: 1.5; }
      .attr-derived { fill: #ffffff; stroke: #1a1a1a; stroke-width: 1.6; stroke-dasharray: 5,4; }
      .attr-multi-outer { fill: #ffffff; stroke: #1a1a1a; stroke-width: 1.5; }
      .attr-multi-inner { fill: none; stroke: #1a1a1a; stroke-width: 1.5; }
      .conn-line { stroke: #202020; stroke-width: 1.4; fill: none; }
      .text-base { font-family: 'Segoe UI', Arial, sans-serif; text-anchor: middle; dominant-baseline: central; fill: #111111; }
      .entity-text { font-size: 15px; font-weight: 600; letter-spacing: 0.2px; }
      .rel-text { font-size: 13.5px; font-weight: 500; }
      .attr-text { font-size: 12.5px; }
      .pk-text { font-size: 12.5px; text-decoration: underline; font-weight: 600; }
      .card-text { font-family: 'Segoe UI', Arial, sans-serif; font-size: 14.5px; font-weight: bold; fill: #000000; text-anchor: middle; dominant-baseline: central; paint-order: stroke fill; stroke: #ffffff; stroke-width: 4px; stroke-linejoin: round; }
    </style>
  </defs>

  <!-- Background -->
  <rect width="100%" height="100%" fill="#ffffff"/>

  <!-- ================= 1. ALL CONNECTOR LINES (Drawn under shapes) ================= -->
  
  <!-- auth_user attributes -->
  <line class="conn-line" x1="480" y1="160" x2="370" y2="80"/>
  <line class="conn-line" x1="480" y1="160" x2="480" y2="70"/>
  <line class="conn-line" x1="480" y1="160" x2="580" y2="80"/>

  <!-- auth_user to 'has' to user -->
  <polyline class="conn-line" points="480,160 590,160 590,220"/>
  <line class="conn-line" x1="590" y1="220" x2="590" y2="300"/>

  <!-- user attributes -->
  <line class="conn-line" x1="590" y1="300" x2="490" y2="205"/>
  <line class="conn-line" x1="590" y1="300" x2="425" y2="240"/>
  <line class="conn-line" x1="590" y1="300" x2="395" y2="290"/>
  <line class="conn-line" x1="590" y1="300" x2="390" y2="340"/>
  <!-- email line: safely to cx=365, cy=390, away from contains -->
  <line class="conn-line" x1="590" y1="300" x2="365" y2="390"/>

  <!-- user to 'views' to timings -->
  <line class="conn-line" x1="590" y1="300" x2="755" y2="300"/>
  <line class="conn-line" x1="755" y1="300" x2="755" y2="430"/>

  <!-- timings attributes -->
  <line class="conn-line" x1="755" y1="430" x2="875" y2="345"/>
  <line class="conn-line" x1="755" y1="430" x2="920" y2="405"/>
  <line class="conn-line" x1="755" y1="430" x2="945" y2="465"/>
  <line class="conn-line" x1="755" y1="430" x2="910" y2="525"/>
  <line class="conn-line" x1="755" y1="430" x2="755" y2="515"/>

  <!-- timings to 'contains' to stop_allocation -->
  <line class="conn-line" x1="755" y1="430" x2="450" y2="430"/>
  <line class="conn-line" x1="450" y1="430" x2="450" y2="540"/>

  <!-- stop_allocation attributes -->
  <line class="conn-line" x1="450" y1="540" x2="230" y2="505"/>
  <line class="conn-line" x1="450" y1="540" x2="225" y2="545"/>
  <line class="conn-line" x1="450" y1="540" x2="230" y2="585"/>

  <!-- stop_allocation to 'contains' to stop -->
  <line class="conn-line" x1="450" y1="540" x2="450" y2="645"/>
  <line class="conn-line" x1="450" y1="645" x2="450" y2="750"/>

  <!-- stop_allocation to 'contains' to vehicle (clean corner routing) -->
  <polyline class="conn-line" points="485,540 485,615 745,615"/>
  <line class="conn-line" x1="745" y1="615" x2="1010" y2="650"/>

  <!-- stop attributes -->
  <line class="conn-line" x1="450" y1="750" x2="315" y2="675"/>
  <line class="conn-line" x1="450" y1="750" x2="290" y2="720"/>
  <line class="conn-line" x1="450" y1="750" x2="285" y2="765"/>
  <line class="conn-line" x1="450" y1="750" x2="300" y2="815"/>
  <line class="conn-line" x1="450" y1="750" x2="345" y2="865"/>
  <line class="conn-line" x1="450" y1="750" x2="435" y2="875"/>

  <!-- stop to 'has' to route -->
  <line class="conn-line" x1="450" y1="750" x2="565" y2="750"/>
  <line class="conn-line" x1="565" y1="750" x2="675" y2="750"/>

  <!-- route attributes -->
  <line class="conn-line" x1="675" y1="750" x2="605" y2="835"/>
  <line class="conn-line" x1="675" y1="750" x2="695" y2="845"/>
  <line class="conn-line" x1="675" y1="750" x2="765" y2="795"/>

  <!-- vehicle attributes -->
  <line class="conn-line" x1="1010" y1="650" x2="895" y2="715"/>
  <line class="conn-line" x1="1010" y1="650" x2="945" y2="790"/>
  <line class="conn-line" x1="1010" y1="650" x2="1025" y2="780"/>
  <line class="conn-line" x1="1010" y1="650" x2="1085" y2="735"/>

  <!-- vehicle to 'has' to GPS Tracking -->
  <line class="conn-line" x1="1010" y1="650" x2="1045" y2="520"/>
  <line class="conn-line" x1="1045" y1="520" x2="1190" y2="410"/>

  <!-- GPS Tracking attributes -->
  <line class="conn-line" x1="1190" y1="410" x2="1070" y2="325"/>
  <line class="conn-line" x1="1190" y1="410" x2="1190" y2="315"/>
  <line class="conn-line" x1="1190" y1="410" x2="1310" y2="345"/>
  <line class="conn-line" x1="1190" y1="410" x2="1345" y2="410"/>
  <line class="conn-line" x1="1190" y1="410" x2="1320" y2="475"/>

  <!-- vehicle to 'has' to Travel History -->
  <line class="conn-line" x1="1010" y1="650" x2="1130" y2="565"/>
  <line class="conn-line" x1="1130" y1="565" x2="1300" y2="600"/>

  <!-- Travel History attributes (Connecting directly from center 1300, 600) -->
  <line class="conn-line" x1="1300" y1="600" x2="1235" y2="505"/>
  <line class="conn-line" x1="1300" y1="600" x2="1375" y2="510"/>
  <line class="conn-line" x1="1300" y1="600" x2="1455" y2="575"/>
  <line class="conn-line" x1="1300" y1="600" x2="1405" y2="655"/>
  <line class="conn-line" x1="1300" y1="600" x2="1130" y2="635"/>
  <line class="conn-line" x1="1300" y1="600" x2="1130" y2="695"/>
  <line class="conn-line" x1="1300" y1="600" x2="1180" y2="760"/>

  <!-- Travel History to 'Generates' to ETA Prediction (Direct center connections) -->
  <line class="conn-line" x1="1300" y1="600" x2="1300" y2="780"/>
  <line class="conn-line" x1="1300" y1="780" x2="1485" y2="780"/>

  <!-- ETA Prediction attributes -->
  <line class="conn-line" x1="1485" y1="780" x2="1445" y2="695"/>
  <line class="conn-line" x1="1485" y1="780" x2="1560" y2="690"/>
  <line class="conn-line" x1="1485" y1="780" x2="1600" y2="765"/>
  <line class="conn-line" x1="1485" y1="780" x2="1575" y2="865"/>
  <line class="conn-line" x1="1485" y1="780" x2="1425" y2="870"/>


  <!-- ================= 2. ALL ENTITY RECTANGLES (White fill covers line interiors) ================= -->
  
  <!-- auth_user -->
  <rect class="entity-rect" x="430" y="141" width="100" height="38"/>
  <text class="text-base entity-text" x="480" y="160">auth_user</text>

  <!-- user -->
  <rect class="entity-rect" x="542" y="281" width="96" height="38"/>
  <text class="text-base entity-text" x="590" y="300">user</text>

  <!-- timings -->
  <rect class="entity-rect" x="712" y="411" width="86" height="38"/>
  <text class="text-base entity-text" x="755" y="430">timings</text>

  <!-- stop_allocation -->
  <rect class="entity-rect" x="385" y="521" width="130" height="38"/>
  <text class="text-base entity-text" x="450" y="540">stop_allocation</text>

  <!-- stop -->
  <rect class="entity-rect" x="407" y="731" width="86" height="38"/>
  <text class="text-base entity-text" x="450" y="750">stop</text>

  <!-- route -->
  <rect class="entity-rect" x="640" y="731" width="70" height="38"/>
  <text class="text-base entity-text" x="675" y="750">route</text>

  <!-- vehicle -->
  <rect class="entity-rect" x="965" y="631" width="90" height="38"/>
  <text class="text-base entity-text" x="1010" y="650">vehicle</text>

  <!-- GPS Tracking -->
  <rect class="entity-rect" x="1130" y="391" width="120" height="38"/>
  <text class="text-base entity-text" x="1190" y="410">GPS Tracking</text>

  <!-- Travel History -->
  <rect class="entity-rect" x="1240" y="581" width="120" height="38"/>
  <text class="text-base entity-text" x="1300" y="600">Travel History</text>

  <!-- ETA Prediction -->
  <rect class="entity-rect" x="1425" y="761" width="120" height="38"/>
  <text class="text-base entity-text" x="1485" y="780">ETA Prediction</text>


  <!-- ================= 3. ALL RELATIONSHIP DIAMONDS (White fill) ================= -->

  <!-- has (auth_user - user) -->
  <polygon class="rel-diamond" points="590,195 618,220 590,245 562,220"/>
  <text class="text-base rel-text" x="590" y="220">has</text>

  <!-- views (user - timings) -->
  <polygon class="rel-diamond" points="755,275 785,300 755,325 725,300"/>
  <text class="text-base rel-text" x="755" y="300">views</text>

  <!-- contains (timings - stop_allocation) -->
  <polygon class="rel-diamond" points="450,405 488,430 450,455 412,430"/>
  <text class="text-base rel-text" x="450" y="430">contains</text>

  <!-- contains (stop_allocation - stop) -->
  <polygon class="rel-diamond" points="450,620 488,645 450,670 412,645"/>
  <text class="text-base rel-text" x="450" y="645">contains</text>

  <!-- contains (stop_allocation - vehicle) -->
  <polygon class="rel-diamond" points="745,590 785,615 745,640 705,615"/>
  <text class="text-base rel-text" x="745" y="615">contains</text>

  <!-- has (stop - route) -->
  <polygon class="rel-diamond" points="565,725 595,750 565,775 535,750"/>
  <text class="text-base rel-text" x="565" y="750">has</text>

  <!-- has (vehicle - GPS Tracking) -->
  <polygon class="rel-diamond" points="1045,495 1070,520 1045,545 1020,520"/>
  <text class="text-base rel-text" x="1045" y="520">has</text>

  <!-- has (vehicle - Travel History) -->
  <polygon class="rel-diamond" points="1130,540 1155,565 1130,590 1105,565"/>
  <text class="text-base rel-text" x="1130" y="565">has</text>

  <!-- Generates (Travel History - ETA Prediction) -->
  <polygon class="rel-diamond" points="1300,752 1348,780 1300,808 1252,780"/>
  <text class="text-base rel-text" x="1300" y="780">Generates</text>


  <!-- ================= 4. ALL ATTRIBUTES (Ellipses with white fill) ================= -->

  <!-- auth_user attributes -->
  <ellipse class="attr-ellipse" cx="370" cy="80" rx="44" ry="19"/>
  <text class="text-base attr-text" x="370" y="80">username</text>

  <ellipse class="attr-ellipse" cx="480" cy="70" rx="44" ry="19"/>
  <text class="text-base attr-text" x="480" y="70">password</text>

  <!-- id (PK) of auth_user -->
  <ellipse class="attr-ellipse" cx="580" cy="80" rx="35" ry="19"/>
  <text class="text-base pk-text" x="580" y="80">id</text>

  <!-- user attributes -->
  <!-- phone: MULTIVALUED (Double ellipse) -->
  <ellipse class="attr-multi-outer" cx="490" cy="205" rx="38" ry="19"/>
  <ellipse class="attr-multi-inner" cx="490" cy="205" rx="32" ry="14"/>
  <text class="text-base attr-text" x="490" y="205">phone</text>

  <ellipse class="attr-ellipse" cx="425" cy="240" rx="36" ry="18"/>
  <text class="text-base attr-text" x="425" y="240">login</text>

  <!-- id (PK) of user -->
  <ellipse class="attr-ellipse" cx="395" cy="290" rx="35" ry="18"/>
  <text class="text-base pk-text" x="395" y="290">id</text>

  <ellipse class="attr-ellipse" cx="390" cy="340" rx="36" ry="18"/>
  <text class="text-base attr-text" x="390" y="340">name</text>

  <!-- email: shifted safely to cx=365, cy=390 so it NEVER touches contains at (450, 430) -->
  <ellipse class="attr-ellipse" cx="365" cy="390" rx="38" ry="18"/>
  <text class="text-base attr-text" x="365" y="390">email</text>

  <!-- timings attributes -->
  <!-- id (PK) of timings -->
  <ellipse class="attr-ellipse" cx="875" cy="345" rx="35" ry="18"/>
  <text class="text-base pk-text" x="875" y="345">id</text>

  <ellipse class="attr-ellipse" cx="920" cy="405" rx="36" ry="18"/>
  <text class="text-base attr-text" x="920" y="405">day</text>

  <ellipse class="attr-ellipse" cx="945" cy="465" rx="38" ry="18"/>
  <text class="text-base attr-text" x="945" y="465">arrival</text>

  <ellipse class="attr-ellipse" cx="910" cy="525" rx="46" ry="18"/>
  <text class="text-base attr-text" x="910" y="525">departure</text>

  <ellipse class="attr-ellipse" cx="755" cy="515" rx="60" ry="19"/>
  <text class="text-base attr-text" x="755" y="515">stop_allocation</text>

  <!-- stop_allocation attributes -->
  <!-- id (PK) of stop_allocation -->
  <ellipse class="attr-ellipse" cx="230" cy="505" rx="35" ry="18"/>
  <text class="text-base pk-text" x="230" y="505">id</text>

  <ellipse class="attr-ellipse" cx="225" cy="545" rx="35" ry="18"/>
  <text class="text-base attr-text" x="225" y="545">stop</text>

  <ellipse class="attr-ellipse" cx="230" cy="585" rx="40" ry="18"/>
  <text class="text-base attr-text" x="230" y="585">vehicle</text>

  <!-- stop attributes -->
  <ellipse class="attr-ellipse" cx="315" cy="675" rx="42" ry="18"/>
  <text class="text-base attr-text" x="315" y="675">latitude</text>

  <ellipse class="attr-ellipse" cx="290" cy="720" rx="36" ry="18"/>
  <text class="text-base attr-text" x="290" y="720">route</text>

  <!-- id (PK) of stop -->
  <ellipse class="attr-ellipse" cx="285" cy="765" rx="35" ry="18"/>
  <text class="text-base pk-text" x="285" y="765">id</text>

  <ellipse class="attr-ellipse" cx="300" cy="815" rx="40" ry="18"/>
  <text class="text-base attr-text" x="300" y="815">stop_no</text>

  <ellipse class="attr-ellipse" cx="345" cy="865" rx="46" ry="18"/>
  <text class="text-base attr-text" x="345" y="865">stop_name</text>

  <ellipse class="attr-ellipse" cx="435" cy="875" rx="45" ry="18"/>
  <text class="text-base attr-text" x="435" y="875">longitude</text>

  <!-- route attributes -->
  <!-- id (PK) of route -->
  <ellipse class="attr-ellipse" cx="605" cy="835" rx="35" ry="18"/>
  <text class="text-base pk-text" x="605" y="835">id</text>

  <ellipse class="attr-ellipse" cx="695" cy="845" rx="45" ry="18"/>
  <text class="text-base attr-text" x="695" y="845">start_point</text>

  <ellipse class="attr-ellipse" cx="765" cy="795" rx="42" ry="18"/>
  <text class="text-base attr-text" x="765" y="795">end_point</text>

  <!-- vehicle attributes -->
  <!-- id (PK) of vehicle -->
  <ellipse class="attr-ellipse" cx="895" cy="715" rx="35" ry="18"/>
  <text class="text-base pk-text" x="895" y="715">id</text>

  <ellipse class="attr-ellipse" cx="945" cy="790" rx="58" ry="19"/>
  <text class="text-base attr-text" x="945" y="790">vehicle_number</text>

  <ellipse class="attr-ellipse" cx="1025" cy="780" rx="50" ry="18"/>
  <text class="text-base attr-text" x="1025" y="780">vehicle_type</text>

  <ellipse class="attr-ellipse" cx="1085" cy="735" rx="42" ry="18"/>
  <text class="text-base attr-text" x="1085" y="735">sub_type</text>

  <!-- GPS Tracking attributes -->
  <!-- tracking_id (PK) of GPS Tracking -->
  <ellipse class="attr-ellipse" cx="1070" cy="325" rx="50" ry="19"/>
  <text class="text-base pk-text" x="1070" y="325">tracking_id</text>

  <ellipse class="attr-ellipse" cx="1190" cy="315" rx="56" ry="19"/>
  <text class="text-base attr-text" x="1190" y="315">vehicle_id (FK)</text>

  <ellipse class="attr-ellipse" cx="1310" cy="345" rx="42" ry="18"/>
  <text class="text-base attr-text" x="1310" y="345">latitude</text>

  <ellipse class="attr-ellipse" cx="1345" cy="410" rx="44" ry="18"/>
  <text class="text-base attr-text" x="1345" y="410">longitude</text>

  <ellipse class="attr-ellipse" cx="1320" cy="475" rx="38" ry="18"/>
  <text class="text-base attr-text" x="1320" y="475">speed</text>

  <!-- Travel History attributes -->
  <!-- history_id (PK) of Travel History -->
  <ellipse class="attr-ellipse" cx="1235" cy="505" rx="50" ry="19"/>
  <text class="text-base pk-text" x="1235" y="505">history_id</text>

  <ellipse class="attr-ellipse" cx="1375" cy="510" rx="56" ry="19"/>
  <text class="text-base attr-text" x="1375" y="510">vehicle_id (FK)</text>

  <ellipse class="attr-ellipse" cx="1455" cy="575" rx="54" ry="19"/>
  <text class="text-base attr-text" x="1455" y="575">route_id (FK)</text>

  <ellipse class="attr-ellipse" cx="1405" cy="655" rx="52" ry="19"/>
  <text class="text-base attr-text" x="1405" y="655">stop_id (FK)</text>

  <ellipse class="attr-ellipse" cx="1130" cy="635" rx="50" ry="19"/>
  <text class="text-base attr-text" x="1130" y="635">arrival_time</text>

  <ellipse class="attr-ellipse" cx="1130" cy="695" rx="54" ry="19"/>
  <text class="text-base attr-text" x="1130" y="695">departure_time</text>

  <!-- Travel Duration: DERIVED (Dashed ellipse with white background) -->
  <ellipse class="attr-derived" cx="1180" cy="760" rx="58" ry="20"/>
  <text class="text-base attr-text" x="1180" y="760">Travel Duration</text>

  <!-- ETA Prediction attributes -->
  <!-- prediction_id (PK) of ETA Prediction -->
  <ellipse class="attr-ellipse" cx="1445" cy="695" rx="50" ry="19"/>
  <text class="text-base pk-text" x="1445" y="695">prediction_id</text>

  <ellipse class="attr-ellipse" cx="1560" cy="690" rx="44" ry="18"/>
  <text class="text-base attr-text" x="1560" y="690">vehicle_id</text>

  <ellipse class="attr-ellipse" cx="1600" cy="765" rx="42" ry="18"/>
  <text class="text-base attr-text" x="1600" y="765">route_id</text>

  <ellipse class="attr-ellipse" cx="1575" cy="865" rx="76" ry="20"/>
  <text class="text-base attr-text" x="1575" y="865">predicted_arrival_time</text>

  <ellipse class="attr-ellipse" cx="1425" cy="870" rx="54" ry="19"/>
  <text class="text-base attr-text" x="1425" y="870">prediction_time</text>


  <!-- ================= 5. ALL CARDINALITY RATIOS ================= -->

  <!-- auth_user - has - user (1 : 1) -->
  <text class="card-text" x="542" y="148">1</text>
  <text class="card-text" x="605" y="260">1</text>

  <!-- user - views - timings (M : N) -->
  <text class="card-text" x="660" y="288">M</text>
  <text class="card-text" x="770" y="375">N</text>

  <!-- stop_allocation - contains - timings (1 : N) -->
  <text class="card-text" x="465" y="485">1</text>
  <text class="card-text" x="685" y="418">N</text>

  <!-- stop - contains - stop_allocation (1 : N) -->
  <text class="card-text" x="465" y="585">N</text>
  <text class="card-text" x="465" y="700">1</text>

  <!-- vehicle - contains - stop_allocation (1 : N) -->
  <text class="card-text" x="505" y="605">N</text>
  <text class="card-text" x="935" y="625">1</text>

  <!-- stop - has - route (M : N) -->
  <text class="card-text" x="515" y="738">M</text>
  <text class="card-text" x="620" y="738">N</text>

  <!-- vehicle - has - GPS Tracking (1 : N) -->
  <text class="card-text" x="1015" y="595">1</text>
  <text class="card-text" x="1120" y="455">N</text>

  <!-- vehicle - has - Travel History (1 : N) -->
  <text class="card-text" x="1075" y="610">1</text>
  <text class="card-text" x="1215" y="575">N</text>

  <!-- Travel History - Generates - ETA Prediction (1 : N) -->
  <text class="card-text" x="1315" y="695">1</text>
  <text class="card-text" x="1395" y="770">N</text>

</svg>
"""

with open("generate_svg_v3.py", "w", encoding="utf-8") as f:
    f.write('svg_code = """' + svg_content.replace('"""', '\\"\\"\\"') + '"""\n')
    f.write('with open("er_diagram_v3.svg", "w", encoding="utf-8") as f: f.write(svg_code)\n')
