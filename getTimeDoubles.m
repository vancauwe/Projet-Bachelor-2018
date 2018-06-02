function [time_doubles1,time_doubles2,time_doubles3, time_doubles4, time_doubles5,...
    time_doubles6, saved6, saved3,saved4]= getTimeDoubles(wkv, convertedDates1, convertedDates2,...
                                                          convertedDates3, convertedDates4,convertedDates5,...
                                                          convertedDates6 )

%GETTIMEDOUBLES 
%   Using the wkv datetimes (wkv timestamps, first data row) given as input to the function, 
%   the function outputs the corresponding time doubles (wkv last row of data)

%   This function is time consuming from the process of iterating through
%   very abundant data. For a sample of roughly 400 seconds of experience run time,
%   the function needs 2 min 30 s to complete.


%allow the user to see that the process is occuring through the Matlab
%Command Window if the user so desires.
disp('processing Time doubles');

%% wkv get for timestamp values
[values,~]=wkv_get(wkv, 'timestamp');

%% Initializing variables
indexTime=1 ; k1=1; k2=1; k3=1; k4=1; k5=1; k6=1;
saved1=[]; saved2=[]; saved3=[]; saved4=[]; saved5=[]; saved6=[];

%% Obtaining the indices of the input wkv timestamps

k=[k1,k2,k3,k4,k5,k6];
lengths=[length(convertedDates1), length(convertedDates2), length(convertedDates3), length(convertedDates4), length(convertedDates5), length(convertedDates6)];

while(indexTime<=length(values))
    %note that the values are datetimes and not strings from the log so
    %necessary to convert them to compare to the string date extracted
    %from text

    if(k1<=length(convertedDates1))
       
        if(strcmp(datestr( values(indexTime) ), convertedDates1{1,k1}))
            saved1=[saved1,indexTime];
            k1=k1+1;
        end
    end
    
    if(k2<=length(convertedDates2))
       
        if(strcmp(datestr( values(indexTime) ), convertedDates2{1,k2}))
            saved2=[saved2,indexTime];
            k2=k2+1;
        end
    end
    
    if(k3<=length(convertedDates3))
       
        if(strcmp(datestr( values(indexTime) ), convertedDates3{1,k3}))
            saved3=[saved3,indexTime];
            k3=k3+1;
        end
    end
    
    
    if(k4<=length(convertedDates4))
       
        if(strcmp(datestr( values(indexTime) ), convertedDates4{1,k4}))
            saved4=[saved4,indexTime];
            k4=k4+1;
        end
    end
    
    if(k5<=length(convertedDates5))
       
        if(strcmp(datestr( values(indexTime) ), convertedDates5{1,k5}))
            saved5=[saved5,indexTime];
            k5=k5+1;
        end
    end
    
    if(k6<=length(convertedDates6))
       
        if(strcmp(datestr( values(indexTime) ), convertedDates6{1,k6}))
            saved6=[saved6,indexTime];
            k6=k6+1;
        end
    end
        
    %if all indexes for the 3 vectors of convertedDates have been found    
    if(k(1)>lengths(1) && k(2)>lengths(2) && k(3)>lengths(3) && k(4)>lengths(4) && k(5)>lengths(5) && k(6)>lengths(6))
        break;
    end
   
    indexTime=indexTime+1;  
end

%% Wkv get for time doubles
[timeDoubles,~]=wkv_get(wkv, 'timestamp_num');

%% Initializing variables
time_doubles1=[]; time_doubles2=[]; time_doubles3=[]; time_doubles4=[]; time_doubles5=[]; time_doubles6=[];

%% From indices, save corresponding time doubles
if(~isempty(convertedDates1))
    ind=1;
    while(ind<=length(saved1))
        time_doubles1=[time_doubles1,timeDoubles(saved1(ind))];
        ind=ind+1;
    end
end
    
if(~isempty(convertedDates2))
    ind=1;
    while(ind<=length(saved2))
        time_doubles2=[time_doubles2,timeDoubles(saved2(ind))];
        ind=ind+1;
    end
end
if(~isempty(convertedDates3))
    ind=1;
    while(ind<=length(saved3))
        time_doubles3=[time_doubles3,timeDoubles(saved3(ind))];
        ind=ind+1;
    end
end
if(~isempty(convertedDates4))
    ind=1;
    while(ind<=length(saved4))
        time_doubles4=[time_doubles4,timeDoubles(saved4(ind))];
        ind=ind+1;
    end
end

if(~isempty(convertedDates5))
    ind=1;
    while(ind<=length(saved5))
        time_doubles5=[time_doubles5,timeDoubles(saved5(ind))];
        ind=ind+1;
    end
end

if(~isempty(convertedDates6))
    ind=1;
    while(ind<=length(saved6))
        time_doubles6=[time_doubles6,timeDoubles(saved6(ind))];
        ind=ind+1;
    end
end

end