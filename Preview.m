function varargout = Preview(varargin)
% PREVIEW MATLAB code for Preview.fig
%    The Preview allows to:
%    - plot wkv variables vs time
%    - plot for a single mode the cycles and cycles'average and variance
%    - from text file extraction, inform on the modes occuring, the number
%    of steps and the cadence per movement zone
%    - import and mark a video so as to synchronize video playing and a
%    marker on the plotted timeline
%    - display the load cells'data on both feet per second
%    - select and crop wkv & text file (irreversible)
%    - save analysis and new files if created
%
%    Preview_OpeningFcn: [line 126]
%    disables certain buttons by default and initializes booleans.
%
%%   Representations
%
%    timeline_button_Callback: [line 236]
%    gets file reference path from Browser. 
%    Interactively asks user to select the wkv if there are multiple ones in the log. 
%    Loads the wkv data and the associated text file.
%    Enables the disabled buttons.
%    
%    variableChoice_Callback: [line 798]
%    from dropdown menu, changes the time or cycles representation
%    depending on the wkv variable selected
%    
%    allbox_Callback: [line 1179]
%    calls effector function wkv_split_cycles_from_txt.m so as to create cycles and plot them
%    
%    avbox_Callback: [line 1289]
%    calls effector function wkv_split_cycles_from_txt.m so as to create
%    cycles. Averages them plots average and variance of the cycles.   
%
%    timebox_Callback: [line 1155]
%    represents data vs time
%
%%   Select
%    selectbutton_Callback: [line 400]
%    through interactive cursor, cuts the wkv data and the text file
%    accordingly. Calls dateSkippedChecked
%%   Analysis Panel 
%
%    mode_button_Callback: [line 939]
%    calls effector function processing.m to display the modes on the
%    Analysis Panel and -only if the representation active is the time representation-
%    plot them with their respective colors on both the analysis axis and the timeline.
%    
%    button_Callback: [line 1488]
%    calls effector function processing.m to display the number of left and right steps on the
%    Analysis Panel and -only if the representation active is the time representation-
%    plot them as their respective symbols on the analysis axis.
%    The symbols mark the END of each step. (i.e. that step was completed)
%
%    cad_Callback: [line 1103]
%    calls effector function processing.m to display the cadence per zone on the
%    Analysis Panel.
%
%%   Load Cells
%    playload_Callback: [line 1722]
%    calls effector function loadProcess.m to average load cell data per
%    second. Represents seperately left and right foot a square
%    corresponding to each load cell zone. 
%
%%   Video
%
%    videoImportbutton_Callback: [line 1393]
%    Imports video and enables the video control buttons
%
%    playbutton_Callback: [line 1435]
%    plays video and -if markers in place and synced- moves the timeline
%    marker along the axis. Updates the scroll position (can be seen once
%    stopped).
%
%    stopbutton_Callback: [line 1541]
%    stops video through a boolean. Enables scroll.
%
%    forwardbutton_Callback: [line 1558]
%    moves video frame one frame forwards and updates timeline marker if
%    markers set and synced. Updates the scroll position.
%
%    backbutton_Callback: [line 1583]
%    moves video frame one frame backwards and updates timeline marker if
%    markers set and synced. Updates the scroll position.
%
%    scroll_Callback: [line 1606]
%    allows to move through video using the scroll below 
%
%%   Markers
%    vidMbutton_Callback: [line 1650]
%    marks the current frame displayed with a yellow small circle (the
%    marker) in the top left corner
%
%    timeMbutton_Callback: [line 1680]
%    Allows user to interactively place the time marker on the timeline if
%    the time representation is currently selected. It is the user's
%    responsibility to place the marker correctly and to ensure that his
%    selection is adapted to playing the timeline marker at the same time as the
%    video.
%
%    syncbutton_Callback: [line 1710]
%    Sets the boolean of sync to True: shows user intent to have timeline
%    marker move along with the video being played.
%
%%   Save & Exit
%    savebutton_Callback: [line 608]
%    if selection has occurred then creates a new .mat file for the subwkv
%    and a new text file with the same ID number.
%    To save the analysis, it makes a text file with the data obtained from mode_button, button and cad_button. 
%    It also calls all relevant Callbacks described above for the different represenations 
%    and saves the GUI state as an image.
%    After saving, Preview closes.
%
%    exitbutton_Callback: [line 1817]
%    deletes Preview GUI
%
%%   Required External Functions and GUI
%    Browser.m / Browser.fig
%    dateSkippedChecked.m / extraction.m /getTimeDoubles.m /
%    loadProcess.m / matTimeConversion.m / processing.m /  
%    timestampConversion.m / wkv_get.m / wkv_split_cycles_from_txt.m 
%    wkv_stack_cycles.m

% Last Modified by GUIDE v2.5 02-Jun-2018 14:47:44
%% Opening Code
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Preview_OpeningFcn, ...
                   'gui_OutputFcn',  @Preview_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Preview is made visible.
function Preview_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Preview (see VARARGIN)

% Choose default command line output for Preview

%% Info from Browser
handles.output = hObject;
handles.h = findobj('Tag','Browser');

%only initialize all other variables if info from browser correctly
%retrieved and not empty
if ~isempty(handles.h)
browserdata = guidata(handles.h);
handles.fileToAnalyse = browserdata.analysis_file;
handles.currentFileList=browserdata.filelist;

%% Variable to indicate if certain important operations have been accomplished
handles.loaded=0;
handles.extraction=0;
handles.selection=0;
handles.all=0;

%% Variable initialization for text treatment
handles.ends_num={}; handles.starts_num={}; handles.toPlotTimes={}; 
handles.LeftS_num={}; handles.RightS_num={}; handles.endMode_num={};
handles.current_operation='none';

%% Variable initialization for video treatment
axis(handles.videoaxes,'off');
handles.user_quit=0;
handles.markedFnum=0;
handles.timemarker=0;
handles.sync=0;
%% Variable initialization for load cell data
axis(handles.leftloadcell,'off');
axis(handles.rightloadcell,'off');
handles.loadindex=1;
handles.cutpersec=0;

%% Button regulation
%for video
set(handles.playbutton, 'Enable', 'off');
set(handles.forwardbutton,'Enable','off');
set(handles.backbutton,'Enable','off');
set(handles.vidMbutton,'Enable','off');
set(handles.timMbutton,'Enable','off');
set(handles.syncbutton, 'Enable', 'off');
set(handles.scroll, 'Enable', 'off');
set(handles.stopbutton,'Enable', 'off');
%for timeline
set(handles.avbox, 'Enable', 'off');
set(handles.allbox, 'Enable', 'off');
set(handles.timebox, 'Enable', 'off');
set(handles.cad_button, 'Enable', 'off');
set(handles.button, 'Enable', 'off');
set(handles.mode_button, 'Enable', 'off');
set(handles.save_button, 'Enable', 'off');
set(handles.select_button, 'Enable', 'off');
set(handles.playload, 'Enable', 'off');
end 

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = Preview_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function Log_timeline_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Log_timeline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in timeline_button.
function timeline_button_Callback(hObject, eventdata, handles)
% hObject    handle to timeline_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% LOADING FILE DATA
try
      %first load the file corresponding to the name handles.fileToAnalyse
      handles.input=load(handles.fileToAnalyse{1});
      handles.original=handles.fileToAnalyse{1};
      
      %variable that allows to know if file has been loaded: so as to not
      %be able to ask for the scroll to change if variable has not been
      %loaded::
      handles.loaded=1; 
      
      %interactive selection of which wkv/log is to be processed if multiple
      %wkvs/logs are present 
      [handles.dim1, ~]= size(handles.input.logs);
      if(handles.dim1~=1)
      
          prompt={'Enter the Log number of the session'};
          dlg_title= 'Log Choice for Analysis';
          num_lines=1;
          answer=inputdlg(prompt,dlg_title,num_lines);

          num_answer=str2num(answer{1});

          if num_answer>0 && num_answer<=length(handles.input.logs)
              handles.LogIndex=num_answer;
              disp(handles.LogIndex);
          else
              errordlg(['The log number must be positive. Check that it is in the range of your logged data.'],'Log Number Error!');
              return;
          end
      
      else
          handles.LogIndex=1;
      end
