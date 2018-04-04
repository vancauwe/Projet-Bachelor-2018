function varargout = Browser(varargin)
% BROWSER MATLAB code for Browser.fig
%      BROWSER, by itself, creates a new BROWSER or raises the existing
%      singleton*.
%
%      H = BROWSER returns the handle to a new BROWSER or the handle to
%      the existing singleton*.
%
%      BROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BROWSER.M with the given input arguments.
%
%      BROWSER('Property','Value',...) creates a new BROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Browser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Browser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Browser

% Last Modified by GUIDE v2.5 31-Mar-2018 20:13:33

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
% handles    structure with handles and user data (see GUIDATA)
handles.filelist.Max=2;
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
    %visibility of Browser / Preview figure out later
    Preview;
end
guidata(hObject, handles);

%will have to put in OpeningFcn that access Browser data and uses the
%filelist value and string to load automatically the file into the preview




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
disp(selpath);
%make it: mkdir
try
    newFolder=fullfile(selpath,answer{1});
    
    if ~exist(newFolder, 'dir')
        mkdir(newFolder);
    else 
        errordlg(['Such a folder already exists.'],'Folder Overwrite Danger.');
        return;
    end
    
    i=1;
    while( i<=length(albumIndexes))
       Filenames = get(handles.filelist,'String');
       fileToLoad=Filenames{i};
       
       [~,name,~]=fileparts(fileToLoad);
       newPlace=fullfile(newFolder,name);
       
       fileToSave=load(fileToLoad);
       save(newPlace, 'fileToSave');
       i=i+1;
    end
        
catch
    errordlg(['New Album folder could not be created.'],'Album Creation Error!');
    return;
end
%iterate through selection


guidata(hObject, handles);


% with multi selection then get indexes as a tableau
% ask to create album folder and name
% load files one by one into workspace 
% save in this folder specified
% close one by one after saving 

%Note: when press on make file then multi select is on. Must have a
%condition for preview button to avoid bug





% --- Executes on button press in makebutton.
function makebutton_Callback(hObject, eventdata, handles)
% hObject    handle to makebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (length(handles.filelist) >= 1)
    
    f = msgbox({'The minimum number of files for an album is 2.'; ...
        'Note: To select multiple files use "command" or "control" as appropriate to your OS.'}, ...
        'Making an album Important Information' );

else
   errordlg(['Files must be opened in browser before making album.'],'Make Album Error!');
   return;
end
guidata(hObject, handles);
    
