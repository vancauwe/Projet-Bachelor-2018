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

% Last Modified by GUIDE v2.5 26-Apr-2018 19:28:19

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
handles.loaded=0;
handles.extraction=0;
handles.cropped=0;
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
      
      %variable that allows to know if file has been loaded: so as to not
      %be able to ask for the scroll to change if variable has not been
      %loaded::
      handles.loaded=1; 
      
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
%Linking x axis of timeline and analysisAxis
ax=[handles.Log_timeline, handles.analysisAxis];
linkaxes(ax,'x');
%%
%ADAPTING TO FILE => make subwkv have txt later on. DONE
%if(handles.dim1~=1)
handles.wkv=handles.input.logs(handles.LogIndex).wkv;
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
%%
if(handles.val~= '-')
    handles.timeline =plot(handles.wkv(end).values(handles.startIndex:end), handles.wkv(varIndex).values(handles.startIndex:end));
    % Plot and get the two clicks locations.
    axes(handles.Log_timeline);
    xlabel('Time [us]');
    %%% 5 should be determined to be a choice representaition
    ylabel(string(handles.wkv(varIndex).name));
end

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
    %%
    %if(handles.dim1~=1)
    handles.cropped=1;
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
        h=str_elements{1,2}; min=str_elements{1,3}; secs=str_elements{1,4}(1:end-1);
        getDay=strsplit(str_elements{1,1},'-');
        d=getDay{1,3};
        
        %not all dates are in the txt file so necessary to look if the
        %current line of the text file is after the desired first date
        %extracted from the subwkv or after the desired last date.
        
        [passed_first] = dateSkippedCheck(secs, min, h, d,first_secs,first_min, first_hour, first_day);
        
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
                h=str_elements{1,2}; min=str_elements{1,3}; secs=str_elements{1,4}(1:end-1);
                getDay=strsplit(str_elements{1,1},'-');
                d=getDay{1,3};
                [passed_last] = dateSkippedCheck(secs, min, h, d,last_secs,last_min, last_hour, last_day);
        
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

    %WKV HANDLE REALLOCATED TO THE CUT UP VERSION, same for the textfile index 
    handles.wkv=handles.subwkv.wkv;
    handles.textfile=handles.subtxt; 
    %disp(handles.subwkv.wkv.name)
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
        handles.timeline =plot(handles.wkv(end).values(handles.startIndex:end), handles.wkv(handles.varIndex).values(handles.startIndex:end));
        % Plot and get the two clicks locations.
        axes(handles.Log_timeline);
        xlabel('Time [us]');
        %%% 5 should be determined to be a choice representaition
        ylabel(string(handles.wkv(handles.varIndex).name));
    end
end


guidata(hObject, handles);

%%
% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%%
if(isequal(handles.loaded,1))
    %[filename, path]=uiputfile;
    
    path=uigetdir(matlabroot, 'Choose where your log selection will be saved,');
    filename=strcat('log_',handles.selectionID,'.mat');
    
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
%%
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
%%
if(~isequal(handles.val, '-') && isequal(handles.loaded,1))
    handles.timeline =plot(handles.wkv(end).values(handles.startIndex:end), handles.wkv(handles.varIndex).values(handles.startIndex:end));
    % Plot and get the two clicks locations.
    axes(handles.Log_timeline);
    xlabel('Time [us]');
    %%% 5 should be determined to be a choice representaition
    ylabel(string(handles.wkv(handles.varIndex).name));
end

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

handles.val='-';
guidata(hObject, handles);


% --- Executes on button press in mode_button.
function mode_button_Callback(hObject, eventdata, handles)
% hObject    handle to mode_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isequal(handles.loaded,1))
    if(~isequal(handles.cropped,1))
        %get from txt file all the modes entered in this data
        if(isequal(handles.extraction,0))
            [handles.dates, handles.modes, handles.colors,handles.endMode, handles.left,handles.right,handles.startCadTime,handles.endCadTime, handles.LeftS, handles.RightS]=extraction(handles.textfile);
            handles.extraction=1;
            
            disp('step1');
        end

        if(~isempty(handles.dates) && ~(isequal(handles.endMode, ' ')))

            k=1;
            while(k<=length(handles.endMode))
                convertedEnds{1,k}=matTimeConversion(handles.endMode{1,k});
                k=k+1;
                disp('step2');
            end
            
            disp('step3');
            ends_num=getTimeDoubles(handles.wkv,convertedEnds);
            

            %convert to a wkv timestamp format
            i=1; 
            while(i<=length(handles.dates))
                disp('step4');
                convertedDates{1,i}=matTimeConversion(handles.dates{1,i});
                i=i+1;
            end

           %where code was
           %replacement:
           disp('step5');
           toPlotTimes=getTimeDoubles(handles.wkv,convertedDates);
           
           disp(toPlotTimes);
           
           disp('step6');
            axes(handles.Log_timeline);
            handles.timeline =plot(handles.wkv(end).values(handles.startIndex:end), handles.wkv(handles.varIndex).values(handles.startIndex:end), 'black');
            hold on
            ymin=min(handles.wkv(handles.varIndex).values(handles.startIndex:end));
            ymax=max(handles.wkv(handles.varIndex).values(handles.startIndex:end));
            y=[ymin,ymax]; %height of the curves
            ind=1;
            
            
            while(ind<=length(toPlotTimes) && ind<=length(ends_num))
                xval=toPlotTimes(ind);

                axes(handles.Log_timeline);
                x=[xval,xval];
                handles.timeline= plot(x,y, handles.colors{1,ind});

                %second axis
                x_analysis=[xval, ends_num(ind)];
                axes(handles.analysisAxis);
                xlim manual;
                ylim([0,1]);
                hold on
                plot(x_analysis, [0.5,0.5],handles.colors{1,ind}, 'Linewidth',5);
                hold off


                mtext{1,ind}=sprintf('%s : %s ', handles.modes{1,ind},handles.colors{1,ind});
                ind=ind+1;
            end
            mtext;
            set(handles.modestext, 'String', mtext);
            axes(handles.Log_timeline);
            hold off

        else
            f = msgbox('Your selection does not comprise enough input to identify the modes: consider looking at a broader selection. \n Suggestion: analyse the whole data set to make an appropriate selection.','Mode Functionality Unoperational.'); 

        end
    
    else
        f=msgbox('You have cropped your data set. Please "Save to Browser" and reopen cropped data in Preview for analysis. consider looking at a broader selection.','Necessary to "Save to Browser" and "Preview" to proceed with analysis.'); 
        
    end
