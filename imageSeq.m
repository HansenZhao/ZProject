classdef imageSeq < handle
    
    properties
        curImageIndex;
        seqLength;
        sequencePath;
    end
    
    properties (Access = private)
        rawImages;
        hNextButton;
        hLastButton;
        hFigure;
        hAxes;
    end
    
    events
        onFigureUpdate;
    end
    
    methods
        function obj = imageSeq()
            [fileNames,filePath,index] = uigetfile('*.*','Please Select Image Sequence...','Multiselect','on');
            if index
                obj.sequencePath = filePath;
                obj.seqLength = length(fileNames);
                tmp = double(imread(strcat(filePath,fileNames{1})));
                tmp = sum(tmp,3);
                tmp = flipud(tmp);
                [nr,nc] = size(tmp);
                obj.rawImages = zeros(nr,nc,obj.seqLength);
                obj.rawImages(:,:,1) = tmp;
                for m = 2:1:obj.seqLength
                    tmp = double(imread(strcat(filePath,fileNames{m})));
                    tmp = sum(tmp,3);
                    tmp = flipud(tmp);
                    obj.rawImages(:,:,m) = tmp;
                end
                obj.curImageIndex = 1;
            end
        end      
        function show(obj)
            rt = get(0,'ScreenSize');
            [x,y,~] = size(obj.rawImages);
            rt(3) = (rt(4)/x)*y;
            obj.hFigure = figure('pos',rt);
            obj.hAxes = axes;
            imagesc(obj.hAxes,obj.rawImages(:,:,obj.curImageIndex));
            title(strcat('Image Seqence:',32,num2str(obj.curImageIndex),32,'/',32,num2str(obj.seqLength)));
            obj.hNextButton = uicontrol('string','next','pos',[10,10,80,49]);
            set(obj.hNextButton,'callback',@obj.onNext);
            obj.hLastButton = uicontrol('string','last','pos',[100,10,80,49]);
            set(obj.hLastButton,'callback',@obj.onLast);
            notify(obj,'onFigureUpdate');
            colormap('gray');
        end          
        function update(obj)
            imagesc(obj.hAxes,obj.rawImages(:,:,obj.curImageIndex));
            title(strcat('Image Seqence:',32,num2str(obj.curImageIndex),32,'/',32,num2str(obj.seqLength)));
            notify(obj,'onFigureUpdate');
        end
        function hF = getFigure(obj)
            hF = obj.hFigure;
        end
        function hA = getAxes(obj)
            hA = obj.hAxes;
        end
        function im = getImage(obj,varargin)
            if isempty(varargin)
                im = obj.rawImages;
            else
                if and(varargin{1}>0,varargin{1}<=obj.seqLength)
                    im = obj.rawImage(:,:,varargin{1});
                end
            end
        end
        function lh = listenUpdate(obj,func)
            lh = addlistener(obj,'onFigureUpdate',func);
        end
    end
    
    methods (Access = private)
        function onNext(obj,varargin)
            obj.curImageIndex = obj.curImageIndex + 1;
            if obj.curImageIndex > obj.seqLength
                obj.curImageIndex = 1;
            end
            obj.update();
        end
        function onLast(obj,varargin)
            obj.curImageIndex = obj.curImageIndex - 1;
            if obj.curImageIndex <= 0
                obj.curImageIndex = obj.seqLength;
            end
            obj.update();
        end
    end
    
end

