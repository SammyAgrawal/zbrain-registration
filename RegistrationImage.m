classdef RegistrationImage < handle
    properties
        baseDir
        filePath
        numericData
        scaledImage
        type
    end
    
    methods
        function obj = RegistrationImage(index, type, loc)
            % index specifies which image from source want. 
            % type is a flag specifying source of file, either videos or
            % high resolution stacks (TBD whether including Z Brain atlas)
            % loc is an argument that specifies the prefix, for now rostral
            % or caudal
            
            obj.type = loc; % store rostral or caudal 
            switch type
                case "stack"
                    % to match file convention, must turn index into
                    % 3-digit string. 65 --> "065" etc
                    s = int2str(index);
                    if (strlength(s) < 3)
                        s = join(repmat("0", 1,3 - strlength(s)), "") + s;
                    end
                    obj.baseDir = "E:/rawData/2019_08_21/fluor/";
                    obj.filePath = obj.baseDir + join([type loc s], "_") + ".tif"; % points to .tif file
                    IG = imread(obj.filePath, "Index", 1); % ? gcamp protein 
                    IR = imread(obj.filePath, "Index", 2); % vglut channel
                    
                    obj.numericData = cat(3, IG, IR, imread(obj.filePath, 3));
                    
                    % Rescale up to 99th quantile
                    IG = rescale(min(IG, quantile(IG, 0.99, 'all')));
                    IR = rescale(min(IR, quantile(IR, 0.99, 'all')));
                    IB = zeros(size(IG), 'single');

                    obj.scaledImage = cat(3, IR, IG, IB);
                    
                case "video"
                    % ProcessingManager calls FleurMetaData class's
                    % load function using metadata.mat file --> fmd
                    % object
                    procMan = ProcessingManager("E:/", "2019_08_21", "rostral", [index]);
                    fmd = procMan.getDataObj(index, 'fluorMetaData');
                    obj.baseDir = procMan.rawFluorDir;
                    obj.filePath = fmd.fluorFileName;
                    obj.numericData = cat(3, fmd.avgImgMC.channel{1}, fmd.avgImgMC.channel{2}, fmd.avgImgMC.channel{3});
                    %obj.scaledImage = fmd.getScaledImage(true);

                otherwise
                    error(sprintf("Unrecognized image source. Try stack or video"))
            end
        end
        
        function data = getScaledImage(obj)
            IG = obj.numericData(:,:,1);
            IR = obj.numericData(:,:,2);
            
            IG = rescale(min(IG, quantile(IG, 0.99, 'all')));
            IR = rescale(min(IR, quantile(IR, 0.99, 'all')));
            IB = zeros(size(IG), 'single');
            data = im2single(IR + IG);
            %obj.scaledImage = cat(3, IR, IG, IB);
            %data = im2single(sum(obj.scaledImage, 3))opt;
        end
    end
    
    methods (Static) end
end