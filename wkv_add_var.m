function [wkv, index] = wkv_add_var(wkv, name, unit, values)
%WKV_ADD_VAR Adds a variable to a WKV variables list.

% Check that the size of the given values array is correct.
if ~isvector(values)
    error('The values argument should be a vector.');
end

if ~isempty(wkv) && (length(values) ~= length(wkv(1).values))
    error(['The length of the values argument should match the length ' ...
           'of the existing variables in the WKV.']);
end

% Add the variable to the WKV, filling all the fields of the structure.
index = length(wkv);
wkv(end+1) = wkv(end);

wkv(index).name = name;
wkv(index).unit = unit;
wkv(index).values = values;
wkv(index).type = class(values);

end
