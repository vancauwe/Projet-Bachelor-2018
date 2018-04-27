function [passed] = date_skipped_check(secs, min, h, d,wanted_secs,wanted_min, wanted_hour, wanted_day)

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