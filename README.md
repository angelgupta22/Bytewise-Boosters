SatOptiNet - 5G Transmitter Optimisation in Urban Environments

Project Overview

**SatOptiNet** is a MATLAB-based simulation framework designed to optimize the placement of 5G transmitters (Tx) in an urban setting using ray tracing and coverage analysis. The objective is to determine the best subset of transmitters that maximizes receiver (Rx) coverage within a given area while minimizing interference and the number of active transmitters.

This project utilizes OpenStreetMap (OSM) building data to simulate realistic environments, evaluate signal strength, and explore different reflection scenarios.

📄 **Presentation**: `Bytewise-Boosters(SatOptiNet).pdf`  
📂 **Main Script**: `Optimisation.m`  
🗺️ **Map Data**: `map.osm` (OpenStreetMap format)

---

## 📂 Project Files

| File | Description |
|------|-------------|
| `Optimisation.m` | Main MATLAB script that loads OSM data, places Tx/Rx, performs ray tracing, evaluates coverage, and outputs the best transmitter sets |
| `map.osm` | Geo-referenced map of the area (Connaught Place, Delhi) with building geometry for ray tracing |
| `Bytewise-Boosters(SatOptiNet).pdf` | Project presentation detailing goals, approach, results, and future scope |
| `best_tx_cases.csv` | Output file storing optimal Tx sets for different thresholds and reflection levels |

---

## 🧠 How It Works

1. **Map Loading**: Loads `map.osm` into MATLAB's Site Viewer with a topographic basemap.
2. **Tx/Rx Grid Setup**: Places transmitters in a uniform grid and receivers in a configurable grid layout within a bounding box.
3. **Ray Tracing**: Evaluates signal strength at each receiver using a ray tracing propagation model across multiple reflection levels.
4. **Threshold Evaluation**: For each reflection level, thresholds from -40 dBm to -120 dBm are used to compute binary signal matrices.
5. **Optimisation**: A brute-force approach is used to find the smallest Tx subset covering the maximum number of Rx sites.
6. **Results & Visualization**: Outputs are saved to a CSV file and visualized in a 3D coverage plot by threshold and Tx set.

---

## ⚙️ How to Run

### Requirements
- MATLAB 2023a or newer
- No additional toolboxes required (works without Mapping Toolbox)
- Optional: Internet connection for online basemap rendering

### Instructions
1. Open `Optimisation.m` in MATLAB.
2. Ensure that `map.osm` is in the same directory as the script.
3. Run the script (`F5` or `Run` button).
4. The script will:
   - Load the map and display Tx and Rx points
   - Evaluate signal strength using ray tracing
   - Output the best Tx sets in `best_tx_cases.csv`
   - Display a 3D plot of results

---

## 📊 Output

- **best_tx_cases.csv** contains:
  - `Reflections`: Number of reflections considered
  - `Threshold`: Signal strength threshold (dBm)
  - `Best_Tx_Set`: Optimal transmitter indices
  - `Coverage`: Number of receivers covered

- **3D Visualization**:
  - Axes: Threshold (dBm), Coverage, Tx Set ID
  - Color-coded by number of reflections

---

## 📌 Notes

- The optimisation is exhaustive (brute-force), hence runtime increases with number of Tx.
- Reflection and threshold combinations explored: 7 reflection levels × 9 threshold values = 63 cases
- Future upgrades can include Genetic Algorithms or Swarm Intelligence for faster optimisation.

---

## 🧑‍💻 Authors

- **Team Bytewise Boosters**
- Contributors: Angel Gupta, Dhruv Narang, Khushi Gupta, Alvia Fatima
- Affiliation: SRM University, Sonipat

---

## 📎 Reference

This project is inspired by 5G mid-band deployment studies and signal propagation in smart urban environments. For detailed methodology and visuals, refer to the included PDF:  
**`Bytewise-Boosters(SatOptiNet).pdf`**

---
