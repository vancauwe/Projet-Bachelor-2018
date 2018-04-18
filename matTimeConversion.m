function [mat_equiv] = matTimeConversion(txt_time)
 %incoming data is a datetime object not string so conversion is necessary
 %we have '[2017-10-04_08_29_35]'
 %we want 25-Sep-2017 06:42:31
str_elements = strsplit(txt_time,'_'); %seperate date from time
%gives [2017-10-04 08 29 35

%TIME
h=str_elements{1,2};
min=str_elements{1,3};
secs=str_elements{1,4}(1:end-1);
time=strcat(h,':',min,':', secs);

%DATE
d=str_elements{1,1}(2:end);
date = datestr( datetime(d,'InputFormat','yyyy-MM-dd') );

%date_elements = strsplit(date,'-');
%day=date_elements{1,3};
%m=date_elements{1,2}; mon=month(m, 'shortname'); 
%y=date_elements{1,1};
%date=strcat(day,'-',mon,'-',y);

%Total
mat_equiv=[date ' ' time];


end