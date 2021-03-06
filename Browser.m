function varargout = Browser(varargin)
% BROWSER MATLAB code for Browser.fig
%    The Browser allows to:
%    - open files one by one in Preview for analysis 
%    - regroup files into albums
%
%    Browser_OpeningFc: [line 61]
%    disables certain buttons by default
%
%%   Loading
%    addbutton_Callback: [line 124]
%    interactively add files to the filelist. Enables
%    the disabled buttons.
%    
%    importbutton_Callback: [line 273]
%    allows to import an entire album to the fileliste.
%    (reads the text file to get all the reference pathes of the files in
%    the album)
%%   Other functions   
%    deletebutton_Callback: [line 160]
%    deletes the selected file from file list
%
%    previewbutton_Callback: [line 185]
%    opens up preview for the single file selected
%
%%   Albums
%    makebutton_Callback: [line 254]
%    displays message explaining how to make an album
%
%    albumbutton_Callback: [line 208]
%    creates an ablum in the form of a text file with the references
%    (pathes) of all the files composing the album
%
%%   Required External Functions and GUI
%    Preview.m / Preview.fig

% Last Modified by GUIDE v2.5 09-May-2018 17:37:30

%% Opening Code
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Browser_OpeningFcn, ...
                   'gui_OutputFcn',  @Browser_OutputFcn, ...
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


% --- Executes just before Browser is made visible.
function Browser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Browser (see VARARGIN)

% Choose default command line output for Browser
handles.output = hObject;
set(handles.deletebutton,'Enable','off');
set(handles.previewbutton,'Enable','off');
set(handles.albumbutton, 'Enable', 'off');
set(handles.makebutton, 'Enable', 'off');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Browser wait for user response (see UIRESUME)
% uiwait(handles.Browser);


% --- Outputs from this function are returned to the command line.
function varargout = Browser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in filelist.
function filelist_Callback(hObject, eventdata, handles)
% hObject    handle to filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns filelist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filelist
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function filelist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    
end

handles.Files={};
handles.filelist={};
disp('Deleting everything');
guidata(hObject, handles);


% --- Executes on button press in addbutton.
function addbutton_Callback(hObject, eventdata, handles)
% hObject    handle to addbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
%handles.filelist.Max=2;
set(handles.filelist, 'Max', 2);
try
      %load appropriate file
      [filename, path]=uigetfile('*.mat','Select the MATLAB code file', 'MultiSelect' , 'on');
      
      if isequal(filename, 0)
       %user canceled
        return;
      end
      
      %whether 1 file added or multiple, adds all of them to filelist.
      filename = cellstr(filename);  
      for k = 1:length(filename)
          handles.Files = [handles.Files; cellstr(fullfile(path, filename{k})) ];
      end

      set(handles.filelist, 'String', handles.Files);
      
      set(handles.deletebutton,'Enable','on');
      set(handles.previewbutton,'Enable','on');
      set(handles.makebutton, 'Enable', 'on');
      
            
catch 
    errordlg(['There was a problem loading the files.'],'Load Error!');
   return;
end
 
guidata(hObject, handles);


% --- Executes on button press in deletebutton.
function deletebutton_Callback(hObject, eventdata, handles)
% hObject    handle to deletebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
List = handles.filelist; 
indexedFilelist = get(List,'value'); 
%index of selected element of the list
newPlace = indexedFilelist(1)-1;
%will be deleted so index minus one

if (newPlace <=0) newPlace = 1; end 

Filenames = get(List,'String'); 
%names of those that will be deleted

if ~isempty(Filenames) 
    Filenames(indexedFilelist) = []; 
    handles.Files=Filenames;
    set(List,'String', handles.Files,'value', newPlace);
end

guidata(hObject, handles);


% --- Executes on button press in previewbutton.
function previewbutton_Callback(hObject, eventdata, handles)
% hObject    handle to previewbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
List = handles.filelist; 
indexedFilelist = get(List,'value'); 
if(length(indexedFilelist)~=1)
    f = msgbox({'Files are previewed one by one.'; ...
        'Only one file can be selected: please unselect till only one remains.'}, ...
        'Selection Error for Preview' );
else
    
    Filenames = get(List,'String'); 
    handles.analysis_file = Filenames(indexedFilelist);
    guidata(hObject, handles);
    %set(gcf,'Visible','off');
    %visibility of Browser / Preview 
    Preview;
end
guidata(hObject, handles);


% --- Executes on button press in albumbutton.
function albumbutton_Callback(hObject, eventdata, handles)
% hObject    handle to albumbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
albumIndexes=get(handles.filelist,'value');
%choose name: prompt...     
prompt={'Enter the name of your album'};
dlg_title= 'Album Name Specification';
num_lines=1;
answer=inputdlg(prompt,dlg_title,num_lines);
%indicate path: uigetdir
selpath = uigetdir;
%make it: mkdir
try
    newFolder=fullfile(selpath,answer{1});
    
    if ~exist(newFolder, 'dir')
        mkdir(newFolder);
    else 
        errordlg(['Such a folder already exists.'],'Folder Overwrite Danger.');
        return;
    end
    
    %Saves text file with references to all files of album
    albumname=strcat(answer{1},'.txt');
    %album has the same name as the folder in which it is
    album=fullfile(newFolder,albumname);
    fileID=fopen(album,'w');
    
    Filenames = get(handles.filelist,'String');
    i=1;
    while( i<=length(albumIndexes))
       fileNameToSave=Filenames{albumIndexes(i)};
       fprintf(fileID,'%s\n', fileNameToSave);
       i=i+1;        
    end
    fclose(fileID);
catch
    errordlg(['New Album folder could not be created.'],'Album Creation Error!');
    return;
end


guidata(hObject, handles);

% --- Executes on button press in makebutton.
function makebutton_Callback(hObject, eventdata, handles)
% hObject    handle to makebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (length(handles.filelist) >= 1)
    
    f = msgbox({'The minimum number of files for an album is 2.'; ...
        'Note: To select multiple files use "command" or "control" as appropriate to your OS.'}, ...
        'Making an album Important Information' ); if (length(get(handles.filelist,'value')) > 1) set(handles.albumbutton, 'Enable', 'on'); end

else
   errordlg(['Files must be opened in browser before making album.'],'Make Album Error!');
   return;
end
guidata(hObject, handles);
    


% --- Executes on button press in importbutton.
function importbutton_Callback(hObject, eventdata, handles)
% hObject    handle to importbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.filelist, 'Max', 2);
try
      %load appropriate file
      [filename, path]=uigetfile('*.txt','Select the album reference text file', 'MultiSelect' , 'on');
      
      if isequal(filename, 0)
       %user canceled
        return;
      end
      fileToOpen=fullfile(path,filename);
      albumFiles=importdata(fileToOpen, '\t');
      Filenames = get(handles.filelist,'String'); 
      k=1;
      while(k<=length(albumFiles))
          handles.Files = [handles.Files; cellstr(albumFiles{k})  ];
          k=k+1;
      end
      
      set(handles.filelist, 'String', handles.Files);
      
      set(handles.deletebutton,'Enable','on');
      set(handles.previewbutton,'Enable','on');
      set(handles.albumbutton, 'Enable', 'on');
      set(handles.makebutton, 'Enable', 'on');
catch
end



guidata(hObject, handles);
