clc; clear; close all;
tic;

%% 1. Load OSM Map (Ground Terrain)
viewer = siteviewer("Buildings", "map.osm", "Basemap", "topographic");

%% 2. Define Satellite (TX) and Ground Node (RX) Region
lat_min = 28.628504;
lat_max = 28.632676;
lon_min = 77.220486;
lon_max = 77.227723;

%% 3. Define Number of Satellites (TX) and Ground Repeaters (RX)
num_sat = 10;    % Number of satellites
num_nodes = 40;  % Number of ground repeaters

% Satellite positions (random over the region, high altitude)
sat_lat = lat_min + (lat_max - lat_min) * rand(num_sat, 1);
sat_lon = lon_min + (lon_max - lon_min) * rand(num_sat, 1);
sat_alt = 550e3 * ones(1, num_sat);  % Row vector, all satellites at 550 km altitude

% Ground node positions in grid
grid_rows = ceil(sqrt(num_nodes));
grid_cols = ceil(num_nodes / grid_rows);
lat_grid = linspace(lat_min, lat_max, grid_rows);
lon_grid = linspace(lon_min, lon_max, grid_cols);
[lat_mesh, lon_mesh] = meshgrid(lat_grid, lon_grid);
node_lat = reshape(lat_mesh(1:num_nodes), num_nodes, 1);
node_lon = reshape(lon_mesh(1:num_nodes), num_nodes, 1);

%% 4. Define Sites for Satellites and Ground Repeaters
satSites = txsite("Latitude", sat_lat, ...
                  "Longitude", sat_lon, ...
                  "AntennaHeight", sat_alt, ...
                  "TransmitterFrequency", 2.4e9, ...
                  "TransmitterPower", 50, ...  % in dBm (optional boost)
                  "Name", "Sat" + (1:num_sat));


nodeSites = rxsite("Latitude", node_lat, "Longitude", node_lon, ...
    "AntennaHeight", 10, ...
    "Name", "Node"+(1:num_nodes));

show(satSites); show(nodeSites);

%% 5. Simulation Parameters
threshold_values = -40:-10:-120;
num_reflections = 0:3;  % Limited due to satellite line-of-sight

% Store best outcomes
best_cases = table();

for maxReflections = num_reflections
    fprintf("\nMaxNumReflections = %d\n", maxReflections);
    
    rtpm = propagationModel("freespace");
    ss = sigstrength(nodeSites, satSites, rtpm);

    
    for threshold = threshold_values
        fprintf("Threshold = %d dBm\n", threshold);
        binary_matrix = ss > threshold;
        
        best_tx_set = [];
        best_coverage = 0;
        num_combinations = 2^num_sat - 1;
        
        for i = 1:num_combinations
            selected_tx = find(de2bi(i, num_sat));
            sub_matrix = binary_matrix(:, selected_tx);
            coverage = sum(any(sub_matrix, 2));
            
            if coverage > best_coverage || ...
               (coverage == best_coverage && length(selected_tx) < length(best_tx_set))
                best_coverage = coverage;
                best_tx_set = selected_tx;
            end
        end
        
        best_cases = [best_cases; table(maxReflections, threshold, ...
            {best_tx_set}, best_coverage, ...
            'VariableNames', {'Reflections', 'Threshold', 'Best_Sat_Set', 'Coverage'})];
    end
end

disp('Best Satellite Combinations per Scenario:');
disp(best_cases);

writetable(best_cases, 'best_satellite_cases.csv');
disp('Results saved successfully.');

toc;