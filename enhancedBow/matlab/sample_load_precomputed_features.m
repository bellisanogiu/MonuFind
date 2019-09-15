function [desc_sample] = sample_load_precomputed_features(filePath, file_ext, desc_name, do_spatial_info)
% Load pre-computed SIFT features for sample images

% The resulting structure array 'desc' will contain one
% entry per images with the following fields:
%  desc(i).r :    Nx1 array with y-coordinates for N SIFT features
%  desc(i).c :    Nx1 array with x-coordinates for N SIFT features
%  desc(i).rad :  Nx1 array with radius for N SIFT features
%  desc(i).sift : Nx128 array with N SIFT descriptors
%  desc(i).imgfname : file name of original image

if do_spatial_info            
    base = strcat('.',file_ext);            
    alter = strcat('_spinf.',desc_name);
    fname=strrep(filePath,base,alter);
else
    fname=strrep(filePath,file_ext,desc_name);
end
fprintf('Loading %s \n',fname);
tmp = load(fname,'-mat');
tmp.desc.class=0;
tmp.desc.imgfname=filePath;
desc_sample=tmp.desc;
desc_sample.sift = single(desc_sample.sift);