catch 
    errordlg(['There was a problem loading the file.'],'Load Error!');
   return;
end
%% Linking x axis of timeline and analysisAxis
ax=[handles.Log_timeline, handles.analysisAxis];
linkaxes(ax,'x');
%% Affecting the selected wkv to its handle
handles.wkv=handles.input.logs(handles.LogIndex).wkv;

%% LOADING TXT FILE

%Assumption: txt file attached to log .mat file will always be in same directory
%get directory path
[directory,~,~]=fileparts(handles.fileToAnalyse{1}); % Full path of the directory to be searched in 
filesAndFolders = dir(directory);     % Returns all the files and folders in the directory
filesInDir = filesAndFolders(~([filesAndFolders.isdir]));  % Returns only the files in the directory                    

%use wkv and logIndex to access second column of structure array
stringToBeFound = handles.input.logs(handles.LogIndex).txt; 

%take the second arguments of the wkv and cut it up to get "log" and log ID number (i.e. 00007)
str_elements = strsplit(stringToBeFound,'_');

numOfFiles = length(filesInDir);
i=1;
while(i<=numOfFiles)
    if( (~isempty (strfind(filesInDir(i).name,str_elements{1,1})) ) && (~isempty (strfind(filesInDir(i).name,'info.txt')) ) && (~isempty (strfind(filesInDir(i).name,str_elements{1,2})) ) )
        found = filesInDir(i).name;
        filename = fullfile(directory, found);
        handles.textfile=importdata(filename, '\t');
        handles.originalLogID=str_elements{1,2};
        break;
    else
        found=[];
    end
    i = i+1;
end

if(isempty(found))
    errordlg(['The txt file associated to your .mat file does not seem to be present in the directory.'],'Txt File Absence');
    return;
end



%% INTERACTIVE TIMELINE

% Find the timestamp index.
timeIndex = find(strcmp({handles.wkv.name}, 'timestamp'), 1);

if isempty(timeIndex)
    error('The timestamp could not be found.');
end

% Discard all the data before a change of time (dt > 1 min), otherwise a
% lot of manual zooming will be required to see the relevant data.
setTimeInd = find(abs(diff(handles.wkv(timeIndex).values)) > duration(0, 1, 0), ...
                  1, 'last');

if isempty(setTimeInd)
    handles.startIndex = 1;
else
    handles.startIndex = setTimeInd+1;
end


%call function to get values and index => wkv_get must be in the same
%folder as the GUI Preview
if(~exist('wkv_get.m', 'file'))
     errordlg(['Please place the file wkv_get.m in the same folder as this GUI.'],'Missing External .m file!');
    return;
else
    if(handles.val~= '-')
    [~, varIndex]=wkv_get(handles.wkv, handles.val);
    end
end
%% Plotting
% if no variable selected previously then plotting will occur when variable
% selected later on via variableChoice_Callback
if(handles.val~= '-')
    
    times=handles.wkv(end).values(handles.startIndex:end);
    handles.timeline =plot(times, handles.wkv(varIndex).values(handles.startIndex:end));
    xmin=handles.wkv(end).values(handles.startIndex); xmax=handles.wkv(end).values(end); xlim([xmin, xmax]);
    %set the checkbox of the representation mode to "time representation"
    set(handles.timebox, 'Enable', 'on');
    set(handles.timebox,'value',1);
    
    % Plot and get the two clicks locations.
    axes(handles.Log_timeline);
    xlabel('Time [s]');
    ytitle_split1=split(string(handles.wkv(handles.varIndex).name), '/');
    ytitle_split2=split(ytitle_split1{end}, '_');
    i=2; ytitle=ytitle_split2{1,1}
    while(i<=length(ytitle_split2))
        ytitle=strcat(ytitle, {' '}, ytitle_split2{i,1});
        i=i+1;
    end
    ylabel(ytitle{1});
    
    set(handles.avbox, 'Enable', 'on');
    set(handles.allbox, 'Enable', 'on');
    set(handles.cad_button, 'Enable', 'on');
    set(handles.button, 'Enable', 'on');
    set(handles.mode_button, 'Enable', 'on');
end

%% Set all buttons on since file and text file correctly loaded

set(handles.save_button, 'Enable', 'on');
set(handles.select_button, 'Enable', 'on');
set(handles.playload, 'Enable', 'on');

guidata(hObject, handles);