end

guidata(hObject, handles);



% --- Executes on button press in button.
function button_Callback(hObject, eventdata, handles)
% hObject    handle to button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isequal(handles.loaded,1))
    
    if(~isequal(handles.cropped,1))
        if(isequal(handles.extraction,0))
            [handles.dates, handles.modes, handles.colors,handles.endMode, handles.left,handles.right,handles.startCadTime,handles.endCadTime,handles.LeftS, handles.RightS]=extraction(handles.textfile);
            handles.extraction=1;
        end

        if(~isempty(handles.LeftS) && ~isempty(handles.LeftS))
            k=1;
            while(k<=length(handles.LeftS))
                convertedLeftS{1,k}=matTimeConversion(handles.LeftS{1,k});
                k=k+1;
            end

            k=1;
            while(k<=length(handles.RightS))
                convertedRightS{1,k}=matTimeConversion(handles.RightS{1,k});
                k=k+1;
            end

            RightS_num=getTimeDoubles(handles.wkv,convertedRightS);
            LeftS_num=getTimeDoubles(handles.wkv,convertedLeftS);

            k=1; j=1;
            hold on
            while(k<=length(RightS_num))
                while(j<=length(LeftS_num))
                    axes(handles.analysisAxis);
                    xlim manual;
                    ylim([0,1]);
                    hold on
                    plot([RightS_num(k),RightS_num(k)],[0.5,0.5], 'ko');
                    plot([LeftS_num(j),LeftS_num(j)],[0.5,0.5], 'k*');
                    k=k+1;j=j+1;
                    hold off;
                end
            end

            stext{1,1}=sprintf('Left steps : %d ', handles.left);
            stext{1,2}=sprintf('Right steps : %d ', handles.right);
            set(handles.stepstext, 'String', stext);

            %put plot focus back on the default log timeline and not on the analysis
            %timeline: avoid having the data plotted in the wrong axes
            axes(handles.Log_timeline);
            hold off
        else
            f = msgbox('Your selection does not comprise any steps: consider looking at a broader selection. \n Suggestion: analyse the whole data set to make an appropriate selection.','Steps Functionality Unoperational.'); 
        end
    
    else
        f=msgbox('You have cropped your data set. Please "Save to Browser" and reopen cropped data in Preview for analysis. consider looking at a broader selection.','Necessary to "Save to Browser" and "Preview" to proceed with analysis.'); 
        
    end
end
guidata(hObject, handles);


% --- Executes on button press in cad_button.
function cad_button_Callback(hObject, eventdata, handles)
% hObject    handle to cad_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% condition needed => only do cadence if doing movement => modes not empty 

if(isequal(handles.loaded,1))
    
    if(~isequal(handles.cropped,1))

        if(isequal(handles.extraction,0))
            [handles.dates, handles.modes, handles.colors,handles.endMode, handles.left,handles.right,handles.startCadTime,handles.endCadTime, handles.LeftS, handles.RightS]=extraction(handles.textfile);
            handles.extraction=1;
        end
        total=handles.left+handles.right+0.5; %+0.5 step

        if(~(isequal(handles.startCadTime, ' ')) && ~(isequal(handles.endCadTime, ' ')))
            k=1;
            while(k<=length(handles.startCadTime))
                convertedStarts{1,k}=matTimeConversion(handles.startCadTime{1,k});
                convertedEnds{1,k}=matTimeConversion(handles.endCadTime{1,k});
                k=k+1;
            end

            starts_num=getTimeDoubles(handles.wkv,convertedStarts);
            ends_num=getTimeDoubles(handles.wkv,convertedEnds);

            k=1; timeDiff=[];
            while(k<=length(handles.startCadTime))
                timeDiff(k)=ends_num(k)-starts_num(k);
                cad(k)=total/timeDiff(k);
                ctext{1,k}=sprintf('In zone %d: %.2f steps/time unit', k, cad(k));
                k=k+1;
            end

            set(handles.cadtext, 'String', ctext);

        else
            f = msgbox('Your selection does not comprise enough input to calculate the cadence: consider looking at a broader selection. \n Suggestion: analyse the whole data set to make an appropriate selection.','Cadence Functionality Unoperational.'); 
        end
    else
        f=msgbox('You have cropped your data set. Please "Save to Browser" and reopen cropped data in Preview for analysis. consider looking at a broader selection.','Necessary to "Save to Browser" and "Preview" to proceed with analysis.'); 
        
    end
end

guidata(hObject, handles);


% --- Executes on button press in timebox.
function timebox_Callback(hObject, eventdata, handles)
% hObject    handle to timebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of timebox


% --- Executes on button press in allbox.
function allbox_Callback(hObject, eventdata, handles)
% hObject    handle to allbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of allbox


% --- Executes on button press in avbox.
function avbox_Callback(hObject, eventdata, handles)
% hObject    handle to avbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of avbox
