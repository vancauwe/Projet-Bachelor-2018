function [starts_num, ends_num, RightS_num, LeftS_num, endMode_num,...
    toPlotTimes, ind_PlotTimes, ind_RightS, ind_LeftS,...
    left,right, colors, startCadTime, endCadTime, modes]=processing(textfile, wkv)
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