%%
% Executes during object creation, after setting all properties.
function timeline_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeline_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%%
% --- Executes on button press in select_button.
function select_button_Callback(hObject, eventdata, handles)
% hObject    handle to select_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isequal(handles.loaded,1))
    %% Variable modification due to selection
    %a boolean indicating the selection occurred 
    handles.selection=1;
    
    %reinitialize analysis and cycles
    handles.extraction=0;
    set(handles.cadtext, 'String', {});
    set(handles.stepstext, 'String', {});
    set(handles.modestext, 'String', {});
    handles.cycles={};
    handles.all=0;
    axes(handles.analysisAxis);
    children = get(gca, 'children');
    delete(children);
   

    wkv=handles.input.logs(handles.LogIndex).wkv;
    
    
    %% Cropping of the data of the wkv

    [t_crop, ~] = ginput(2);
    
    % Get the corresponding begin/end indices.
    beginIndex = 1;
    endIndex = length(wkv(end).values);
    
    if t_crop(1) > t_crop(2)
        tmp = t_crop(1);
        t_crop(1) = t_crop(2);
        t_crop(2) = tmp;
    end

    for i=1:length(wkv(end).values) 
        if (wkv(end).values(i)) >= t_crop(1)
            beginIndex = i;
            break;
        end
    end

    for i=beginIndex:length(wkv(end).values)
        if wkv(end).values(i) >= t_crop(2)
            endIndex = i;
            break;
        end
    end

    range = beginIndex:endIndex;

    %Extract the dataset.

    for i=1:length(wkv)
        wkv(i).values = wkv(i).values(range);
    end

    %% Cropping of the data from txt file corresponding
    
    %intiialize a temporary text
    handles.subwkv = struct('wkv', wkv, 'txt', 'temporary');

    %handles.subtext
    %get from subwkv the first and last timestamp
    first_time=handles.subwkv.wkv(1).values(1);
    last_time=handles.subwkv.wkv(1).values(end);
    %cut up timestamps to use info
    [txt_first, first_day, first_hour, first_min, first_secs]=timestampConversion(first_time);
    [txt_last, last_day, last_hour, last_min, last_secs]=timestampConversion(last_time);
    
    %Create handles.textfile (array of lines) to make the txt file associated to the subwkv
    index=1;

    while(length(handles.textfile)>=index)
        %reach the first timestamp of subwkv
        entry=handles.textfile{index};
        entry_decompo=strsplit(entry,' ');
        txt_date=entry_decompo{1,1};
        
        %further decomposition for a more in depth comparison of txt_date
        %and txt_first and txt_last
        str_elements = strsplit(txt_date,'_'); %seperate date from time
        h=str_elements{1,2}; minute=str_elements{1,3}; secs=str_elements{1,4}(1:end-1);
        getDay=strsplit(str_elements{1,1},'-');
        d=getDay{1,3};
        
        %not all dates are in the txt file so necessary to look if the
        %current line of the text file is after the desired first date
        %extracted from the subwkv or after the desired last date.
        
        [passed_first] = dateSkippedCheck(secs, minute, h, d,first_secs,first_min, first_hour, first_day);
        
        if(strcmp(txt_date,txt_first) || isequal(passed_first,1))
            handles.subtxt={};
            passed_last=0;
            %when first timestamp reached. Save all entries until last one reached
            while(~strcmp(txt_date,txt_last) && isequal(passed_last,0))
                
                entry=handles.textfile{index};
                entry_decompo=strsplit(entry,' ');
                txt_date=entry_decompo{1,1};
                
                %further decomposition for a more in depth comparison of txt_date
                %and txt_first and txt_last
                str_elements = strsplit(txt_date,'_'); %seperate date from time
                h=str_elements{1,2}; minute=str_elements{1,3}; secs=str_elements{1,4}(1:end-1);
                getDay=strsplit(str_elements{1,1},'-');
                d=getDay{1,3};
                [passed_last] = dateSkippedCheck(secs, minute, h, d,last_secs,last_min, last_hour, last_day);
        
                handles.subtxt{end+1,1}=entry;
                index=index+1;

            end

            if(strcmp(txt_date,txt_last) || isequal(passed_last,1))
                 break;
            end


        end
        index=index+1;

    end

    %in save ask the user to name the log file by giving a number and put this
    %new name in the subwkv file 2nd field

    safe=0;
    while(safe==0)
        prompt={'Enter a number for the log info text file that will be created in association to this data.'};
        dlg_title= 'Text File Number Choice';
        num_lines=1;
        answer=inputdlg(prompt,dlg_title,num_lines);
        
        handles.selectionID=answer{1};
        
        Name=strcat('log_',answer{1},'_info.txt')
        if(~ (exist(Name, 'file') == 2))
            handles.subtxtName=Name; 
            safe=1;
        else
            errordlg(['Please choose a different log ID number.'],'Danger of file overwrite.');
            return;
        end
    end

    %handles because necessary for subsequent saving and creation of the actual txt file

    %Creating the handle corresponding to cut up
    handles.subwkv = struct('wkv', wkv, 'txt', handles.subtxtName);

    %% Handles Reallocation due to IRREVERSIBLE selection
    %WKV HANDLE REALLOCATED TO THE CUT UP VERSION, same for the textfile  
    handles.wkv=handles.subwkv.wkv;
    handles.textfile=handles.subtxt; 
    %i.e. the selection is irreversible.

    %%
    %call function to get values and index => wkv_get must be in the same
    %folder as the GUI Preview
    if(~exist('wkv_get.m', 'file'))
         errordlg(['Please place the file wkv_get.m in the same folder as this GUI.'],'Missing External .m file!');
        return;
    else
        if(handles.val~= '-')
        [~, handles.varIndex]=wkv_get(handles.wkv, handles.val);
        end
    end

    if(handles.val~= '-')
        set(handles.timebox,'value',1)
        
        times=handles.wkv(end).values(handles.startIndex:end);
        axes(handles.Log_timeline);
        handles.timeline =plot(times, handles.wkv(handles.varIndex).values(handles.startIndex:end));
        xmin=handles.wkv(end).values(handles.startIndex);
        xmax=handles.wkv(end).values(end);
        xlim([xmin, xmax]); 
      
        
        % labels 
        xlabel('Timestamps');
        ytitle_split1=split(string(handles.wkv(handles.varIndex).name), '/');
        ytitle_split2=split(ytitle_split1{end}, '_');
        i=2; ytitle=ytitle_split2{1,1}
        while(i<=length(ytitle_split2))
            ytitle=strcat(ytitle, {' '}, ytitle_split2{i,1});
            i=i+1;
        end
        ylabel(ytitle{1});
        
        set(handles.avbox, 'Enable', 'on');
        set(handles.allbox, 'Enable', 'on');
        set(handles.cad_button, 'Enable', 'on');
        set(handles.button, 'Enable', 'on');
        set(handles.mode_button, 'Enable', 'on');
    end
end


guidata(hObject, handles);


% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(isequal(handles.loaded,1))
    
    
    if(isequal(handles.selection,1))
        %select place where new data set will be saved
        path=uigetdir(matlabroot, 'Choose where your log selection will be saved,');
        filename=strcat('log_',handles.selectionID,'.mat');

        newfilename = fullfile(path, filename);
        logs=handles.subwkv;
        
        %% Save wkv 
        try 
            save(newfilename, 'logs');

            currentList=get(handles.currentFileList, 'String');

            newFileList = [currentList; cellstr(newfilename) ];
           
            set(handles.currentFileList, 'String', newFileList);
            setappdata(handles.h,'filelist', handles.currentFileList);
        catch
            errordlg(['There was a problem saving the mat file.'],'Save Error!');
            return;
        end
        %% Save txt
        try
            txtToSave=fullfile(path,handles.subtxtName);

            fileID=fopen(txtToSave,'w');
            S=handles.subtxt;
            i=1;
            while(i<= length(handles.subtxt))

                fprintf(fileID,'%s\n', S{i,1});
                i=i+1;
            end
            fclose(fileID);

        catch
            errordlg(['There was a problem saving the txt file.'],'Save Error!');
            return;
        end
    end
    %% Saving Analysis Data   
    try
        if(isequal(handles.extraction,1))
            
            if(isequal(handles.selection,1))
                %path and selectionID will exist if selection made
                datafilename=strcat('log_',handles.selectionID,'_data.txt');
            else
                %be able to save data of a file that has not been cropped
                [directory,~,~]=fileparts(handles.original);
                path=directory;
                datafilename=strcat('log_',handles.originalLogID,'_data.txt');
            end

            datasaved = fullfile(path, datafilename);
            fileID=fopen(datasaved,'w');
            
            modedata=get(handles.modestext, 'string');
            if(~isequal(modedata, 'Modes Data'))
                fprintf(fileID,'%s\n', 'Modes: ');
                i=1;
                while(i<=length(modedata))
                    fprintf(fileID,'%s\n', modedata{i,1});
                    i=i+1;
                end
            end
            
            stepdata=get(handles.stepstext, 'string');
            if(~isequal(stepdata,'Steps Data'))
                fprintf(fileID,'%s\n', 'Steps: ');
                i=1;
                while(i<=length(stepdata))
                    fprintf(fileID,'%s\n', stepdata{i,1});
                    i=i+1;
                end      
            end
            
            caddata= get(handles.cadtext, 'string');
            if(~isequal(caddata, 'Cadence Data'))
                fprintf(fileID,'%s\n', 'Cadences: ');
                i=1;
                while(i<=length(caddata))
                    fprintf(fileID,'%s\n',caddata{i,1});
                    i=i+1;
                end
            end
            
            if(isequal(handles.selection,1))
                selectiontext=strcat('This data corresponds to a selection. Original file: ', handles.original);
                fprintf(fileID,'%s\n', selectiontext);
            end
            
            fclose(fileID);
        end
    catch
        errordlg('There was a problem saving the data file.','Save Error!');
        return;
    end

