% Read reference brain stack
stackFileName = "E:/workspace/Z-Brain-master/StackGrab_221021_175926.tif"; % video 
fileInfo = imfinfo(stackFileName); % array of structs
numSlices = length(fileInfo); % double, number of Z slices
for i = 1:numSlices
    imread(stackFileName, "Index", i); % 621 x 1406 x 3 uint8
end


% Test registration
% Image (index 72) from stackFileName, separately saved. 621 x 1406 x 3 uint8
ref = imread("E:/workspace/Z-Brain-master/AnatomySliceGrab_221021_173545.tif");
% Focus in on rostral area, manually cropped Z brain image
target = ref(150:450, 1:600, 1);

% select high res image from stack
highResStackDir = "E:/rawData/2019_08_21/fluor/stack_caudal_0";
index = "17.tif";
source2 = imread(highResStackDir + index);


fileNumbers = [10];
procMan = ProcessingManager("E:/", "2019_08_21", "rostral", fileNumbers);

[optimizer, metric] = imregconfig('multimodal');
% optimizer.GrowthFactor = 1.005;
% optimizer.Epsilon = 1.5e-8;
% optimizer.InitialRadius = 6.25e-4;
optimizer.InitialRadius = 0.001;
optimizer.MaximumIterations = 100;


for i = fileNumbers
    % 256 x 512 x 3 3-channel array
    I = procMan.getDataObj(i, 'fluorMetaData').getScaledImage(true); % getScaled makes from 0 to 1; true specifies motion correction in fmd object (from video)
    source = sum(I, 3);

    tform = imregtform(source, target, 'affine', optimizer, metric); % stores 3x3 transformation matrix to align Rimg to Z atlas target
    movingRegistered = imwarp(source, tform, 'OutputView', imref2d(size(target)));

    figure
    subplot(4,1,1);
    imshow(source);
    subplot(4,1,2);
    imshow(target);
    subplot(4,1,3);
    imshow(movingRegistered);
    subplot(4,1,4);
    imshowpair(target, movingRegistered);
end
