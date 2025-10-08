  <h1>Flutter Happy Place</h1>

  <h2>Overview</h2>
  <p>
    <strong>Flutter Happy Place</strong> is a Flutter application that provides a simple interface for saving and listing locations. Each saved item contains a title and an associated geographic location selected via a map interface. The project currently includes the list screen (which displays stored location titles) and navigation to an "Add New Location" screen. The actual map-based location picker has not yet been implemented in this repository.
  </p>

  <h2>Key Features</h2>
  <ul>
    <li>List of saved locations displayed with title information.</li>
    <li>Navigation to an "Add New Location" screen from the list view.</li>
    <li>Designed to use a map-based picker for selecting a geographic location (picker implementation pending).</li>
  </ul>

  <h2>Project Status</h2>
  <p>
    The repository contains the UI for listing locations and a flow to add a new location. The location picker UI and logic (map view and coordinate selection) are not included and need to be implemented. Use this README as a guide for setting up the project, running it locally, and implementing the missing map picker feature.
  </p>

  <h2>Prerequisites</h2>
  <ul>
    <li>Flutter SDK (stable channel) installed and configured. Verify with <code>flutter --version</code>.</li>
    <li>Android Studio or Xcode (for Android or iOS development respectively) or another IDE that supports Flutter.</li>
    <li>An API key if you choose to integrate Google Maps (see the implementation notes below).</li>
  </ul>

  <h2>Installation and Setup</h2>
  <ol>
    <li>Clone the repository:
      <pre><code>git clone https://github.com/Iftikhar-Shams-Niloy/flutter_happy_place.git
cd flutter_happy_place</code></pre>
    </li>
    <li>Get dependencies:
      <pre><code>flutter pub get</code></pre>
    </li>
    <li>Run the app on an emulator or device:
      <pre><code>flutter run</code></pre>
    </li>
  </ol>

  <h2>Directory Structure (typical)</h2>
  <p class="muted">Note: actual file names and folders in the repository may differ slightly; this is a typical layout for reference.</p>
  <ul>
    <li><code>/lib</code> — Main application code</li>
    <li><code>/lib/main.dart</code> — App entrypoint</li>
    <li><code>/lib/screens/</code> — Screens such as the list screen and add-location screen</li>
    <li><code>/lib/widgets/</code> — Reusable widgets</li>
    <li><code>/assets/</code> — Static assets (icons, images)</li>
  </ul>

  <h2>Missing Piece: Map-based Location Picker</h2>
  <p>
    The repository currently lacks the map-based location picker. The rest of the flow (list of saved titles and navigation to add screen) is present. To enable full functionality, implement a screen that allows the user to select a point on a map and return the selected coordinates (latitude and longitude) to the "Add New Location" screen so the app can save them along with the title.
  </p>

  <h3>Implementation Suggestions</h3>
  <p>Two common options:</p>
  <ul>
    <li><strong>Google Maps</strong> — Use the <code>google_maps_flutter</code> plugin. Requires obtaining an API key for Android and/or iOS and configuring platform-specific settings.</li>
    <li><strong>OpenStreetMap / Leaflet</strong> — Use the <code>flutter_map</code> package (based on Leaflet) if you prefer an open-source alternative without Google API dependency.</li>
  </ul>

 
  <h2>Dependencies (recommended)</h2>
  <p class="muted">Add the following to <code>pubspec.yaml</code> if you adopt Google Maps:</p>
  <pre><code>dependencies:
  flutter:
    sdk: flutter
  google_maps_flutter: ^2.3.0
  # optionally:
  # location: ^4.4.0   # to request device location permission
  # permission_handler: ^10.2.0</code></pre>

  <p class="muted">
    Replace version constraints with the latest compatible package versions for your Flutter SDK.
  </p>

  <h2>Persistence and Storage</h2>
  <p>
    The repository does not document how saved locations are persisted. Typical choices include:
  </p>
  <ul>
    <li><code>sqflite</code> or <code>moor/Drift</code> — for structured local SQL storage.</li>
    <li><code>hive</code> — for a light-weight key-value/local document store.</li>
    <li><code>shared_preferences</code> — for very small amount of data (not recommended for lists of complex objects).</li>
  </ul>
  <p>
    Choose the package that best fits requirements and document the chosen approach in the repository after integrating it.
  </p>

  <h2>Contributing</h2>
  <p>
    Contributions are welcome. Recommended workflow:
  </p>
  <ol>
    <li>Fork the repository.</li>
    <li>Create a feature branch: <code>git checkout -b feature/map-picker</code>.</li>
    <li>Implement and test your changes.</li>
    <li>Open a pull request with a clear description of changes and testing steps.</li>
  </ol>

  <h2>Suggested Next Work Items</h2>
  <ul>
    <li>Implement the map-based location picker and wire it to the add-location flow.</li>
    <li>Add persistent storage for saved locations and demonstrable CRUD operations.</li>
    <li>Add form validation for location titles and clear UX for missing information.</li>
    <li>Document platform-specific setup for maps (API keys and manifest/plist changes).</li>
  </ul>
  <hr />

</body>
</html>