%% Timeline with analysis Image
set(handles.timebox, 'value',1);
set(handles.avbox, 'Enable', 'on');
set(handles.allbox, 'Enable', 'on');
set(handles.cad_button, 'Enable', 'on');
set(handles.button, 'Enable', 'on');
set(handles.mode_button, 'Enable', 'on');

timebox_Callback(handles.timebox, eventdata, handles);
mode_button_Callback(handles.mode_button, eventdata, handles);
button_Callback(handles.button, eventdata, handles);
cad_button_Callback(handles.cad_button, eventdata, handles);

if(isequal(handles.selection,1))
    %path and selectionID will exist if selection made
    imagename=strcat('log_',handles.selectionID,'_timeline');
else
    %be able to save data of a file that has not been cropped
    [directory,~,~]=fileparts(handles.original);
    path=directory;
    imagename=strcat('log_',handles.originalLogID,'_timeline');
end
timesaved = fullfile(path, imagename);
set(gcf,'PaperPositionMode','auto');
saveas(gcf,timesaved,'png');

%% Saving All Cycles Image
set(handles.allbox, 'value',1);
allbox_Callback(handles.allbox, eventdata, handles);
if(isequal(handles.selection,1))
    %path and selectionID will exist if selection made
    imagename=strcat('log_',handles.selectionID,'_average_variance');
else
    %be able to save data of a file that has not been cropped
    [directory,~,~]=fileparts(handles.original);
    path=directory;
    imagename=strcat('log_',handles.originalLogID,'_average_variance');
end
averagesaved = fullfile(path, imagename);
set(gcf,'PaperPositionMode','auto');
saveas(gcf,averagesaved,'png');

%% Saving Graph Average Image
%plot average graph 
set(handles.avbox, 'value',1);
avbox_Callback(handles.avbox, eventdata, handles);

if(isequal(handles.selection,1))
    %path and selectionID will exist if selection made
    imagename=strcat('log_',handles.selectionID,'_all_cycles');
else
    %be able to save data of a file that has not been cropped
    [directory,~,~]=fileparts(handles.original);
    path=directory;
    imagename=strcat('log_',handles.originalLogID,'_all_cycles');
end
allsaved = fullfile(path, imagename); 
set(gcf,'PaperPositionMode','auto');
saveas(gcf,allsaved,'png');


end
handles.user_quit=1;
delete(handles.figure1);




% --- Executes during object creation, after setting all properties.
function select_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function save_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%%
% --- Executes on selection change in variableChoice.
function variableChoice_Callback(hObject, eventdata, handles)
% hObject    handle to variableChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% Get the index name
contents = cellstr(get(handles.variableChoice,'String'));
handles.val=contents{get(handles.variableChoice,'Value')};
%% Get the index from wkv
%call function to get values and index => wkv_get must be in the same
%folder as the GUI Preview
if(~exist('wkv_get.m', 'file'))
    errordlg(['Please place the file wkv_get.m in the same folder as this GUI.'],'Missing External .m file!');
    return;
else
    %wkv needs to be a handle
    %startIndex also
    if(~isequal(handles.val, '-') && isequal(handles.loaded,1))
        [~, handles.varIndex]=wkv_get(handles.wkv, handles.val);
    end
end
%% Plot on Timeline due to variable change
if(~isequal(handles.val, '-') && isequal(handles.loaded,1))
    
    times=handles.wkv(end).values(handles.startIndex:end);
    axes(handles.Log_timeline);
    hold off;
    handles.timeline =plot(times, handles.wkv(handles.varIndex).values(handles.startIndex:end));
        
    set(handles.timebox,'value',1);
    % Plot and get the two clicks locations.
    xlabel('Time [s]'); xmin=handles.wkv(end).values(handles.startIndex); xmax=handles.wkv(end).values(end); xlim([xmin, xmax]);
    %%% 5 should be determined to be a choice representaition
    ytitle_split1=split(string(handles.wkv(handles.varIndex).name), '/');
    ytitle_split2=split(ytitle_split1{end}, '_');
    i=2; ytitle=ytitle_split2{1,1}
    while(i<=length(ytitle_split2))
        ytitle=strcat(ytitle, {' '}, ytitle_split2{i,1});
        i=i+1;
    end
    ylabel(ytitle{1});
    
    set(handles.avbox, 'Enable', 'on');
    set(handles.allbox, 'Enable', 'on');
    set(handles.cad_button, 'Enable', 'on');
    set(handles.button, 'Enable', 'on');
    set(handles.mode_button, 'Enable', 'on');
end

%% Plot Cycles due to variable change
if(~isequal(handles.val, '-') && isequal(handles.loaded,1) && (isequal(get(handles.avbox, 'value'),1)|| isequal(get(handles.allbox, 'value'),1)))
    set(handles.timebox, 'Enable','on');
    set(handles.timebox, 'value',0);
    set(handles.select_button, 'Enable', 'off');
    
    nPoints=300*length(handles.cycles);
    [handles.stackedCycles, handles.times] = wkv_stack_cycles(handles.cycles, handles.varIndex, nPoints);
    %transform into a percentage time scale
    handles.times= (100.*handles.times)./handles.times(end);
    
    % Constants.
    FILL_COLOR = [1 1 1] * 0.8; % Light gray.
    
    % Boolean both: Average and all cycles
    both=(isequal(get(handles.avbox, 'value'),1) && isequal(get(handles.allbox, 'value'),1));
    
    if(isequal(both,1))             
        %% Compute the mean and std curves.
        m = mean(handles.stackedCycles, 1);
        standardDeviation = std(handles.stackedCycles, 1);
        mstdp = m + standardDeviation;
        mstdm = m - standardDeviation;

        %% Plot.
        % Mean and standard deviation envelope.
        axes(handles.Log_timeline);
        xlabel('Cycle (2 steps) Percentage');
        fill([handles.times fliplr(handles.times)], [mstdm fliplr(mstdp)], ...
             FILL_COLOR, 'EdgeColor','None');
        hold on;
        plot(handles.times, m, 'black', 'LineWidth', 2);
        %% Plot All the curves.
        axes(handles.Log_timeline);
        plot(handles.times, handles.stackedCycles);
        hold on 
    end
    
%% Only average and variance of cycles   
    if(isequal(get(handles.avbox, 'value'),1) && isequal(both,0))
         %% Compute the mean and std curves.
        m = mean(handles.stackedCycles, 1);
        standardDeviation = std(handles.stackedCycles, 1);
        mstdp = m + standardDeviation;
        mstdm = m - standardDeviation;
        %% Plot.
        % Mean and standard deviation envelope.
        axes(handles.Log_timeline);
        xlabel('Cycle (2 steps) Percentage');
        fill([handles.times fliplr(handles.times)], [mstdm fliplr(mstdp)], ...
             FILL_COLOR, 'EdgeColor','None');
        hold on;
        plot(handles.times, m, 'black', 'LineWidth', 2);
    end
    
%% Only all cycles
    if(isequal(get(handles.allbox, 'value'),1) && isequal(both,0))
         % All the curves.
        axes(handles.Log_timeline);
        xlabel('Cycle (2 steps) Percentage');
        plot(handles.times, handles.stackedCycles);
        [num, ~]=size(handles.stackedCycles);
        i=1; 
        while(i<=num)
            labels{i}=strcat('Cycle ' , num2str(i));
            i=i+1;
        end
        legend(labels, 'Location', 'northeast');
        hold on
    end
                
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function variableChoice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to variableChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
%%
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%initialize to no variable selected
handles.val='-';
guidata(hObject, handles);


