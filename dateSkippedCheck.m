function [passed] = dateSkippedCheck(secs, min, h, d,wanted_secs,wanted_min, wanted_hour, wanted_day)

%DATESKIPPEDCHECKED 
%   Essential function to obtain the cropped text file associated to the
%   cropped wkv data.
%   Solves the difference in precision between wkv timestamps and text file
%   timestamps.
%   The text file timestamps/dates are less numerous than the wkv
%   timestamps. 
%   In the cropping of the text file to match the cropped wkv data, it is
%   necessary to check that the text file date being compared to the first
%   and last wkv timestamps is not "greater" time-wise. 

%   Example:
%   if our lower cropping limit date is (from wkv): 25-Sep-2017 06:42:24
%   and -as we iterate through the text file to cut it likewise-
%   we reach a text file entry such as: [2017-09-25_06_42_34]
%   then this entry is relevant to the cropped wkv data and we must start
%   saving from this entry onwards to make the cropped text file.

%   The boolean "passed" allows to make sure the "skipping phenomenon" does
%   not occur.

%number conversion of all the date data
secs=str2num(secs); min=str2num(min); h=str2num(h); d=str2num(d); 
wanted_secs=str2num(wanted_secs); wanted_min=str2num(wanted_min); wanted_hour=str2num(wanted_hour); 
wanted_day=str2num(wanted_day); 

if( (secs>wanted_secs) && (isequal(min,wanted_min)) && (isequal(h,wanted_hour)) && (isequal(d,wanted_day)) )
    passed=1;
end
        
if( (min>wanted_min) && (isequal(h,wanted_hour)) && (isequal(d,wanted_day)) )
    passed=1;
end


if( (h>wanted_hour) && (isequal(d,wanted_day)) )
    passed=1;
end

if(d>wanted_day)
    passed=1; 
end

if(~(exist('passed', 'var')))
    passed=0;
end
end