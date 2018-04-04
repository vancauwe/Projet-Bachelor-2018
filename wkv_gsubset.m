function subwkv = wkv_gsubset(wkv, plotIndex)
%WKV_GSUBSET Interactively extracts a subset of the given WKV dataset.
%   plotIndex is the index of the variable to plot, in order to select the
%   area to make a subset from. Once the plot window is displayed, click at
%   the beginning, then the end of the desired region. The vertical
%   position of the clicks is ignored.

%% Get the selection from the user.

% Find the timestamp index.
timeIndex = find(strcmp({wkv.name}, 'timestamp'), 1);

if isempty(timeIndex)
    error('The timestamp could not be found.');
end

% Discard all the data before a change of time (dt > 1 min), otherwise a
% lot of manual zooming will be required to see the relevant data.
setTimeInd = find(abs(diff(wkv(timeIndex).values)) > duration(0, 1, 0), ...
                  1, 'last');

if isempty(setTimeInd)
    startIndex = 1;
else
    startIndex = setTimeInd+1;
end

% Plot and get the two clicks locations.
hFig = figure;
plot(wkv(end).values(startIndex:end), ...
     wkv(plotIndex).values(startIndex:end));
xlabel('Time [us]');

[t_crop, ~] = ginput(2);
close(hFig);

% Get the corresponding begin/end indices.
beginIndex = 1;
endIndex = length(wkv(end).values);

if t_crop(1) > t_crop(2)
    tmp = t_crop(1);
    t_crop(1) = t_crop(2);
    t_crop(2) = tmp;
end

for i=1:length(wkv(end).values)
    if wkv(end).values(i) >= t_crop(1)
        beginIndex = i;
        break;
    end
end

for i=beginIndex:length(wkv(end).values)
    if wkv(end).values(i) >= t_crop(2)
        endIndex = i;
        break;
    end
end

range = beginIndex:endIndex;

%% Extract the dataset.
subwkv = wkv_subset(wkv, range);

end