% --- Executes on button press in mode_button.
function mode_button_Callback(hObject, eventdata, handles)
% hObject    handle to mode_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%double preventive condition: button not "clickable" if not loaded.
if(isequal(handles.loaded,1))
    
        %% Get from txt file all the modes entered in this data
        
        %extraction must be done once to get all data. First run takes time
        %operation of the function getTimeDoubles taking time is to process 
        %the timestamps dates (wkv(1)) vs. time doubles (wkv(end))
        if(isequal(handles.extraction,0))
            handles.extraction=1;
            
            [handles.starts_num, handles.ends_num, handles.RightS_num, handles.LeftS_num,...
                handles.endMode_num,handles.toPlotTimes, handles.ind_PlotTimes, handles.ind_RightS,...
                handles.ind_LeftS, handles.left, handles.right, handles.colors, handles.startCadTime,...
                handles.endCadTime, handles.modes]=processing(handles.textfile, handles.wkv);
        
        end
        
        %% After extraction and other processes, represent analysis data
        if(~isempty(handles.toPlotTimes)&& ~isempty(handles.endMode_num))

           %need ToPlotTimes and ends_num: Condition
           %the plot is only done if the timeline representation is active
           %if cycles or average/variance then only written in analysis
           %frame but no representation on graph
           
           if(isequal(get(handles.timebox, 'value'),1))
                
                axes(handles.Log_timeline);
                             
                times=handles.wkv(end).values(handles.startIndex:end);
                
                handles.timeline =plot(times, handles.wkv(handles.varIndex).values(handles.startIndex:end), 'black');
                set(handles.timebox,'value',1);
                hold on
                ymin=min(handles.wkv(handles.varIndex).values(handles.startIndex:end));ymax=max(handles.wkv(handles.varIndex).values(handles.startIndex:end));
                xmin=handles.wkv(end).values(handles.startIndex); xmax=handles.wkv(end).values(end);
                xlim([xmin, xmax]); y=[ymin,ymax]; %height of the curves
           end 
            
            ind=1;
            while(ind<=length(handles.toPlotTimes) && ind<=length(handles.endMode_num))
                 if(isequal(get(handles.timebox, 'value'),1))
                    xval=handles.toPlotTimes(ind);

                    axes(handles.Log_timeline);
                    x=[xval,xval];
                    handles.timeline= plot(x,y, handles.colors{1,ind});

                    %second axis: on analysis plot 
                    endplot=handles.endMode_num(ind);
                    x_analysis=[xval, endplot];
                    axes(handles.analysisAxis);
                    xlim manual;
                    ylim([0,1]);
                    hold on
                    plot(x_analysis, [0.5,0.5],handles.colors{1,ind}, 'Linewidth',5);
                    hold off
                 end
                 
                 %we presume that the mode is new, if this is not the case
                 %then the while loop below will prove so.
                 u=1; new=1; 
                 while(u<ind)
                     newmode=isequal(handles.modes{1,u},handles.modes{1,ind});
                     %it is enough to have on equality to know that the
                     %mode and its color will already be listed in mtext
                     if(isequal(newmode,1))
                         new=0;
                     end
                     u=u+1;
                 end
                 if(isequal(new,1))
                    mtext{1,ind}=sprintf('%s : %s ', handles.modes{1,ind},handles.colors{1,ind});
                 end

                 ind=ind+1;
            end
            mtext;
            set(handles.modestext, 'String', mtext);
            axes(handles.Log_timeline);
            hold off
        else
            f = msgbox('Your selection does not comprise enough input to identify the modes: consider looking at a broader selection. Suggestion: analyse the whole data set to make an appropriate selection.','Mode Functionality Unoperational.'); 
        end
        
    
end

guidata(hObject, handles);



% --- Executes on button press in button.
function button_Callback(hObject, eventdata, handles)
% hObject    handle to button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%double preventive condition: button not "clickable" if not loaded.
if(isequal(handles.loaded,1))
    
        %% Get from txt file all the steps noted in this data
        
        %extraction must be done once to get all data. First run takes time
        %operation of the function getTimeDoubles taking time is to process 
        %the timestamps dates (wkv(1)) vs. time doubles (wkv(end))
        if(isequal(handles.extraction,0))
            handles.extraction=1;
            
            [handles.starts_num, handles.ends_num, handles.RightS_num, handles.LeftS_num,...
                handles.endMode_num,handles.toPlotTimes, handles.ind_PlotTimes, handles.ind_RightS,...
                handles.ind_LeftS, handles.left, handles.right, handles.colors, handles.startCadTime,...
                handles.endCadTime, handles.modes]=processing(handles.textfile, handles.wkv);
        end

        %% After extraction and other processes, represent analysis data
        
        if(~isempty(handles.LeftS_num) && ~isempty(handles.RightS_num))
            k=1; j=1;
            if(isequal(get(handles.timebox, 'value'),1))
                hold on
                while(k<=length(handles.RightS_num))
                   axes(handles.analysisAxis);
                   xlim manual;
                   ylim([0,1]);
                   hold on
                   plot([handles.RightS_num(k),handles.RightS_num(k)],[0.5,0.5], 'ko');
                   k=k+1;
                end

                while(j<=length(handles.LeftS_num))
                   axes(handles.analysisAxis);
                   xlim manual;
                   ylim([0,1]);
                   hold on
                   plot([handles.LeftS_num(j),handles.LeftS_num(j)],[0.5,0.5], 'k*');
                   j=j+1;
                 end
                hold off;
            end
            stext{1,1}=sprintf('Left steps : %d ', handles.left);
            stext{1,2}=sprintf('Right steps : %d ', handles.right);
            set(handles.stepstext, 'String', stext);

            %put plot focus back on the default log timeline and not on the analysis
            %timeline: avoid having the data plotted in the wrong axes
            axes(handles.Log_timeline);
            hold off
        else
            f = msgbox({'Your selection does not comprise any steps: consider looking at a broader selection.' ;'Suggestion: analyse the whole data set to make an appropriate selection.'},'Steps Functionality Unoperational.');       
        end
       
    
end
guidata(hObject, handles);


% --- Executes on button press in cad_button.
function cad_button_Callback(hObject, eventdata, handles)
% hObject    handle to cad_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% condition needed => only do cadence if doing movement => modes not empty

%double preventive condition: button not "clickable" if not loaded.
if(isequal(handles.loaded,1))
    
        %% Get from txt file all the info from txt to calculate cadence
        
        %extraction must be done once to get all data. First run takes time
        %operation of the function getTimeDoubles taking time is to process 
        %the timestamps dates (wkv(1)) vs. time doubles (wkv(end))
        if(isequal(handles.extraction,0))
            
            handles.extraction=1;
            
            [handles.starts_num, handles.ends_num, handles.RightS_num, handles.LeftS_num,...
                handles.endMode_num,handles.toPlotTimes, handles.ind_PlotTimes, handles.ind_RightS,...
                handles.ind_LeftS, handles.left, handles.right, handles.colors, handles.startCadTime,...
                handles.endCadTime, handles.modes] = processing(handles.textfile, handles.wkv);
    
        end
        
        %% After extraction and other processes, represent analysis data
        if(~isempty(handles.starts_num) && ~isempty(handles.ends_num))
            total=handles.left+handles.right+0.5; %+0.5 step
            
            k=1; timeDiff=[];
            while(k<=length(handles.startCadTime))
                %timeDiff is in seconds
                timeDiff(k)=handles.ends_num(k)-handles.starts_num(k);
                timeDiff(k)=timeDiff(k)/60; %conversion to minutes
                
                cad(k)=total/timeDiff(k);
                ctext{1,k}=sprintf('In zone %d: %.2f steps/min', k, cad(k));
                k=k+1;
            end

            set(handles.cadtext, 'String', ctext);
        else
             f = msgbox({'Your selection does not comprise enough input to calculate the cadence: consider looking at a broader selection.' ;'Suggestion: analyse the whole data set to make an appropriate selection.'},'Cadence Functionality Unoperational.');            
        end
        
