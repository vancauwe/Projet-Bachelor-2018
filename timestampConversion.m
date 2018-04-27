function [txt_equiv, day, hour, min, secs] = timestampConversion(mat_time)
mat_time=datestr(mat_time); %incoming data is a datetime object not string so conversion is necessary
str_elements = strsplit(mat_time,' '); %seperate date from time

%DATE
date=str_elements{1,1};
%convert month to number equivalent
m=month(str_elements{1,1});
if(length(num2str(m))==1) 
    m=strcat('0',num2str(m)); 
end
dcompo=strsplit(date,'-'); %split date up in day/month/year
day=dcompo{1,1}; year=dcompo{1,3};
date_reorg=strcat(year,'-',num2str(m),'-',day);

%TIME
time=str_elements{1,2};
tcompo=strsplit(time,':'); %split time up in hour/min/sec
hour=tcompo{1,1}; min=tcompo{1,2}; secs=tcompo{1,3};
time_reorg=strcat(hour,'_',min,'_',secs);

%Full
txt_equiv=strcat('[',date_reorg,'_',time_reorg,']');

end