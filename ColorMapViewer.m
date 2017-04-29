function varargout = ColorMapViewer(varargin)
% COLORMAPVIEWER MATLAB code for ColorMapViewer.fig
%      COLORMAPVIEWER, by itself, creates a new COLORMAPVIEWER or raises the existing
%      singleton*.
%
%      H = COLORMAPVIEWER returns the handle to a new COLORMAPVIEWER or the handle to
%      the existing singleton*.
%
%      COLORMAPVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COLORMAPVIEWER.M with the given input arguments.
%
%      COLORMAPVIEWER('Property','Value',...) creates a new COLORMAPVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ColorMapViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ColorMapViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ColorMapViewer

% Last Modified by GUIDE v2.5 27-Apr-2017 22:39:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ColorMapViewer_OpeningFcn, ...
                   'gui_OutputFcn',  @ColorMapViewer_OutputFcn, ...
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


% --- Executes just before ColorMapViewer is made visible.
function ColorMapViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ColorMapViewer (see VARARGIN)

% Choose default command line output for ColorMapViewer
handles.output = hObject;
handles.controller = varargin{1};
handles.isPlotBg = varargin{2};
handles.cLim = varargin{3};
handles.isKeepRange = 0;
scatterPoint(handles,0);
refreshSubAxes(handles);
set(handles.Stx_curFrame,'String',num2str(handles.controller.curFrame));
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ColorMapViewer wait for user response (see UIRESUME)
% uiwait(handles.Fig_viewer);


% --- Outputs from this function are returned to the command line.
function varargout = ColorMapViewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Btn_Last.
function Btn_Last_Callback(hObject, eventdata, handles)
% hObject    handle to Btn_Last (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
scatterPoint(handles,-1);
set(handles.Stx_curFrame,'String',num2str(handles.controller.curFrame));


% --- Executes on button press in Btn_Next.
function Btn_Next_Callback(hObject, eventdata, handles)
% hObject    handle to Btn_Next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
scatterPoint(handles,1);
refreshSubAxes(handles);
set(handles.Stx_curFrame,'String',num2str(handles.controller.curFrame));


function scatterPoint(handles,addDir)
    c = get(handles.Axes_main,'Color');

    
    dataArray = handles.controller.getCurData(addDir);
    
    genPointHeatMap(handles.Axes_main,400,dataArray(:,2:4),3,1.5,'disk');
    set(handles.Axes_main,'NextPlot','add');
    scatter(handles.Axes_main,dataArray(:,2),dataArray(:,3),20,dataArray(:,4),'filled');
    
    if handles.isPlotBg
        data = handles.controller.getPData();
        filter = data(:,2) <= handles.controller.curFrame;
        data = data(filter,:);
        ids = unique(data(:,1))';
        for id = ids
            plot(handles.Axes_main,data(data(:,1)==id,3),data(data(:,1)==id,4),'Color',lines(1));
            
        end
    end
    set(handles.Axes_main,'NextPlot','replace');
    box on;
    if handles.isKeepRange
        set(handles.Axes_main,'XLim',handles.xlim);
        set(handles.Axes_main,'YLim',handles.ylim);
    end
    set(handles.Axes_main,'Color',c);
    colormap(hsv);
    caxis(handles.cLim);
    colorbar(handles.Axes_main);
    
function refreshSubAxes(handles)
%     info = handles.controller.getCurInfo();
%     frame = handles.controller.curFrame;
%     if isempty(handles.Axes_1.Children)
%         plot(handles.Axes_1,frame,info{1});
%     else
%         if length(handles.Axes_1.Children.YData) >= handles.controller.frameLength
%             clearSubAxes();
%             refreshSubAxes();
%             return;
%         end
%         plot(handles.Axes_1,[handles.Axes_1.Children.XData,frame],...
%             [handles.Axes_1.Children.YData,info{1}]);
%     end

function clearSubAxes(handles)
%     handles.Axes_1.Children = {};


% --- Executes on button press in Rbtn_keepRange.
function Rbtn_keepRange_Callback(hObject, eventdata, handles)
% hObject    handle to Rbtn_keepRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Rbtn_keepRange


% --- Executes on button press in Btn_AxesBG.
function Btn_AxesBG_Callback(hObject, eventdata, handles)
% hObject    handle to Btn_AxesBG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
c = uisetcolor;
if length(c) > 1
    set(handles.Axes_main,'Color',c);
end

% --- Executes on button press in Btn_captureRange.
function Btn_captureRange_Callback(hObject, eventdata, handles)
% hObject    handle to Btn_captureRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~handles.isKeepRange
    handles.isKeepRange = 1;
end
set(hObject,'BackgroundColor',[0.47,0.67,0.19]);
handles.xlim = get(handles.Axes_main,'XLim');
handles.ylim = get(handles.Axes_main,'YLim');
guidata(hObject,handles);


% --- Executes on button press in Btn_release.
function Btn_release_Callback(hObject, eventdata, handles)
% hObject    handle to Btn_release (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.Axes_main,'XLimMode','auto','YLimMode','auto');
set(handles.Btn_captureRange,'BackgroundColor',[0.94,0.94,0.94]);
handles.isKeepRange = 0;
guidata(hObject,handles);


% --- Executes on button press in Btn_saveImage.
function Btn_saveImage_Callback(hObject, eventdata, handles)
% hObject    handle to Btn_saveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Btn_saveVideo.
function Btn_saveVideo_Callback(hObject, eventdata, handles)
% hObject    handle to Btn_saveVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uiputfile('*.avi','Save video...');
handles.controller.setCurFrameIndex(1);
videoObj = VideoWriter(strcat(path,file));
frameRate = inputdlg({'Frame Rate','Quality [0,100]'},'Video',1,{'10','75'});
videoObj.FrameRate = str2num(frameRate{1});
videoObj.Quality = str2num(frameRate{2});
open(videoObj);
for m = 1:1:handles.controller.frameLength
    scatterPoint(handles,1);
    set(handles.Stx_curFrame,'String',num2str(handles.controller.curFrame));
    writeVideo(videoObj,getframe(handles.Axes_main));
end
close(videoObj);
msgbox(strcat('Video output:',32,path,file));
% --- Executes on button press in Btn_play.
function Btn_play_Callback(hObject, eventdata, handles)
% hObject    handle to Btn_play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
