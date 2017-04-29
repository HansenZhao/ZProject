classdef ParticleSTData < handle
    
    properties
        t;
        addtionInfo;
    end
    
    properties(Access = private)
        arrayData; % id,posX,posY,colorValue,groupTag,obj
        cellData; % method specific data
        capacity;
        particleNum;
    end
    
    properties(Dependent)
        count;
        groupNum;
    end
    
    methods
        function obj = ParticleSTData(t,varargin)
            obj.t = t;
            if isempty(varargin)
                obj.capacity = 100;
            else
                obj.capacity = varargin{1};
            end
            obj.arrayData = zeros(obj.capacity,5);
            obj.cellData = cell(obj.capacity,4);
            obj.particleNum = 0;
            obj.addtionInfo = {};
        end
        
        function addInfo(obj,info)
            obj.addtionInfo = [obj.addtionInfo,info];
        end
        
        function c = get.count(obj)
            c = obj.particleNum;
        end
        
        function gN = get.groupNum(obj)
            gN = length(unique(obj.arrayData(:,5))); 
        end
        
        function addSingleNew(obj,varargin)
            if obj.particleNum == obj.capacity
                obj.arrayData = [obj.arrayData;zeros(obj.capacity,5)];
                obj.cellData = [obj.cellData;cell(obj.capacity,4)];
                obj.capacity = obj.capacity * 2;
            end
            obj.particleNum = obj.particleNum + 1;
            L = length(varargin);
            for m = 1:1:min(L,5)
                obj.arrayData(obj.particleNum,m) = varargin{m};
            end
            if L == 6
                obj.cellData{obj.particleNum} = varargin{6};
            end           
        end
        
        function addNewList(obj,arrayData,varargin)
            L = size(arrayData,1);
            if (obj.particleNum + L) > obj.capacity
                obj.arrayData = [obj.arrayData;zeros(L*2,5)];
                obj.cellData = [obj.cellData;cell(L*2,4)];
                obj.capacity = obj.capacity + L*2;
            end
            obj.arrayData((obj.particleNum + 1):(obj.particleNum + L),:) = arrayData;
            if ~isempty(varargin)
                obj.cellData{(obj.particleNum + 1):(obj.particleNum + L)} = varargin{1};
            end
            obj.particleNum = obj.particleNum + L;
        end
        
        function [aData,cData] = get(obj,varargin)
            L = length(varargin);
            if L == 0
                aData = obj.arrayData;
                cData = obj.cellData;
                return;
            end
            cData = cell(0,0);
            aData = zeros(obj.particleNum,L);
            blank = -1;
            for m = 1:1:L
                idx = ParticleSTData.str2ID(varargin{m});
                if idx == 0
                    error('invalid feature name');
                else if idx == -1
                        cData = obj.cellData;
                        blank = m;
                    else
                        aData(:,m) = obj.arrayData(:,idx);
                    end
                end
            end
            if blank > 0
                aData(:,blank) = [];
            end
        end
    end
    
    methods(Static)
        function idx = str2ID(str)
            switch str
                case 'id'
                    idx = 1;
                case 'posX'
                    idx = 2;
                case 'posY'
                    idx = 3;
                case 'value'
                    idx = 4;
                case 'tag'
                    idx = 5;
                case 'obj'
                    idx = -1;
                otherwise
                    idx = 0;
            end
        end
    end
    
end

