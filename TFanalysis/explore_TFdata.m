load('V:\Methadone_eMID\pooled_data\nsf_tfd_8trials.mat')
a=squeeze(mean(cat(4, FB11_case_post_data, FB11_case_pre_data, FB11_control_data),4));

a=squeeze(mean(cat(4, FB11_case_post_data, FB11_case_pre_data, FB11_control_data),4))-squeeze(mean(cat(4, FB10_case_post_data, FB10_case_pre_data, FB10_control_data),4));

a=squeeze(mean(cat(4, FB11_case_post_data, FB11_case_pre_data, FB11_control_data),4))-squeeze(mean(cat(4, FB10_case_post_data, FB10_case_pre_data, FB10_control_data),4));


a=squeeze(mean(cat(4, FB11_case_post_data, FB11_case_pre_data, FB11_control_data),4))-squeeze(mean(cat(4, FB21_case_post_data, FB21_case_pre_data, FB21_control_data),4));

a=squeeze(mean(cat(4, FB11_case_post_data, FB11_case_pre_data, FB11_control_data),4))-squeeze(mean(cat(4, FB31_case_post_data, FB31_case_pre_data, FB31_control_data),4));

a=squeeze(mean(cat(4, FB21_case_post_data, FB21_case_pre_data, FB21_control_data),4))-squeeze(mean(cat(4, FB20_case_post_data, FB20_case_pre_data, FB20_control_data),4));


FL = [12, 18, 19, 22, 23, 23, 26, 27];
% Define electrode indices for the frontal right region
FR = [2, 3, 4, 5, 9, 10, 123, 124];
% Define electrode indices for the frontal midline region
FM = [15, 16];
% Combine frontal regions
FA = [FL, FR, FM];


timeRangeAnalysisMS=[0, 1000]
timeRangeOrignalMS=[-1000,2000]
samplingRate=250
startTimeIdx = round((timeRangeAnalysisMS(1) - timeRangeOrignalMS(1)) * samplingRate / 1000) + 1;
midTimeIdx = round((0 - timeRangeOrignalMS(1)) * samplingRate / 1000) + 1;
endTimeIdx = round((timeRangeAnalysisMS(2) - timeRangeOrignalMS(1)) * samplingRate / 1000) + 1;



b=squeeze(mean(a(FA,:,:),1));
% Assume b is your data and you have defined startTimeIdx and endTimeIdx
data = b(startTimeIdx:endTimeIdx, 1:end)';

% Define interpolation factors for x and y dimensions
xFactor = 10; % Interpolate to double the resolution in x
yFactor = 10; % Interpolate to double the resolution in y

% Generate original grid vectors
[x, y] = meshgrid(1:size(data, 2), 1:size(data, 1));

% Generate finer grid vectors
[xq, yq] = meshgrid(linspace(1, size(data, 2), size(data, 2) * xFactor), ...
                    linspace(1, size(data, 1), size(data, 1) * yFactor));

% Interpolate data onto the finer grid
dataInterp = interp2(x, y, data, xq, yq, 'linear'); % You can also try 'cubic' for smoother results


% Define the RGB values for sky blue and firebrick
skyBlue = [115, 215, 255] / 255; % RGB for sky blue
firebrick = [255, 48, 48] / 255; % RGB for firebrick
white = [1, 1, 1]; % RGB for white

% Number of steps in the colormap
numSteps = 50; % Half the number of steps since we have two transitions

