function messages = extract_messages(wkv, messagesFilename, tagsOnly)
%EXTRACT_MESSAGES Gets the messages of an "*_info.txt" file into structs.
% This function reads the file designated by messagesFilename, and returns
% an array of struct, one per message of the logfile, with the following
% fields:
% -text: the text content of the message.
% -time: the timestamp of the message, as a datetime object.
% -index: the sample index of the wkv object, corresponding to the time of
% the message.
%
% If the argument tagsOnly is set to 1, then only the messages starting
% with the "#" character will be included in the output array.

if ~exist('tagsOnly', 'var')
    tagsOnly = 0;
end

messages = [];

fid = fopen(messagesFilename);

if fid == -1
    error('Could not open the specified messages file.');
else
    try
        while ~feof(fid)
            line = fgetl(fid);
            
            if tagsOnly
                messageStartIndex = find(line == '#', 1);
            else
                messageStartIndex = find(line == ']', 1) + 1;
            end

            if ~isempty(messageStartIndex) && length(line) > messageStartIndex
                m.text = line(messageStartIndex+1:end);
                m.time = datetime(line(1:20), 'InputFormat', '[yyyy-MM-dd_HH_mm_ss');
                
                if ~isempty(wkv)
                    m.index = find_nearest(wkv_get(wkv, 'timestamp'), m.time);
                end

                messages = [messages m]; %#ok<AGROW>
            end
        end
        fclose(fid);
    catch
        fclose(fid);
        error('Error while reading the messages file.');
    end
end

end
