classdef CMVController < handle
    
    properties
        dataCell;
        cLim;
    end
    
    properties(Access = private);
        pdata;
        frames;
        curFrameIndex
    end
    
    properties(Dependent)
        frameLength;
        curFrame;
    end
    
    methods
        function obj = CMVController(frames,dataCell,pdata,cLim)
            obj.dataCell = dataCell;
            obj.pdata = pdata;
            obj.frames = frames;
            obj.curFrameIndex = 1;
            obj.cLim = cLim;
        end
        function f = get.curFrame(obj)
            f = obj.frames(obj.curFrameIndex);
        end
        function data = getCurData(obj,adding)
            if adding ~= 0
                obj.curFrameIndex = obj.curFrameIndex + adding;
                if obj.curFrameIndex > length(obj.frames)
                    obj.curFrameIndex = 1;
                end
                if obj.curFrameIndex < 1
                    obj.curFrameIndex = length(obj.frames);
                end
            end
            data = obj.dataCell{obj.curFrameIndex}.get('id','posX','posY','value');
        end
        function show(obj,isPlotBg)
            ColorMapViewer(obj,isPlotBg,obj.cLim);
        end
        function res = getCurFramePData(obj)
            ids = obj.dataCell{obj.curFrameIndex}.get('id');
            res = [];
            for id = ids'               
                res = [res;obj.pdata.getParticle(id)];
            end
        end
        function pdata = getPData(obj)
            pdata = obj.pdata.getParticle();
        end
        function setCurFrameIndex(obj,frameIndex)
            obj.curFrameIndex = frameIndex;
            if obj.curFrameIndex > length(obj.frames)
                obj.curFrameIndex = 1;
            end
            if obj.curFrameIndex < 1
                obj.curFrameIndex = length(obj.frames);
            end
        end
        function l = get.frameLength(obj)
            l = length(obj.frames);
        end
        function info = getCurInfo(obj)
            info = obj.dataCell{obj.curFrameIndex}.addtionInfo;
        end
    end
    
    methods(Static)
        function flag = isInTri(pos,verts)
            o = verts(1,:);
            v1 = verts(2,:) - o;
            v2 = verts(3,:) - o;
            v3 = pos - o;
            alpha = dot(v1,v2)/(norm(v1)*norm(v2));
            alpha1 = dot(v3,v1)/(norm(v3)*norm(v1));
            alpha2 = dot(v3,v2)/(norm(v3)*norm(v2));
            
            if ~(alpha <= alpha1) && (alpha <= alpha2)
                flag = false;
                return;
            end
            
            o = verts(2,:);
            v1 = verts(1,:) - o;
            v2 = verts(3,:) - o;
            v3 = pos - o;
            alpha = dot(v1,v2)/(norm(v1)*norm(v2));
            alpha1 = dot(v3,v1)/(norm(v3)*norm(v1));
            alpha2 = dot(v3,v2)/(norm(v3)*norm(v2));
            
            if (alpha <= alpha1) && (alpha <= alpha2)
                flag = true;
            else
                flag = false;
            end    
        end      
    end
    
end