end

guidata(hObject, handles);


% --- Executes on button press in timebox.
function timebox_Callback(hObject, eventdata, handles)

if(isequal(handles.loaded,1))
    %% Time Representation
    if(isequal(get(handles.timebox,'value'),1))
        %Replot the timeline for variable choice
        set(handles.allbox, 'Enable','on');
        set(handles.allbox, 'value', 0);
        set(handles.avbox, 'value',0);
        set(handles.select_button, 'Enable', 'on');
        set(handles.timMbutton,'Enable','on');
        set(handles.syncbutton, 'Enable', 'on')

        axes(handles.Log_timeline);
        hold off;
        times=handles.wkv(end).values(handles.startIndex:end);
        plot(times, handles.wkv(handles.varIndex).values(handles.startIndex:end)); xmin=handles.wkv(end).values(handles.startIndex); xmax=handles.wkv(end).values(end); xlim([xmin, xmax]);
    end
end

guidata(hObject, handles);


% --- Executes on button press in allbox.
function allbox_Callback(hObject, eventdata, handles)

%% All Cycle Representation

%double preventive condition: button not "clickable" if not loaded.
if(isequal(handles.loaded,1))
    
    %two possibilities: if there are steps then take the time between steps
    %as cycles and take out first because don't know where it begins
    %if there is startCadTime and steps then can have first step included

        if(isequal(handles.extraction,0))
    
            handles.extraction=1;
            
            [handles.starts_num, handles.ends_num, handles.RightS_num, handles.LeftS_num,...
                handles.endMode_num,handles.toPlotTimes, handles.ind_PlotTimes, handles.ind_RightS,...
                handles.ind_LeftS, handles.left, handles.right, handles.colors, handles.startCadTime,...
                handles.endCadTime, handles.modes] = processing(handles.textfile, handles.wkv);
    
        end
        
        %if condition makes that we can only look at one mode/zone after another
        if(isempty(handles.ind_PlotTimes) || isequal(length(handles.ind_PlotTimes),1))
            %% Representation boxes switch
            set(handles.timebox, 'value',0);
            set(handles.timebox, 'Enable','on');
            set(handles.allbox, 'Enable','off');
            set(handles.select_button, 'Enable', 'off');
            set(handles.timMbutton,'Enable','off');
            set(handles.syncbutton, 'Enable', 'off');
            %% Adapt the step data so as to always have full 2 step cycle based on the left leg foot off
            if(handles.ind_RightS(1)>handles.ind_LeftS(1))
                %take away the end of this first left step time so that the
                %cycle pattern is defined by the end of a right step always
                %this means we are looking at the left leg as a reference
                handles.ind_LeftS=handles.ind_LeftS(2:end);
            end
            
            %Check that right step time +1 superior than left step time 
            %else take away last left step time because would leave half a cycle
            if(length(handles.ind_RightS)<=length(handles.ind_LeftS))
                handles.ind_LeftS=handles.ind_LeftS(1:end-1);
            end
            
            indices=transpose(sort([handles.ind_RightS handles.ind_LeftS]));
            N=length(handles.ind_RightS)-1;
            
            if(~isequal(handles.all,1) && isequal(get(handles.allbox,'value'),1) && ~isequal(handles.varIndex,'-'))
                handles.all=1;
                % 1 get cycles
                handles.cycles = wkv_split_cycles_from_txt(handles.wkv,indices,N);

                % 2 stack cycles
                nPoints=300*length(handles.cycles);
                [handles.stackedCycles, handles.times] = wkv_stack_cycles(handles.cycles, handles.varIndex, nPoints);
                %transform into a percentage time scale
                handles.times= (100.*handles.times)./handles.times(end);
                
                %% Check the function arguments.
                if ~isvector(handles.times)
                    error('times should be a vector.');
                end

                if size(handles.stackedCycles, 2) ~= length(handles.times)
                    error(['times should have the same length as the number of columns' ...
                           'of stackedVectors.']);
                end
            end


           if(isequal(get(handles.allbox,'value'),1) && ~isequal(handles.varIndex,'-'))

            %% Plot.
            % All the curves and add a legend indicating which cycle is which
            
            %clear analysis axis
            axes(handles.analysisAxis);
            children = get(gca, 'children');
            delete(children);
            
            axes(handles.Log_timeline);
            plot(handles.times, handles.stackedCycles);
            xlabel('Cycle (2 steps) Percentage');
            [num, ~]=size(handles.stackedCycles);
            i=1; 
            while(i<=num)
                labels{i}=strcat('Cycle ' , num2str(i));
                i=i+1;
            end
            legend(labels, 'Location', 'northeast');
            
            hold on
            
           end
        else
            %% Representation boxes maintained
            set(handles.timebox, 'Enable','on');
            set(handles.timebox, 'value',1);
            set(handles.allbox, 'Enable','on');
            set(handles.allbox, 'value',0);
            f = msgbox({'Cycle decomposition can only be done for one mode.'; ...
                'Please select your data before visualizing cycles.'}, ...
                'Cycle Requirement' );
        end 
end
guidata(hObject, handles);


% --- Executes on button press in avbox.
function avbox_Callback(hObject, eventdata, handles)
%% Average and Variance Representation of Cycles 

