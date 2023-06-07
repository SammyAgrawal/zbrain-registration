function [bestIndex, bestSimilarity, transformation] = registrationSimilarity(regImg)
% Returns most similar image in Z brain stack give Registration Image
%   
load("croppedZBrainImages.mat");
testZImages = manuallyCropped; % for now, only select out of images that have been manually cropped
% define 2-D registration parameters
[optimizer, metric] = imregconfig('multimodal');
% optimizer.GrowthFactor = 1.005;
% optimizer.Epsilon = 1.5e-8;
% optimizer.InitialRadius = 6.25e-4;
optimizer.InitialRadius = 0.001;
optimizer.MaximumIterations = 100;
bestSimilarity = 0;
bestIndex = -1;

for i= testZImages % eventually going to be entire ZBrainStack
   disp("Testing against new Zebrafish atlas image from ZBRAIN");
   disp(i);
    zImage = ZBrainImage(i);
    target = zImage.cropToFit(regImg, true, false); % for now, manual crop
    source = regImg.getScaledImage();
    % affine transformation is most general, allowing for translation,
    % rotation, scale, and shear. 
    transMat = imregtform(source, target, 'affine', optimizer, metric); % stores 3x3 transformation matrix to align fmd to Z atlas target
    movingRegistered = imwarp(source, transMat, 'OutputView', imref2d(size(target)));
    movingRegistered = imregister(source, target, 'affine', optimizer, metric, 'DisplayOptimization', true);
    similarity = ssim(movingRegistered, target);
    disp("SSIM Similarity between registration image and target; rescaled and target");
    disp(similarity);
    
    if(similarity > bestSimilarity)
        
        bestSimilarity = similarity;
        disp("New Best Similarity: " + num2str(bestSimilarity));
        bestIndex = i;
        transformation = transMat;
    end
    
    %{
    figure
    subplot(4,1,1);
    imshow(source);
    title("Stack image");
    subplot(4,1,2);
    imshow(target);
    title("Z Brain Image");
    subplot(4,1,3);
    imshow(movingRegistered);
    title("Registered Stack Image");
    subplot(4,1,4);
    imshowpair(target, movingRegistered);
    %}
    
end

end

