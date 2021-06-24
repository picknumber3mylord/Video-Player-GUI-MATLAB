function varargout = VideoPlayer(varargin)
%VIDEOPLAYER MATLAB code file for VideoPlayer.fig
%      VIDEOPLAYER, by itself, creates a new VIDEOPLAYER or raises the existing
%      singleton*.
%
%      H = VIDEOPLAYER returns the handle to a new VIDEOPLAYER or the handle to
%      the existing singleton*.
%
%      VIDEOPLAYER('Property','Value',...) creates a new VIDEOPLAYER using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to VideoPlayer_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      VIDEOPLAYER('CALLBACK') and VIDEOPLAYER('CALLBACK',hObject,...) call the
%      local function named CALLBACK in VIDEOPLAYER.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VideoPlayer

% Last Modified by GUIDE v2.5 07-Dec-2018 16:22:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VideoPlayer_OpeningFcn, ...
                   'gui_OutputFcn',  @VideoPlayer_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before VideoPlayer is made visible.
function VideoPlayer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for VideoPlayer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes VideoPlayer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = VideoPlayer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in playPause.
function playPause_Callback(hObject, eventdata, handles)
% hObject    handle to playPause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.playing || strcmp(get(handles.playPause, 'String'), 'Pause'))
    set(handles.playPause, 'String' , 'Play');
    handles.playing = false;
    guidata(hObject, handles);
    uiwait();
else 
    set(handles.playPause, 'String', 'Pause');
    handles.playing = true;
    guidata(hObject, handles);
    uiresume();
end 




% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

MP4 = handles.videoFile;
if (handles.orig)
    handles.orig = false;
    set(handles.slider1, 'Value', (MP4.CurrentTime / MP4.Duration));
    guidata(hObject, handles);
else
    h = get(handles.slider1,'Value');
    MP4.CurrentTime= h * MP4.Duration;
    handles.videoFile = MP4;
    handles.playing = true;
    axes1 = handles.mainVideo;
    axes2 = handles.aaVid;
    axes3 = handles.frcVid;
    currentFrame = readFrame(MP4);
    image(currentFrame, 'Parent',axes1);
    axes1.Visible = 'off';
    image(currentFrame, 'Parent', axes2);
    axes2.Visible = 'off';
    image(currentFrame, 'Parent', axes3);
    axes3.Visible = 'off';
    pause(1 / MP4.FrameRate);
    guidata(hObject,handles);
    playPause_Callback(hObject, eventdata, handles);
end


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in disableAA.
function disableAA_Callback(hObject, eventdata, handles)
% hObject    handle to disableAA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.aadis || strcmp(get(handles.disableAA, 'String'), 'Enable Anti-Aliasing'))
    handles.aadis = false;
    set(handles.disableAA, 'String', 'Disable Anti-Aliasing');
    MP4 = handles.videoFile;
    vidAxes = handles.aaVid;
    width = MP4.Width;
    height = MP4.Height;
    vidFrame = readFrame(MP4);
    red = vidFrame(:, :, 1);
    green = vidFrame(:, :, 2);
    blue = vidFrame(:, :, 3);
    for i = 2:1:height
        for j = 2:1:width
            redVal = (red(i, j) - red(i, j - 1)) / 2;
            red(i, j) = redVal;
            red(i, j - 1) = redVal;
            blueVal = (blue(i, j) - blue(i, j - 1)) / 2;
            blue(i, j) = blueVal;
            blue(i, j - 1) = blueVal;
            greenVal = (green(i, j) - green(i, j - 1)) / 2;
            green(i, j) = greenVal;
            green(i, j - 1) = greenVal;
        end
    end
    vidFrame(:, :, 1) = red;
    vidFrame(:, :, 2) = green;
    vidFrame(:, :, 3) = blue;
    image(vidFrame, 'Parent', vidAxes);
    vidAxes.Visible = 'off';
    pause(1 / MP4.FrameRate);
else
    handles.aadis = true;
    MP4 = handles.videoFile;
    vidAxes = handles.aaVid;
    set(handles.disableAA, 'String', 'Enable Anti-Aliasing');
    vidFrame = readFrame(MP4);
    image(vidFrame, 'Parent', vidAxes)
    vidAxes.Visible = 'off';
    pause(1 / MP4.FrameRate);
end
guidata(hObject, handles);

