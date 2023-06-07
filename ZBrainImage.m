classdef ZBrainImage
    %Z Brain Image Wrapper Image Class for Z Brain Images, registration
    %   Computes transforms and stores relevant file information
    
    properties
        baseDir
        fileInfo
        numSlicesInStack
        numericData
        index
        micronPerPixel
    end
    
    methods 
        function obj = ZBrainImage(index) % TO DO: add source argument that allows different Z Brains
            %ZBrainImage Construct an instance of this class
            %   Detailed explanation goes here
            obj.index = index;
            obj.baseDir = "E:/workspace/Z-Brain-master/StackGrab_221021_175926.tif";
            obj.fileInfo = imfinfo(obj.baseDir); % structs
            obj.numSlicesInStack = length(obj.fileInfo);
            obj.fileInfo = obj.fileInfo(index);
            obj.numericData = imread(obj.baseDir, index);
            obj.numericData = obj.numericData(:,:,1); % all three channels equivalent for all images
            
            % TO DO - load metadata and micron conversions (Alex Code)
            
            %zBrainMeta = grabMetaData(obj.baseDir,'isImageJFile',true,'checkIfScanImageFile',false);
            %ZBrainMicOverPix = [zBrainMeta.XMicPerPix,zBrainMeta.YMicPerPix,zBrainMeta.ZMicPerPlane];
            %ZBrainMicOverPix = round(ZBrainMicOverPix*10^3)/10^3;
        end
        
        function croppedImage = cropToFit(obj, source, manual, overwrite)
            %cropToFit given an RegistrationImage, automatically crops to find greatest
            %overlap. 
            if(manual)
                load("croppedZBrainImages.mat");
                if(ismember(obj.index, manuallyCropped) & ~overwrite)
                    % have already done once, can just recall
                    indices = uint16(croppedImages{obj.index});
                    croppedImage = im2single(obj.numericData(indices(1,1): indices(1,2), indices(2,1):indices(2,2)));
                else % either overwriting existing value or adding new one
                    if (~overwrite) % if adding new one, add to list of added
                        manuallyCropped(end+1) = obj.index;
                    end
                    figure
                    imshow(source.getScaledImage()); % show image registering to so crop correctly
                    title("Source Image");
                    figure
                    [croppedImage, rect] = imcrop(obj.numericData);
                    croppedImage = im2single(croppedImage);
                    % save indices to .mat file for access later. 
                    a = rect(2); b=rect(1); c=rect(2) + rect(4); d=rect(1)+rect(3);
                    croppedImages{obj.index} = uint16([a c; b d]);
                    save("croppedZBrainImages.mat", "manuallyCropped", "croppedImages"); % overwrites .mat file, saving new onecr
                end
                
            else
                %code for if not manual
                target = sum(source.scaledImage, 3); % want to crop the Z image so that it matches target
                
            end
        end
        
        function [x y] = cropTransform(obj, xcoords, ycoords)
            load("croppedZBrainImages.mat");
            croppedImage = obj.cropToFit(RegistrationImage(50, "stack", "caudal"), true, false);
            indices = double(croppedImages{obj.index});
            frame = imref2d(size(croppedImage));
            frame.XWorldLimits = indices(2,:) + 0.5;
            frame.YWorldLimits = indices(1,:) + 0.5;
            [x y] = intrinsicToWorld(frame, xcoords, ycoords);
        end
        
        function edges = edgeDetected(obj)
            img = obj.numericData;
            img(img<60) = 0;
            img(img>=60) = 1;
            % find edges
            edges = edge(img);
        end
        
    end
    
    methods (Static)
        function croppedImage = getCroppedImage(index, source, manual, overwrite)
            ZImage = ZBrainImage(index);
            croppedImage = ZImage.cropToFit(source, manual, overwrite);
        end
        
        function stack = getZBrainStack(source)
            % eventually, want source to specify which stack
            dir = "E:/workspace/Z-Brain-master/StackGrab_221021_175926.tif";
            numslices = length(imfinfo(dir)); % 138
            [height width, ~] = size(imread(dir));
            stack = single(zeros(height, width, numslices));
            for i = 1:numslices
                Z = ZBrainImage(i);
                stack(:,:,i) = Z.numericData;
            end
        end
        
        %function dimReduced = PCA(indices)
    end
end

