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

% Last Modified by GUIDE v2.5 05-May-2017 19:52:40

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
handles.isKeepRange = 0;
handles.backLength = -1;
handles.k = 1;
handles.isRef = 0;
handles.isShowHM = 1;
handles.cLim = [];
handles.HMtype = 'value';
set(handles.Ed_cLim,'String','auto');
set(handles.Rb_showHeatMap,'Value',1);
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
    if handles.isShowHM
        genPointHeatMap(handles.Axes_main,handles.HMtype,40,dataArray(:,2:4),3,1.5,2);
        set(handles.Axes_main,'NextPlot','add');
        scatter(handles.Axes_main,dataArray(:,2),dataArray(:,3),20,dataArray(:,4),'filled');
    else
        scatter(handles.Axes_main,dataArray(:,2),dataArray(:,3),20,dataArray(:,4),'filled');
        set(handles.Axes_main,'NextPlot','add');
    end
    
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
    colorbar(handles.Axes_main);
    if isempty(handles.cLim)
    else
        caxis(handles.Axes_main,handles.cLim);
    end
    
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


% --- Executes on selection change in Pop_dataType.
function Pop_dataType_Callback(hObject, eventdata, handles)
% hObject    handle to Pop_dataType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(hObject,'String'));
switch contents{get(hObject,'Value')}
    case 'Direction'
        handles.typeHM = 'value';
    case 'Hist Direction'
        handles.typeHM = 'tag';
    case 'Velocity'
        handles.typeHM = 'value';
    case 'Hist Velocity'
        handles.typeHM = 'tag';
    case 'MSD'
        handles.typeHM = 'tag';
    case 'Asym'
        handles.typeHM = 'value';
end
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns Pop_dataType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Pop_dataType
function refreshControllerData(handles,str)
    switch str
        case 'Direction'
            param = struct();
            param.backLength = handles.backLength;
            param.isRef = handles.isRef;
            handles.controller.askForData(CBDataType.NetDirection,param);
        case 'Hist Direction'
        case 'Velocity'
            param = struct();
            param.backLength = handles.backLength;
            param.isRef = handles.isRef;
            handles.controller.askForData(CBDataType.NetVelocity,param);
        case 'Hist Velocity'
        case 'Asym'
        case 'MSD'
            param = struct();
            param.backLength = handles.backLength;
            param.tau = floor(param.backLength/3);
            param.k = handles.k;
            param.methods = handles.kmeansMethod;
            handles.controller.askForData(CBDataType.MSD,param);
    end
% --- Executes during object creation, after setting all properties.
function Pop_dataType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pop_dataType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ed_backLength_Callback(hObject, eventdata, handles)
% hObject    handle to Ed_backLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.backLength = str2double(get(hObject,'String'));
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of Ed_backLength as text
%        str2double(get(hObject,'String')) returns contents of Ed_backLength as a double


% --- Executes during object creation, after setting all properties.
function Ed_backLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ed_backLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Rb_refDir.
function Rb_refDir_Callback(hObject, eventdata, handles)
% hObject    handle to Rb_refDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.isRef = get(hObject,'Value');
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of Rb_refDir



function Ed_k_Callback(hObject, eventdata, handles)
% hObject    handle to Ed_k (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.k = str2double(get(hObject,'String'));
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of Ed_k as text
%        str2double(get(hObject,'String')) returns contents of Ed_k as a double


% --- Executes during object creation, after setting all properties.
function Ed_k_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ed_k (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Pop_kmeansMethod.
function Pop_kmeansMethod_Callback(hObject, eventdata, handles)
% hObject    handle to Pop_kmeansMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(hObject,'String'));
handles.kmeansMethod = contents{get(hObject,'Value')};
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns Pop_kmeansMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Pop_kmeansMethod


% --- Executes during object creation, after setting all properties.
function Pop_kmeansMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pop_kmeansMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Btn_getData.
function Btn_getData_Callback(hObject, eventdata, handles)
% hObject    handle to Btn_getData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(handles.Pop_dataType,'String'));
refreshControllerData(handles,contents{get(handles.Pop_dataType,'Value')});
scatterPoint(handles,0);
set(handles.Stx_curFrame,'String',num2str(handles.controller.curFrame));

function Ed_xRange_Callback(hObject, eventdata, handles)
% hObject    handle to Ed_xRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ed_xRange as text
%        str2double(get(hObject,'String')) returns contents of Ed_xRange as a double


% --- Executes during object creation, after setting all properties.
function Ed_xRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ed_xRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ed_yRange_Callback(hObject, eventdata, handles)
% hObject    handle to Ed_yRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ed_yRange as text
%        str2double(get(hObject,'String')) returns contents of Ed_yRange as a double


% --- Executes during object creation, after setting all properties.
function Ed_yRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ed_yRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Pop_colorMap.
function Pop_colorMap_Callback(hObject, eventdata, handles)
% hObject    handle to Pop_colorMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(hObject,'String'))
colormap(handles.Axes_main,contents{get(hObject,'Value')});
% Hints: contents = cellstr(get(hObject,'String')) returns Pop_colorMap contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Pop_colorMap


% --- Executes during object creation, after setting all properties.
function Pop_colorMap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pop_colorMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Rb_showHeatMap.
function Rb_showHeatMap_Callback(hObject, eventdata, handles)
% hObject    handle to Rb_showHeatMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.isShowHM = get(hObject,'Value');
scatterPoint(handles,0);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of Rb_showHeatMap



function Ed_cLim_Callback(hObject, eventdata, handles)
% hObject    handle to Ed_cLim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = get(hObject,'String');
if strcmp(str,'auto')
    handles.cLim = [];
else if strcmp(str,'ref')
        handles.cLim = handles.controller.cLim;
    else
        try
            str_seg = strsplit(str,' ');
            handles.cLim = [str2num(str_seg{1}),str2num(str_seg{2})];
        catch
            set(hObject,'String','ERROR INPUT');
        end
    end
end
scatterPoint(handles,0);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of Ed_cLim as text
%        str2double(get(hObject,'String')) returns contents of Ed_cLim as a double


% --- Executes during object creation, after setting all properties.
function Ed_cLim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ed_cLim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
