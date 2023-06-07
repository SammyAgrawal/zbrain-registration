function regions = getBrainRegion(x, y, z)
% eventually, using registraton this is what we want. Map coordinates to
% fixed reference frame (Z Atlas) and access annotations to see brain
% regions of specific cell. This function loads the Z Brain annotations and
% 
load('MaskDatabase.mat')
% voxel physical size of 0.798 um (x/y) and 2um (z).
height = 1406; width=621; Zs = 138; % for some reason, not loaded in line 6
regions = []; % store all matching regions
[~,  numRegions] = size(MaskDatabaseNames);
for i = 1:numRegions % manually iterate through every region (TODO improve)
    region = full(MaskDatabase(:,i));
    region = reshape(region, height, width, Zs); % reshape to ref coords
    if(region(x,y,z)) % is boolean array, so indexing cell position
        regions = [regions i]; % add to list (can be in multiple)
    end
end
regions = MaskDatabaseNames(regions);
end