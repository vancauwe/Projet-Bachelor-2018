function [starts_num, ends_num, RightS_num, LeftS_num, endMode_num,...
    toPlotTimes, ind_PlotTimes, ind_RightS, ind_LeftS,...
    left,right, colors, startCadTime, endCadTime, modes] = processing(textfile, wkv)

%PROCESSING 
%   The function calls:
%   1. extraction (get text file entries and info)
%   2. matTimeConversion (convert text file entries into wkv timestamps)
%   3. getTimeDoubles (from wkv timestamps get the time doubles
%   corresponding)

%   Through the process, it outputs for further analysis:
%   - for Mode Button: modes [strings], colors, toPlotTimes and endMode_num [wkv timestamps]
%   - for Step Button: left and right [doubles], LeftS_num and RightS_num [wkv timestamps] 
%   - for Cadence Button: starts_num and ends_num [wkv timestamps] 
%   - for All Button & Av Button (Cycles) : ind_PlotTimes, ind_RightS, ind_LeftS (doubles) 
%   (as it is easier to compare indices than timestamps)

%   Hence the function processing.m is called in the following Callbacks: avbutton,
%   allbutton, mode_button, button, cad_button

%% Extraction must be done once to get all data. First run takes time
%operation of the function getTimeDoubles taking time is to process 
%the timestamps dates (wkv(1)) vs. time doubles (wkv(end))

[dates, modes, colors, endMode, left,right,startCadTime,endCadTime, LeftS,RightS]=extraction(textfile);
            
%% Calling matTimeConversion on extracted values -IF values have been extracted
if(~(isempty(endMode))) 
    k=1;
    while(k<=length(endMode))
        converted_endMode{1,k}=matTimeConversion(endMode{1,k});
        k=k+1;
    end
else
    converted_endMode={};
end

if(~isempty(dates))
    %convert to a wkv timestamp format
    i=1; 
    while(i<=length(dates))
        converted_dates{1,i}=matTimeConversion(dates{1,i});
        i=i+1;
    end
else
    converted_dates={};
end

if(~isempty(LeftS))
    k=1;
    while(k<=length(LeftS))
        convertedLeftS{1,k}=matTimeConversion(LeftS{1,k});
        k=k+1;
    end
else
    convertedLeftS={};
end

if(~isempty(RightS))
    k=1;
    while(k<=length(RightS))
        convertedRightS{1,k}=matTimeConversion(RightS{1,k});
        k=k+1;
    end
else
    convertedRightS={};
end

if(~(isequal(startCadTime, ' ')) && ~(isequal(endCadTime, ' ')))
    k=1;
    while(k<=length(startCadTime))
        convertedStarts{1,k}=matTimeConversion(startCadTime{1,k});
        convertedEnds{1,k}=matTimeConversion(endCadTime{1,k});
        k=k+1;
    end
else
    convertedStarts={};
    convertedEnds={};
end
%% Get the time doubles associated to the mat wkv timestamps
%this is the operation taking time in the program. 
[starts_num, ends_num, RightS_num, LeftS_num, endMode_num,...
    toPlotTimes, ind_PlotTimes, ind_RightS, ind_LeftS]=getTimeDoubles(wkv,convertedStarts,convertedEnds, convertedRightS, convertedLeftS,converted_endMode, converted_dates);

       
end