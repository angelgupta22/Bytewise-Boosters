clc; clear; close all;

tic;
%% 1. Load OSM Map in Site Viewer
viewer = siteviewer("Buildings", "map.osm", "Basemap", "topographic");

%% 2. Define Bounding Box for Tx & Rx Selection
lat_min = 28.628504;  % Lower latitude
lat_max = 28.632676;  % Upper latitude
lon_min = 77.220486;  % Left longitude
lon_max = 77.227723;  % Right longitude

%% 3. Define n Tx and m Rx Locations (Rx in Grid Formation)
num_tx = 16;   % Number of Tx locations
num_rx = 20;  % Number of Rx locations (in a grid)

%rng('shuffle'); % Randomization seed

% Random Tx locations
%tx_lat = lat_min + (lat_max - lat_min) * rand(num_tx, 1);
%tx_lon = lon_min + (lon_max - lon_min) * rand(num_tx, 1);
%% try 
grid_size_tx = sqrt(num_tx);
lat_vals_tx = linspace(lat_min, lat_max, grid_size_tx);
lon_vals_tx = linspace(lon_min, lon_max, grid_size_tx);
[lat_mesh_tx, lon_mesh_tx] = meshgrid(lat_vals_tx, lon_vals_tx);
tx_lat = reshape(lat_mesh_tx, [], 1);
tx_lon = reshape(lon_mesh_tx, [], 1);
tx_matrix = [tx_lat, tx_lon];

% Create a grid of Rx locations
grid_rows = ceil(sqrt(num_rx));  % Define rows for the grid
grid_cols = ceil(num_rx / grid_rows);  % Define columns for the grid

lat_grid = linspace(lat_min, lat_max, grid_rows);
lon_grid = linspace(lon_min, lon_max, grid_cols);

[lat_mesh, lon_mesh] = meshgrid(lat_grid, lon_grid);
rx_lat = reshape(lat_mesh(1:num_rx), num_rx, 1);
rx_lon = reshape(lon_mesh(1:num_rx), num_rx, 1);

toc;
%% 4. Plot Tx & Rx on the OSM Map
txSites = txsite("Latitude", tx_lat, "Longitude", tx_lon, ...
    "AntennaHeight", 10, "TransmitterFrequency", 2.4e9, "Name", "Tx"+ (1:num_tx));

rxSites = rxsite("Latitude", rx_lat, "Longitude", rx_lon, ...
    "AntennaHeight", 1.5, "Name", "Rx"+ (1:num_rx));

show(txSites);
show(rxSites);

% Define threshold range
threshold_values = -50:-10:-100;
num_reflections = 0:5;

% Initialize storage for best cases
best_cases = table();

for maxReflections = num_reflections
    fprintf("\nEvaluating MaxNumReflections = %d\n", maxReflections);
    
    % Define propagation model
    rtpm = propagationModel("raytracing", ...
        Method="sbr", ...
        MaxNumReflections=maxReflections, ...  
        BuildingsMaterial="concrete", ...
        TerrainMaterial="concrete");
    
    % Compute signal strength
    raytrace(txSites, rxSites, rtpm);
    ss = sigstrength(rxSites, txSites, rtpm);
    
    % Iterate over each threshold
    for threshold = threshold_values
        fprintf("\nThreshold = %d dBm\n", threshold);
        
        % Convert to binary matrix (1 if above threshold, 0 otherwise)
        binary_matrix = ss > threshold;
        
        % Print binary matrix for debugging
        disp("Binary Matrix:");
        disp(binary_matrix);
        
        % Brute Force Search for Best Tx Combination
        best_tx_set = [];
        best_coverage = 0;
        num_combinations = 2^num_tx - 1;
        
        for i = 1:num_combinations
            selected_tx = find(de2bi(i, num_tx));
            sub_binary_matrix = binary_matrix(:, selected_tx);
            coverage = sum(any(sub_binary_matrix, 2));
            
            if coverage > best_coverage || (coverage == best_coverage && length(selected_tx) < length(best_tx_set))
                best_coverage = coverage;
                best_tx_set = selected_tx;
            end
        end
        
        % Store best case for this reflection-threshold pair
        best_cases = [best_cases; table(maxReflections, threshold, {best_tx_set}, best_coverage, 'VariableNames', {'Reflections', 'Threshold', 'Best_Tx_Set', 'Coverage'})];
    end
end

disp('Best Tx cases for each of the 25 scenarios:');
disp(best_cases);

% Save results to a CSV file
writetable(best_cases, 'best_tx_cases.csv');
disp('Best Tx cases saved successfully.');

toc;
% Extract unique reflection levels
reflection_levels = unique(best_cases.Reflections);

figure;
hold on;
grid on;
view(45, 30);  % Adjust view angle
title('Coverage vs Threshold vs Tx Set (per Reflection)');
xlabel('Threshold (dBm)');
ylabel('Coverage');
zlabel('Tx Set ID');

% Convert Tx sets to string for uniqueness, then map to numeric index
tx_sets_str = cellfun(@(x) mat2str(sort(x)), best_cases.Best_Tx_Set, 'UniformOutput', false);
[unique_tx_sets, ~, tx_set_ids] = unique(tx_sets_str);

colors = lines(length(reflection_levels));  % Distinct colors for each reflection level

