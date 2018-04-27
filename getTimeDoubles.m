function [time_doubles]=getTimeDoubles(wkv, convertedDates)
% Calling: time_doubles=getTimeDoubles(handles.wkv,convertedDates)

disp('processing Time doubles');

%get corresponding time doubles 
%get indexes of timestamps corresponding to those where entering a mode
[values,~]=wkv_get(wkv, 'timestamp');

%modes: for testing indexTime for log3 can be 1170000
indexTime=1 ; k=1; saved=[];
while(indexTime<=length(values))
    %note that the values are datetimes and not strings from the log so
    %necessary to convert them to compare to the string date extracted
    %from text

    if(k<=length(convertedDates))
       
        if(strcmp(datestr( values(indexTime) ), convertedDates{1,k}))
            saved=[saved,indexTime];
            k=k+1;
        end
    else
        break;
    end
    indexTime=indexTime+1;  
end

[timeDoubles,~]=wkv_get(wkv, 'timestamp_num');

ind=1; time_doubles=[];
while(ind<=length(saved))
    time_doubles=[time_doubles,timeDoubles(saved(ind))];
    ind=ind+1;
end
end