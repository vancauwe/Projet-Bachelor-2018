function wkv_plot_mean_std(stackedVectors, times, plotAllCurves)
%WKV_PLOT_MEAN_STD Plots mean and standard deviation of a set of vectors.
%   stackedVectors is a matrix made of horizontal vectors, stacked
%   vertically.

%% Constants.
FILL_COLOR = [1 1 1] * 0.8; % Light gray.

%% Check the function arguments.
if ~isvector(times)
    error('times should be a vector.');
end

if size(stackedVectors, 2) ~= length(times)
    error(['times should have the same length as the number of columns' ...
           'of stackedVectors.']);
end

if ~exist('plotAllCurves', 'var')
    plotAllCurves = 0;
end

nSeries = size(stackedVectors, 1);

%% Compute the mean and std curves.
m = mean(stackedVectors, 1);
standardDeviation = std(stackedVectors, 1);
mstdp = m + standardDeviation;
mstdm = m - standardDeviation;

%% Plot.

% Mean and standard deviation envelope.
fill([times fliplr(times)], [mstdm fliplr(mstdp)], ...
     FILL_COLOR, 'EdgeColor','None');
hold on;
plot(times, m, 'black', 'LineWidth', 2);

% All the curves.
if plotAllCurves
    plot(times, stackedVectors);
end

end

