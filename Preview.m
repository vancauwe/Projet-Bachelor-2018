function varargout = Preview(varargin)
% PREVIEW MATLAB code for Preview.fig
%      PREVIEW, by itself, creates a new PREVIEW or raises the existing
%      singleton*.
%
%      H = PREVIEW returns the handle to a new PREVIEW or the handle to
%      the existing singleton*.
%
%      PREVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREVIEW.M with the given input arguments.
%
%      PREVIEW('Property','Value',...) creates a new PREVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Preview_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Preview_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Preview

% Last Modified by GUIDE v2.5 04-Apr-2018 23:44:18

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
handles.output = hObject;
handles.h = findobj('Tag','Browser');
if ~isempty(handles.h)
browserdata = guidata(handles.h);
handles.fileToAnalyse = browserdata.analysis_file;
handles.currentFileList=browserdata.filelist;
end
%check that the analysis_file is not empty? 

%If need be, the second handles structure can be updated from the first GUI by using
%setappdata(Preview, handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Preview wait for user response (see UIRESUME)
% uiwait(handles.figure1);


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

% Hint: place code in OpeningFcn to populate Log_timeline


% --- Executes on button press in timeline_button.
function timeline_button_Callback(hObject, eventdata, handles)
% hObject    handle to timeline_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%LOADING FILE DATA
try
      %first load the file corresponding to the name handles.fileToAnalyse
      handles.input=load(handles.fileToAnalyse{1});
      
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

%%
%ADAPTING TO FILE => make subwkv have txt later on. DONE
%if(handles.dim1~=1)
wkv=handles.input.logs(handles.LogIndex).wkv;
%else
    %wkv=handles.input.logs;
%end
%%
%LOADING TXT FILE

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
    if( (~isempty (strfind(filesInDir(i).name,str_elements{1,1})) ) && (~isempty (strfind(filesInDir(i).name,str_elements{1,2})) ) )
        found = filesInDir(i).name;
        filename = fullfile(directory, found);
        handles.textfile=importdata(filename, '\t');
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



%%
% INTERACTIVE TIMELINE

% Find the timestamp index.
timeIndex = find(strcmp({wkv.name}, 'timestamp'), 1);

if isempty(timeIndex)
    error('The timestamp could not be found.');
end

% Discard all the data before a change of time (dt > 1 min), otherwise a
% lot of manual zooming will be required to see the relevant data.
setTimeInd = find(abs(diff(wkv(timeIndex).values)) > duration(0, 1, 0), ...
                  1, 'last');

if isempty(setTimeInd)
    startIndex = 1;
else
    startIndex = setTimeInd+1;
end

%make the diverse things that can be represented
%get index corresponding to name via get function

%call function to get values and index => wkv_get must be in the same
%folder as the GUI Preview
if(~exist('wkv_get.m', 'file'))
     errordlg(['Please place the file wkv_get.m in the same folder as this GUI.'],'Missing External .m file!');
    return;
else
    [~, varIndex]=wkv_get(wkv, handles.val);
end
%%
handles.timeline =plot(wkv(end).values(startIndex:end), wkv(varIndex).values(startIndex:end));
% Plot and get the two clicks locations.
axes(handles.Log_timeline);
xlabel('Time [us]');
%%% 5 should be determined to be a choice representaition
ylabel(string(wkv(varIndex).name));

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

%%

%if(handles.dim1~=1)
wkv=handles.input.logs(handles.LogIndex).wkv;
%else
    %wkv=handles.input.logs;
%end

%%

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
    if wkv(end).values(i) >= t_crop(1)
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

%%
handles.subwkv = struct('wkv', wkv, 'txt', 'temporary');

%handles.subtext
%get from subwkv the first and last timestamp
first_time=handles.subwkv.wkv(1).values(1);
last_time=handles.subwkv.wkv(1).values(end);
%cut up timestamps to use info
txt_first=timestampConversion(first_time);
txt_last=timestampConversion(last_time);

%Create handles.textfile (array of lines) to make the txt file associated to the subwkv
index=1;

while(length(handles.textfile)>=index)
    %reach the first timestamp of subwkv
    entry=handles.textfile{index};
    entry_decompo=strsplit(entry,' ');
    txt_date=entry_decompo{1,1};

    if(~strcmp(txt_date,txt_first))
        handles.subtxt={};
        %when first timestamp reached. Save all entries until last one reached
        while(~strcmp(txt_date,txt_last))
        entry=handles.textfile{index};
        entry_decompo=strsplit(entry,' ');
        txt_date=entry_decompo{1,1};

        handles.subtxt{end+1,1}=entry;
        index=index+1;
        
        end
        
        if(txt_date==txt_last)
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

%TO DO: Must create a "Security" loop to make sure this file name is not already present in the directory

%Creating the handle corresponding to cut up
handles.subwkv = struct('wkv', wkv, 'txt', handles.subtxtName);

guidata(hObject, handles);

%%
% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%%
[filename, path]=uiputfile;
newfilename = fullfile(path, filename);
logs=handles.subwkv;
try 
    save(newfilename, 'logs');
     
    currentList=get(handles.currentFileList, 'String');
    
    newFileList = [currentList; cellstr(newfilename) ];
    %set(handles.currentfilelist, 'String', handles.Files);
    %newFileList = handles.currentFileList;
    
    
    set(handles.currentFileList, 'String', newFileList);
    setappdata(handles.h,'filelist', handles.currentFileList);
catch
    errordlg(['There was a problem saving the mat file.'],'Save Error!');
    return;
end

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
guidata(hObject, handles);
%%
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
%%
contents = cellstr(get(handles.variableChoice,'String'));
handles.val=contents{get(handles.variableChoice,'Value')};

guidata(hObject, handles);

% Hints: contents = cellstr(get(hObject,'String')) returns variableChoice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from variableChoice

%%
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
guidata(hObject, handles);
