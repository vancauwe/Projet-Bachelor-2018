function wkv_plot(wkv, varsIndices, varargin)
%WKV_PLOT Plots several variables over time, from a WKV structure.
% wkv_plot(wkv, varsIndices) plots the variables designated by the indices
% varsIndices.
% wkv_plot(___, 'LineStyle', lineStyle) sets the line style (see the plot()
% documentation for more information).
% wkv_plot(___, 'LineWidth', lineWidth) sets the line width (see the plot()
% documentation for more information).
% wkv_plot(___, 'MessagesFile', messagesFile) adds tags on the figure (a
% vertical line and a label) for each message starting by "#" in the given
% file.

%% Interpret the optional arguments.
argParser = inputParser;
addOptional(argParser, 'LineStyle', '-');
addOptional(argParser, 'LineWidth', 0.5);
addOptional(argParser, 'MessagesFile', '');
parse(argParser, varargin{:});

lineStyle = argParser.Results.LineStyle;
lineWidth = argParser.Results.LineWidth;
messagesFile = argParser.Results.MessagesFile;

%% Plot the variables values.

% Find the timestamp index.
timeIndex = find(strcmp({wkv.name}, 'timestamp'), 1);

if isempty(timeIndex)
    error('The timestamp could not be found.');
end

% Discard all the data before a change of time (dt > 1 min), otherwise a
% lot of manual zooming will be required to see the relevant data.
setTimeInd = find(abs(diff(wkv(timeIndex).values)) > duration(0, 1, 0), ...
                  1, 'last');

if ~isempty(setTimeInd)
    for i=1:length(wkv)
        wkv(i).values(1:setTimeInd) = [];
    end
end

% Plot.
varsMat = cell2mat({wkv(varsIndices).values}');

plot(wkv(timeIndex).values, varsMat, ...
     'LineStyle', lineStyle, 'LineWidth', lineWidth);
xtickformat('hh:mm:ss.SSS');

%% Generate the legend.
legendLabels = cell(1, length(varsIndices));
for i=1:length(varsIndices)
    varIndex = varsIndices(i);
    legendLabels{i} = [wkv(varIndex).name ' [' wkv(varIndex).unit ']'];
end

hLegend = legend(legendLabels);
hLegend.Interpreter = 'none';

%% Show the user tags.
if exist(messagesFile, 'file')
    allDataMin = min(varsMat(:));
    allDataMax = max(varsMat(:));
    
    tags = extract_messages(wkv, messagesFile, 1);
    
    hold on;
    
    for tag = tags
        text(tag.time, allDataMax, tag.text, 'Rotation', 45);
        h = plot([tag.time tag.time], [allDataMin allDataMax], 'k--');
        h.Annotation.LegendInformation.IconDisplayStyle = 'off';
    end
    
    ylim([allDataMin allDataMax*1.1]);
    
    hold off;
end

end