if(isequal(handles.loaded,1))
    %two possibilities: if there are steps then take the time between steps
    %as cycles and take out first because don't know where it begins
    %if there is startCadTime and steps then can have first step included

        if(isequal(handles.extraction,0))
                
            handles.extraction=1;
            
            [handles.starts_num, handles.ends_num, handles.RightS_num, handles.LeftS_num,...
                handles.endMode_num,handles.toPlotTimes, handles.ind_PlotTimes, handles.ind_RightS,...
                handles.ind_LeftS, handles.left, handles.right, handles.colors, handles.startCadTime,...
                handles.endCadTime, handles.modes] = processing(handles.textfile, handles.wkv);
    
        end
        
        %if condition makes that we can only look at one mode/zone after another
        if(isempty(handles.ind_PlotTimes) || isequal(length(handles.ind_PlotTimes),1))
            %% Representation boxes switch
            set(handles.timebox, 'value',0);
            set(handles.timebox, 'Enable','on');
            set(handles.allbox, 'Enable','off');
            set(handles.select_button, 'Enable', 'off');
            set(handles.timMbutton,'Enable','off');
            set(handles.syncbutton, 'Enable', 'off');
            %% Adapt the step data so as to always have full 2 step cycle based on the left leg foot off
            if(handles.ind_RightS(1)>handles.ind_LeftS(1))
                %take away the end of this first left step time so that the
                %cycle pattern is defined by the end of a right step always
                %this means we are looking at the left leg as a reference
                handles.ind_LeftS=handles.ind_LeftS(2:end);
            end
            
            %Check that right step time +1 superior than left step time 
            %else take away last left step time because would leave half a cycle
            if(length(handles.ind_RightS)<=length(handles.ind_LeftS))
                handles.ind_LeftS=handles.ind_LeftS(1:end-1);
            end
            
            indices=transpose(sort([handles.ind_RightS handles.ind_LeftS]));
            N=length(handles.ind_RightS)-1;
            
            if(~isequal(handles.all,1) && isequal(get(handles.avbox,'value'),1) && ~isequal(handles.varIndex,'-') )
                handles.all=1;
                % 1 get cycles
                handles.cycles = wkv_split_cycles_from_txt(handles.wkv,indices,N);
                % 2 stack cycles
                nPoints=300*length(handles.cycles);
                [handles.stackedCycles, handles.times] = wkv_stack_cycles(handles.cycles, handles.varIndex, nPoints);
                %transform into a percentage time scale
                handles.times= (100.*handles.times)./handles.times(end);
                %% Check the function arguments.
                if ~isvector(handles.times)
                    error('times should be a vector.');
                end

                if size(handles.stackedCycles, 2) ~= length(handles.times)
                    error(['times should have the same length as the number of columns' ...
                           'of stackedVectors.']);
                end
            end

            if(isequal(get(handles.avbox,'value'),1) && ~isequal(handles.varIndex,'-'))
                 %clear analysis axis
                axes(handles.analysisAxis);
                children = get(gca, 'children');
                delete(children);
                %% Constants.
                FILL_COLOR = [1 1 1] * 0.8; % Light gray.

                %% Compute the mean and std curves.
                m = mean(handles.stackedCycles, 1);
                standardDeviation = std(handles.stackedCycles, 1);
                mstdp = m + standardDeviation;
                mstdm = m - standardDeviation;

                %% Plot.
                % Mean and standard deviation envelope.
                axes(handles.Log_timeline);
                xlabel('Cycle (2 steps) Percentage');
                fill([handles.times fliplr(handles.times)], [mstdm fliplr(mstdp)], ...
                     FILL_COLOR, 'EdgeColor','None');
                hold on;
                plot(handles.times, m, 'black', 'LineWidth', 2);
                        
            end
        else
            %% Representation boxes maintained
            set(handles.timebox, 'Enable','on');
            set(handles.timebox, 'value',1);
            set(handles.allbox, 'Enable','on');
            set(handles.allbox, 'value',0);
            f = msgbox({'Cycle decomposition can only be done for one mode.'; ...
                'Please select your data before visualizing cycles.'}, ...
                'Cycle Requirement' );
        end
end
guidata(hObject, handles);


% --- Executes on button press in videoImportbutton.
function videoImportbutton_Callback(hObject, eventdata, handles)
% hObject    handle to videoImportbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Import Video

[ video_file_name,video_file_path ] = uigetfile({'*.mp4'},'Pick a video file');   
if(video_file_path == 0)
    return;
end
handles.input_video_file = [video_file_path,video_file_name];
handles.videoObject = VideoReader(handles.input_video_file);

%first frame has been read through import
handles.f=1;
handles.totalframes=get(handles.videoObject, 'NumberOfFrames');
handles.fps=get(handles.videoObject, 'FrameRate');
set(handles.scroll,'Min',0);
set(handles.scroll,'Max',handles.videoObject.Duration);

handles.videoObject = VideoReader(handles.input_video_file);
frame_1=read(handles.videoObject,1);
axes(handles.videoaxes);
imshow(frame_1);
drawnow;
axis(handles.videoaxes,'off');

%% Set button properties
set(handles.exitbutton,'Enable','off');
set(handles.playbutton, 'Enable', 'on');
set(handles.forwardbutton,'Enable','on');
set(handles.backbutton,'Enable','on');
set(handles.vidMbutton,'Enable','on');
set(handles.scroll, 'Enable', 'on');
set(handles.stopbutton,'Enable', 'on');


guidata(hObject, handles);


% --- Executes on button press in playbutton.
function playbutton_Callback(hObject, eventdata, handles)
% hObject    handle to playbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Display first frame
%set(handles.pausebutton,'Enable','on');

%% Play/Pause - show marked frame

set(handles.videoImportbutton,'Enable','off');

if(strcmp(get(handles.playbutton,'String'),'Play'))
    %% Play has been clicked
    %set(handles.playbutton,'String','Pause');
    
    set(handles.forwardbutton,'Enable','off');
    set(handles.backbutton,'Enable','off');
    set(handles.vidMbutton,'Enable','off');
    set(handles.timMbutton,'Enable','off');
    set(handles.scroll, 'Enable', 'off');
    
    set(handles.avbox, 'Enable', 'off');
    set(handles.allbox, 'Enable', 'off');
    set(handles.timebox, 'Enable', 'off');
    set(handles.cad_button, 'Enable', 'off');
    set(handles.button, 'Enable', 'off');
    set(handles.mode_button, 'Enable', 'off');
    set(handles.save_button, 'Enable', 'off');
    set(handles.select_button, 'Enable', 'off');
    set(handles.playload, 'Enable', 'off');
    
    handles.user_quit=0;
    guidata(hObject, handles);
        
end

%timeline 
if(isequal(handles.loaded,1))
    if(~isequal(handles.varIndex, '-'))
    ymin=min(handles.wkv(handles.varIndex).values(handles.startIndex:end));
    ymax=max(handles.wkv(handles.varIndex).values(handles.startIndex:end));
    y=[ymin,ymax]; %height of the curves
    end
end

for i=handles.f:handles.totalframes
    axes(handles.videoaxes);
    
    handles = guidata(hObject);
    disp(handles.user_quit);
    
    if(strcmp(get(handles.playbutton,'String'),'Pause') || ~handles.user_quit)
        
        %update frame count and update scroll position
        handles.f=i;
        guidata(hObject, handles);
        handles = guidata(hObject);
        set(handles.scroll, 'Value', handles.videoObject.CurrentTime);
        guidata(hObject, handles);
        handles = guidata(hObject);
        
        %if the frame is the marked frame, display marked frame 
        if(isequal(i,handles.markedFnum))
            imshow(handles.markedFrame);
            drawnow;
            pause(0.05);
        else
            %display frames one after the other
            handles.frame = read(handles.videoObject,i);
            guidata(hObject, handles);
            imshow(handles.frame);
            drawnow;
            pause(0.05); 

            %timeline. 
            %sync must be activated and frames played must be after the marked frame
            if(~isequal(handles.sync,0) && (i>handles.markedFnum)) 
                %old position of marker
                oldx=handles.xmarker;
                %the video advances. 
                %the reference time is that of the marker frame: handles.markedTime
                %moves time marker forwards the number of seconds that the video moves forwards
                videoadvancement=handles.videoObject.CurrentTime-handles.markedTime;
                %calculate new position
                axes(handles.Log_timeline);
                hold on;
                %delete the timeline marker each time moved forward
                children = get(gca, 'children');
                delete(children(1));
                handles.xmarker=oldx+videoadvancement;
                x=[handles.xmarker,handles.xmarker];
                handles.new= plot(x,y, ':r', 'Linewidth', 2);
                hold off;
            end
   
        end
            
    else
        break;
    end
end

guidata(hObject, handles);


% --- Executes on button press in stopbutton.
function stopbutton_Callback(hObject, eventdata, handles)
% hObject    handle to stopbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% Stop has been clicked

