classdef helperFuncs
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods 
    end
    
    methods (Static)
        function data = getStackSlice(index, channels, addTogether)
            % channel 2 is green; channel 1 is red (glutamergic more in specific regions);
            img = RegistrationImage(index, "stack", "caudal");
            IG = img.numericData(:,:,1);
            IR = img.numericData(:,:,2);
            IB = zeros(size(IG), 'single');
            
            IG = rescale(min(IG, quantile(IG, 0.99, 'all')));
            IR = rescale(min(IR, quantile(IR, 0.99, 'all')));
            scaledImage = cat(3, IR, IG, IB);
            data = scaledImage(:,:,channels); % grabs requested channels
            if (addTogether)
                data = sum(data, 3); % sums up channels into 2d image
            end
            figure; imshow(data);
            title("Caudal Stack, " + num2str(index) +"; Channels " + join(string(channels), " "));
        end
        
        function ZStackImage = getZImage(index)
            stackFileName = "E:/workspace/Z-Brain-master/StackGrab_221021_175926.tif"; % video 
            ZStackImage = imread(stackFileName, index);
            if isequal(ZStackImage(:,:,1), ZStackImage(:,:,2), ZStackImage(:,:,3))
                ZStackImage = ZStackImage(:,:,1);
            end
            %fileInfo = imfinfo(stackFileName); % array of structs
        end
        
        function croppedImage = addNewManualCropping(zIndex, caudalStackIndex)
            zImage = ZBrainImage(zIndex);
            source = RegistrationImage(caudalStackIndex, "stack", "caudal");
            croppedImage = zImage.cropToFit(source, true, true);
        end
        
        function croppedImage = getCropping(index)
            zImage = ZBrainImage(index);
            figure
            imshow(zImage.numericData);
            title("Uncropped Image")
            load("croppedZBrainImages.mat");
            if(ismember(index, manuallyCropped))
                indices = uint16(croppedImages{index});
                croppedImage = zImage.numericData(indices(1,1): indices(1,2), indices(2,1):indices(2,2));
            end
        end
        
        function [i,j] = displayMostSimilar(simMatrix, stackImages, testZImages)
            % given similarity matrix, isolates best alignment guess; picks
            % off most similar. Then plots results. 
            [i j] = find(simMatrix == max(simMatrix, [], "all"));
            i = stackImages(i); j = testZImages(j);
            regImg = RegistrationImage(i, "stack", "caudal"); zImage = ZBrainImage(j); 
            figure; montage({regImg.getScaledImage, zImage.numericData});
            title(sprintf("Best Fit: Caudal stack %d, Z Image %d", i, j));
            
        end
        
        function [i j valMat] = getMostSimilar(stackImages, testZImages)
            valMat = similarityMatrix(stackImages, testZImages);
            [i,j] = helperFuncs.displayMostSimilar(valMat, stackImages, testZImages);
        end
        
        function [best_k, highest_mean] = getBestDiagonal(mat)
            % returns diagonal with highest mean value
            [m, n] = size(mat);
            best_k = 0;
            highest_mean = -1;
            for k = 1-m:n-1
                d = diag(mat, k);
                avg = mean(d(d>0.01));
                if(avg > highest_mean) highest_mean = avg; best_k = k;  end
            end
        end
        
        function worldImage = plotWorldCanvas(image, frame)
            % given image and imref2d defining relation to world
            % coordinates, graphs. Defnitely very annoying brute force
            Z = ZBrainImage(5); worldImage = zeros(size(Z.numericData));
            [ysize, xsize] = size(image);
            for y = 1:ysize
                xIntrinsic = 1:xsize;
                yIntrinsic = repelem([y], length(xIntrinsic));
                [xWorld, yWorld] =  intrinsicToWorld(frame, xIntrinsic, yIntrinsic);
                worldImage(uint16(yWorld(1)), uint16(xWorld)) = image(y, :);
            end
            %figure; imshow(worldImage); 
        end
        
        function Q = principalComponentAnalysis(X, varargin)
            % X is a d x n matrix representing the set if vectors
            % we wish to project onto a lower dimensional subspace. n
            % vectors, each an element of Rd. 
            % Q is a d x k matrix storing the k principal components. To
            % reconstruct the projection matrix, use Q * Q^T. To get the
            % lower dimensional representation, get Q^T * x (kxd) (dx1)
            options = struct('k',2, 'meanNormalize', true);
            options = parseNameValueoptions(options,varargin{:});
            disp(options);
            if(options.meanNormalize)
                X = X - mean(X);
            end
            M = X * X';
        end
    end
end