% Create a colormap that transitions from sky blue to white and then to firebrick
customCMap = [linspace(skyBlue(1), white(1), numSteps)', linspace(skyBlue(2), white(2), numSteps)', linspace(skyBlue(3), white(3), numSteps)';
              linspace(white(1), firebrick(1), numSteps)', linspace(white(2), firebrick(2), numSteps)', linspace(white(3), firebrick(3), numSteps)'];

% Plot the interpolated (smoother) data
figure
imagesc(timeRangeAnalysisMS, [1, 40], dataInterp );
xlabel('Time (ms)', 'FontSize', 16);
ylabel('Frequency (Hz)', 'FontSize', 16);
set(gca,'YDir','normal')
colormap(customCMap); % Optionally add a color bar to the plot
colorbar
caxis([-1.5 1.5]); % For example, setting the range explicitly

set(gca, 'FontSize', 16);

% Add a colorbar and set its font size
h = colorbar;
set(h, 'FontSize', 16);
% Add a vertical line at x = 0
hold on; % Hold on to the current plot
yLimits = get(gca, 'YLim'); % Get the current y-axis limits
line([0 0], yLimits, 'Color', 'k', 'LineWidth', 1,'LineStyle', '--'); % Draw the line
hold off; % Release the plot hold



% Assuming `FL`, `FR`, etc., are defined as indices or logical arrays that select
% data from the `TFdata` for each region. If not, you will need to define these
% based on your channel layout and the regions they correspond to.
TFdata=a;

regions = {FL, FR, CL, CR, PL, PR, OL, OR}; % Replace these with your actual region indices
regionNames = {'FL', 'FR', 'CL', 'CR', 'PL', 'PR', 'OL', 'OR'};
nRegions = length(regions);

% Create a figure to hold all subplots
figure;

% Precompute the global min and max if you want the same color scale for all subplots
globalMin = min(TFdata(:));
globalMax = max(TFdata(:));

% Loop through each region and create a subplot
for i = 1:nRegions
    subplot(4, 2, i); % Adjust the grid size as necessary
    
    % Extract data for the current region
    regionData = TFdata(regions{i}, startTimeIdx:endTimeIdx, :, :); % 4D data for the region
    
%     % Perform normalization (assuming `func_BL_norm` is your function from above)
%     normRegionData = func_BL_norm(regionData, baselineRange, samplingRate, timeOffsetMs, normType);
%     
    % Average across channels and trials for plotting
    meanNormRegionData = mean(mean(regionData, 4), 1); % Average over channels and trials
    
    % Squeeze to remove singleton dimensions
    meanNormRegionData = squeeze(meanNormRegionData);
    
    % Plot the data
    data = meanNormRegionData';

    % Define interpolation factors for x and y dimensions
    xFactor = 10; % Interpolate to double the resolution in x
    yFactor = 10; % Interpolate to double the resolution in y
    
    % Generate original grid vectors
    [x, y] = meshgrid(1:size(data, 2), 1:size(data, 1));
    
    % Generate finer grid vectors
    [xq, yq] = meshgrid(linspace(1, size(data, 2), size(data, 2) * xFactor), ...
        linspace(1, size(data, 1), size(data, 1) * yFactor));
    
    % Interpolate data onto the finer grid
    dataInterp = interp2(x, y, data, xq, yq, 'linear'); % You can also try 'cubic' for smoother results

    
    imagesc(timeRangeAnalysisMS, [1, 40],dataInterp );
    xlabel('Time (ms)', 'FontSize', 16);
    ylabel('Frequency (Hz)', 'FontSize', 16);
    set(gca,'YDir','normal')
    colormap(customCMap); % Optionally add a color bar to the plot
    % Set the same color scale for all subplots
    caxis([globalMin, globalMax]);
    title(regionNames{i});
    set(gca, 'FontSize', 16);
    
    
  
    
%     % Optionally, only show colorbar on the last subplot to save space
%     if i == nRegions
%         colorbar;
%     end
    
    % More formatting options here...
end

% Improve subplot layout
% You can use `tight_subplot`, `subtightplot`, or similar functions here if you have them















% Define your time bins and frequency bands
timeBins = [140 180; 180 220; 220 260; 260 300]; % in ms
freqBands = [5 6; 5 10; 8 12; 15 20; 20 30]; % in Hz

% Define the time range for analysis and original time range in ms
timeRangeOriginalMS = [-1000, 2000];
samplingRate = 250; % in Hz

% Preallocate an array to hold start and end indices for each time bin
timeIdx = zeros(size(timeBins, 1), 2);

% Calculate start and end indices for each time bin
for i = 1:size(timeBins, 1)
    startTimeIdx = round((timeBins(i, 1) - timeRangeOriginalMS(1)) * samplingRate / 1000) + 1;
    endTimeIdx = round((timeBins(i, 2) - timeRangeOriginalMS(1)) * samplingRate / 1000) + 1;
    timeIdx(i, :) = [startTimeIdx endTimeIdx];
end

% Define frequencies of interest
freqs = 1:0.5:40;

% Find indices of frequency bands
freqIdx = zeros(size(freqBands, 1), 2);
for i = 1:size(freqBands, 1)
    startFreqIdx = find(freqs >= freqBands(i, 1), 1);
    endFreqIdx = find(freqs <= freqBands(i, 2), 1, 'last');
    freqIdx(i, :) = [startFreqIdx endFreqIdx];
end

% Assuming 'a' is a 3D matrix of size (channels x time points x frequencies)
% Initialize a figure to hold all subplots
figure;

% Loop over each time bin and frequency band and plot topographies
for t = 1:size(timeBins, 1)
    for f = 1:size(freqBands, 1)
        % Extract the data for the current time bin and frequency band
        data2topo = mean(mean(a(:, timeIdx(t, 1):timeIdx(t, 2), freqIdx(f, 1):freqIdx(f, 2)), 3), 2);

        % Create a subplot for each time bin and frequency band
        subplot(size(timeBins, 1), size(freqBands, 1), (t-1)*size(freqBands, 1) + f);

        % Call the topoplot function from EEGLAB (as an example)
        % You will need to replace 'chanlocs' with your actual channel locations variable
        topoplot(data2topo, chanlocs, 'maplimits', 'absmax', 'electrodes', 'off', 'conv', 'on');

        % Add title to each subplot for clarity
        title(sprintf('%.1f-%.1f Hz, %d-%d ms', freqBands(f, 1), freqBands(f, 2), timeBins(t, 1), timeBins(t, 2)));
    end
end

% Optionally, add a grand title or other annotations as needed
suptitle('Topographic Maps per Frequency Band and Time Bin');
colormap(customCMap); % Optionally add a color bar to the plot
% colorbar
% caxis([-1.5 1.5]); % For example, setting the range explicitly
% Adjust layout to prevent subplot overlap
set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]); % Maximize figure to screen size