% --- Executes on button press in disableFRC.
function disableFRC_Callback(hObject, eventdata, handles)
% hObject    handle to disableFRC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MP4 = handles.videoFile;
axes = handles.frcVid;
frame1 = readFrame(MP4);
frame2 = frame1;
image(frame1, 'Parent', axes);
axes.Visible = 'off';
image(frame2, 'Parent', axes);
axes.Visible = 'off';
pause(1 / MP4.FrameRate);
guidata(hObject, handles);

    


% --- Executes on button press in stop.
function stop_Callback(hObject, eventdata, handles)
% hObject    handle to stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MP4 = handles.videoFile;
vidAxes = handles.mainVideo;
axes2 = handles.aaVid;
axes3 = handles.frcVid;
MP4.CurrentTime = 0;
firstFrame = readFrame(MP4);
image(firstFrame, 'Parent', vidAxes);
vidAxes.Visible = 'off';
image(firstFrame, 'Parent', axes2);
axes2.Visible = 'off';
image(firstFrame, 'Parent', axes3);
axes3.Visible = 'off';
pause(1 / MP4.FrameRate);
set(handles.slider1, 'Value', 0);
set(handles.playPause, 'String', 'Play');
handles.playing = false;
guidata(hObject, handles);
uiwait();


% --- Executes on button press in stepForward.
function stepForward_Callback(hObject, eventdata, handles)
% hObject    handle to stepForward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~(handles.playing)
    handles.playing = true;
else
    uiresume();
end
MP4 = handles.videoFile;
MP4.CurrentTime = MP4.CurrentTime + (1 / MP4.FrameRate);
axes1 = handles.mainVideo;
axes2 = handles.aaVid;
axes3 = handles.frcVid;
forwardFrame = readFrame(MP4);
image(forwardFrame, 'Parent',axes1);
axes1.Visible = 'off';
image(forwardFrame, 'Parent', axes2);
axes2.Visible = 'off';
image(forwardFrame, 'Parent', axes3);
axes3.Visible = 'off';
set(handles.slider1, 'Value', (MP4.CurrentTime / MP4.Duration));
handles.videoFile = MP4;
guidata(hObject, handles);
playPause_Callback(hObject, eventdata, handles);



% --- Executes on button press in stepBack.
function stepBack_Callback(hObject, eventdata, handles)
% hObject    handle to stepBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~(handles.playing)
    handles.playing = true;
else
    uiresume();
end
MP4 = handles.videoFile;
MP4.CurrentTime = MP4.CurrentTime - (2 / MP4.FrameRate);
axes1 = handles.mainVideo;
axes2 = handles.aaVid;
axes3 = handles.frcVid;
forwardFrame = readFrame(MP4);
image(forwardFrame, 'Parent',axes1);
axes1.Visible = 'off';
image(forwardFrame, 'Parent', axes2);
axes2.Visible = 'off';
image(forwardFrame, 'Parent', axes3);
axes3.Visible = 'off';
set(handles.slider1, 'Value', (MP4.CurrentTime / MP4.Duration));
handles.videoFile = MP4;
guidata(hObject, handles);
playPause_Callback(hObject, eventdata, handles);


% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputFile = uigetfile('*.mp4');
MP4 = VideoReader(inputFile);
handles.videoFile = MP4;
set(handles.text12, 'String', inputFile);
set(handles.text13, 'String', [num2str(MP4.Width), ' x ', num2str(MP4.Height)]);
set(handles.text14, 'String', num2str(int8(MP4.FrameRate)));
dur = round(MP4.Duration);
h = int8(dur / 3600);
m = int8(dur / 60);
s = mod(dur, 60);
set(handles.text15, 'String', [num2str(h), 'h ', num2str(m), 'm ', num2str(s), 's']);
handles.iState = true;
handles.playing = false;
guidata(hObject, handles);
stop_Callback(hObject, eventdata, handles);
axes1 = handles.mainVideo;
axes2 = handles.aaVid;
axes3 = handles.frcVid;
guidata(hObject, handles);
while (hasFrame(MP4))
    vidFrame = readFrame(MP4);
    image(vidFrame, 'Parent',axes1);
    axes1.Visible = 'off';
    handles.aadis = true;
    guidata(hObject, handles);
    disableAA_Callback(hObject, eventdata, handles);
    disableFRC_Callback(hObject, eventdata, handles);
    handles.MP4 = MP4;
    handles.orig = true;
    guidata(hObject, handles);
    slider1_Callback(hObject, eventdata, handles);
    pause(1 / MP4.FrameRate);
end
handles.videoFile = MP4;
guidata(hObject, handles);
