% Clear existing figures and variables
close all

% Setting the path for input data
thpath_ori = ''; 
cd(thpath_ori);

% Load all text files matching the pattern '*12pN.txt'
raw_ori = dir(['*12pN.txt']);
S_ori = struct(raw_ori);
num_file_ori = length(S_ori);

% Initialize variables for storing results
dz_ori = cell(1, num_file_ori);
binx = -100:299; % Bin range from -100 to 299
binxLength = length(binx);
colorScaleMin = 0.5;
colorScaleMax = 1.3;
range = 5; % Range for calculations
results = struct();

% Load data from each file into 'dz_ori'
for i = 1:num_file_ori
    dz_ori{i} = load(S_ori(i).name);
end

% Process each pair of data files
for a = 1:num_file_ori
    for b = a+1:num_file_ori  % Avoid redundant combinations
        % Initialize heatmap matrix
        heatmapMatrix = zeros(binxLength, binxLength);

        % Calculate the heatmap matrix
        for i = 1:binxLength
            % Determine the valid range of indices for multiplication
            jStart = max(1, i - range);
            jEnd = min(binxLength, i + range);

            for j = jStart:jEnd
                if j <= length(dz_ori{b}) % Check bounds for second dataset
                    heatmapMatrix(i, j) = sqrt(dz_ori{a}(i, 1) * dz_ori{b}(j, 1));
                end
            end
        end

        % Calculate mean values in a diamond shape
        meanValues = zeros(1, binxLength);
        for i = 1:binxLength
            diamondSum = 0;
            count = 0; % Count elements for averaging
            for j = max(1, i - range):min(binxLength, i + range)
                horizontalStart = max(1, i - (range - abs(j - i)));
                horizontalEnd = min(binxLength, i + (range - abs(j - i)));

                % Sum values and count elements
                diamondSum = diamondSum + sum(heatmapMatrix(j, horizontalStart:horizontalEnd));
                count = count + (horizontalEnd - horizontalStart + 1);
            end

            % Calculate mean value
            if count ~= 0
                meanValues(i) = diamondSum / count;
            end
        end

        % Extract file names for labeling
        nameA = extractBefore(S_ori(a).name, '12pN');

        nameB = extractBefore(S_ori(b).name, '12pN');

        % Create a unique identifier for each combination
        numb_i = sprintf('combination_%d_%d', a, b);
        identifier = sprintf('combination_%s_%s', nameA, nameB);

        % Store results in the structure
        results.(numb_i).heatmapMatrix = heatmapMatrix;
        results.(numb_i).meanValues = meanValues; 
        results.(numb_i).identifier = identifier;

        % Plot heatmaps and bar charts
        figure;

        % Plot bar chart for dataset A
        subplot('Position', [0.7, 0.1, 0.2, 0.8]);
        barh(binx, dz_ori{a}, 1, 'EdgeColor', [0.50, 0.50, 0.50], 'FaceAlpha', 0.5);
        xlabel(nameA);
        hold on

        % Plot bar chart for dataset B
        subplot('Position', [0.1, 0.1, 0.2, 0.8]);
        barh(binx, dz_ori{b}, 1, 'EdgeColor', [0.50, 0.50, 0.50], 'FaceAlpha', 0.5);
        xlabel(nameB);
        set(gca, 'XDir', 'reverse');
        hold on

        % Plot heatmap for mean values
        subplot('Position', [0.45, 0.1, 0.1, 0.8]);
        imagesc(flip(meanValues'), [colorScaleMin, colorScaleMax]);
        colormap(jet); % Choose a colormap
        set(gca, 'xtick', []);
        set(gca, 'ytick', []);
        hold on

        % Plot mean values
        figure; 
        plot(binx, meanValues);
        xlim([-50 300]);
        ylim([0 1.4]);
    end
end
