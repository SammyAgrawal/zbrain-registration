function valueMatrix = similarityMatrix(stackImages, testZImages)
    %
    % 
    load("croppedZBrainImages.mat");
    %testZImages = [1, 20, 43, 54, 65, 72, 82, 90, 102, 115, 126]; % psuedo-randomly chosen to represent different parts of brain
    %stackImages = 10 * (1:12);
    
    % define 2-D registration parameters
    [optimizer, metric] = imregconfig('multimodal');
    % optimizer.GrowthFactor = 1.005;
    % optimizer.Epsilon = 1.5e-8;
    % optimizer.InitialRadius = 6.25e-4;
    optimizer.InitialRadius = 0.001;
    optimizer.MaximumIterations = 100;

    valueMatrix = zeros(length(stackImages), length(testZImages));

    for i = 1:length(stackImages)
        for j=1:length(testZImages) % eventually going to be entire ZBrainStack
            disp(num2str(i) + " " + num2str(j));
            regImg = RegistrationImage(stackImages(i), "stack", "caudal");
            zImage = ZBrainImage(testZImages(end + 1 - j));
            target = zImage.cropToFit(regImg, true, false); % for now, manual crop
            % affine transformation is most general LT, allowing for:
            % translation, rotation, scale, and shear. 
            source = regImg.getScaledImage(); 
            tform = imregtform(source, target, 'affine', optimizer, metric); % stores 3x3 transformation matrix to align Rimg to Z atlas target
            sourceRegistered = imwarp(source, tform, 'OutputView', imref2d(size(target)));
            %sourceRegistered = imregister(source, target, 'affine', optimizer, metric, 'DisplayOptimization', false);
            %sourceResized = imresize(regImg.getScaledImage(), size(target)); resizeRegistered = imregister(sourceResized, target, 'affine', optimizer, metric);
           
            %similarity = similaritytMetric(source, target);
            valueMatrix(i,j) = ssim(sourceRegistered, target);
        end
    end
end