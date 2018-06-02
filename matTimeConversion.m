function [mat_equiv] = matTimeConversion(txt_time)


%MATTIMECONVERSION 
%   converts a text file date format into a datetime value as present in the wkv data.
%   input date format (from txt file): [2017-09-25_06_42_24]
%   output date (from wkv): 25-Sep-2017 06:42:24 

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

%Total
mat_equiv=[date ' ' time];


end