set(handles.forwardbutton,'Enable','on'); set(handles.backbutton,'Enable','on'); set(handles.vidMbutton,'Enable','on');
set(handles.timMbutton,'Enable','on');set(handles.scroll, 'Enable', 'on');
set(handles.exitbutton,'Enable','on'); set(handles.videoImportbutton,'Enable','on');
set(handles.avbox, 'Enable', 'on'); set(handles.allbox, 'Enable', 'on');
set(handles.timebox, 'Enable', 'on'); set(handles.cad_button, 'Enable', 'on');
set(handles.button, 'Enable', 'on'); set(handles.mode_button, 'Enable', 'on');
set(handles.save_button, 'Enable', 'on');set(handles.select_button, 'Enable', 'on'); set(handles.playload, 'Enable', 'on');

guidata(hObject, handles);

% --- Executes on button press in forwardbutton.
function forwardbutton_Callback(hObject, eventdata, handles)
% hObject    handle to forwardbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Forward Button
axes(handles.videoaxes);
if(isequal(handles.f+1,handles.markedFnum))
    handles.f=(handles.f+1);
    imshow(handles.markedFrame);
    drawnow;
    pause(0.02);
else
    handles = guidata(hObject);
    handles.frame=read(handles.videoObject,(handles.f+1));
    handles.f=(handles.f+1);
    imshow(handles.frame); 
end

%add the display of markedFrame
guidata(hObject, handles);



% --- Executes on button press in backbutton.
function backbutton_Callback(hObject, eventdata, handles)
% hObject    handle to backbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% Backward Button
axes(handles.videoaxes);
if(isequal(handles.f-1,handles.markedFnum))
    handles.f=(handles.f-1);
    imshow(handles.markedFrame);
    drawnow;
    pause(0.02);
else
    handles = guidata(hObject);
    handles.frame=read(handles.videoObject,(handles.f-1));
    handles.f=(handles.f-1);
    imshow(handles.frame);
    drawnow; 
end

guidata(hObject, handles);


function scroll_Callback(hObject, eventdata, handles)
% hObject    handle to scroll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% Scroll movement 
axes(handles.videoaxes);
handles = guidata(hObject);

%old time
oldTime=handles.videoObject.CurrentTime;
%new time where scroll places
newTime=get(handles.scroll,'Value');

diff=newTime-oldTime;
numofFrames=floor((diff)*handles.fps);
handles.f=handles.f+numofFrames;

if(isequal(handles.f,handles.markedFnum))
    imshow(handles.markedFrame);
    drawnow;
    pause(0.02);
else
    handles.frame=read(handles.videoObject,handles.f);
    imshow(handles.frame);
    drawnow; 
end
    
%add the display of markedFrame
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function scroll_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scroll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in vidMbutton.
function vidMbutton_Callback(hObject, eventdata, handles)
% hObject    handle to vidMbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Place video marker by making a new marked frame image
%its role: memorize the currentTime at hand and the frame number
%show visually the marker

axes(handles.videoaxes);
handles = guidata(hObject);
handles.markedTime=handles.videoObject.CurrentTime;
handles.markedFnum=handles.f;
%result of insertMarker is an image
handles.markedFrame=insertShape(handles.frame,'circle',[80 130 35],'LineWidth',20);
imshow(handles.markedFrame);
drawnow;
pause(0.2);

set(handles.timMbutton,'Enable','on');
%both video and timeline markers are set so sync is possible
if(~isequal(handles.timemarker,0))
    set(handles.syncbutton,'Enable','on');
end

guidata(hObject, handles);



% --- Executes on button press in timMbutton.
function timMbutton_Callback(hObject, eventdata, handles)
% hObject    handle to timMbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% Place marker on timeline 
%ginput
axes(handles.Log_timeline);
[handles.xmarker,~] = ginput(1)
%create a vertical red bar as a "cursor"

ymin=min(handles.wkv(handles.varIndex).values(handles.startIndex:end));
ymax=max(handles.wkv(handles.varIndex).values(handles.startIndex:end));
y=[ymin,ymax]; %height of the curves

hold on;
x=[handles.xmarker,handles.xmarker];
handles.new= plot(x,y, ':r', 'Linewidth', 2);
hold off;

handles.timemarker=1;

%both video and timeline markers are set so sync is possible
if(~isequal(handles.markedFnum,0))
    set(handles.syncbutton,'Enable','on');
end

guidata(hObject, handles);


% --- Executes on button press in syncbutton.
function syncbutton_Callback(hObject, eventdata, handles)
% hObject    handle to syncbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% sync the video and timeline markers only if they have been created
if(~isequal(handles.timemarker,0) && ~isequal(handles.markedFnum,0))
    handles.sync=1;
end
guidata(hObject, handles);


% --- Executes on button press in playload.
function playload_Callback(hObject, eventdata, handles)
% hObject    handle to playload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%call function to get values and index => wkv_get must be in the same
%folder as the GUI Preview


%% Represent Load Data from wkv
i=handles.loadindex;
if(isequal(handles.loaded,1))
    if(~exist('wkv_get.m', 'file'))
         errordlg(['Please place the file wkv_get.m in the same folder as this GUI.'],'Missing External .m file!');
        return;
    else
        
        if(strcmp(get(handles.playload,'String'),'Play'))
            set(handles.playload,'String','Pause');
            handles.user_quit=0;
            guidata(hObject, handles);

        else
            set(handles.playload,'String','Play');
            handles.user_quit=1;
            guidata(hObject, handles);
            set(handles.exitbutton,'Enable','on');

        end
        
        %% Call loadProcess function to cut into seconds
        handles = guidata(hObject);
        if(~isequal(handles.cutpersec,1))
            [handles.loadpersec,handles.stamps]=loadProcess(handles.wkv);
            handles.cutpersec=1;
            guidata(hObject, handles);
        end
        
        while(i<=size(handles.stamps,2))
            handles = guidata(hObject);
            if(~handles.user_quit)
                
                %% Affect the load per second for representation
                aL=handles.loadpersec(i,1); bL=handles.loadpersec(i,2); cL=handles.loadpersec(i,3); dL=handles.loadpersec(i,4);
                Row2L=[cL dL]; Row1L=[aL bL];
                cdataL=[Row1L;Row2L]

                aR=handles.loadpersec(i,5); bR=handles.loadpersec(i,6); cR=handles.loadpersec(i,7); dR=handles.loadpersec(i,8);
                Row2R=[cR dR]; Row1R=[aR bR];
                cdataR=[Row1R;Row2R];
                
                %% Draw left Load cells
                handles = guidata(hObject);
                if(~handles.user_quit)
                axes(handles.leftloadcell);
                imagesc(cdataL);
                colormap(jet);
                axis(handles.leftloadcell,'off');
                drawnow;
                end
                %% Draw right Load cells
                handles = guidata(hObject);
                if(~handles.user_quit)
                axes(handles.rightloadcell);
                imagesc(cdataR);
                colormap(jet);
                axis(handles.rightloadcell,'off');
                drawnow;
                end
                %% Indicate the second time frame associated 
                handles = guidata(hObject);
                if(~handles.user_quit)
                set(handles.loadtime, 'String', datestr(handles.stamps(i)));
                guidata(hObject, handles);
                i=i+1;
                end
                
                handles.loadindex=i;
                %make everything start over
                if(isequal(i,size(handles.stamps,2)))
                    i=1;
                    handles.loadindex=1;
                end
            else
                handles.loadindex=i;
                guidata(hObject, handles);
                break;
                
            end
        end

    end
end
guidata(hObject, handles);

% --- Executes on button press in exitbutton.
function exitbutton_Callback(hObject, eventdata, handles)
% hObject    handle to exitbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% EXIT
delete(handles.figure1);
