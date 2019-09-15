function [desc_train, desc_test] = load_precomputed_features(data, file_ext, desc_name, dataset_dir, basepath, do_spatial_info, desc_train, desc_test)
% Load pre-computed SIFT features for training images

% The resulting structure array 'desc' will contain one
% entry per images with the following fields:
%  desc(i).r :    Nx1 array with y-coordinates for N SIFT features
%  desc(i).c :    Nx1 array with x-coordinates for N SIFT features
%  desc(i).rad :  Nx1 array with radius for N SIFT features
%  desc(i).sift : Nx128 array with N SIFT descriptors
%  desc(i).imgfname : file name of original image

lasti=1;
for i = 1:length(data)
     images_descs = get_descriptors_files(data,i,file_ext,desc_name,do_spatial_info,'train');
     for j = 1:length(images_descs) 
        fname = fullfile(basepath,'img',dataset_dir,data(i).classname,images_descs{j});
        fprintf('Loading %s \n',fname);
        tmp = load(fname,'-mat');
        tmp.desc.class=i;
%         tmp.desc.imgfname=regexprep(fname,['.' desc_name],'.jpg');
        if do_spatial_info
            base = strcat('_spinf.',desc_name);
            alter = strcat('.',file_ext);            
            tmp.desc.imgfname=strrep(fname,base,alter);
        else
            tmp.desc.imgfname=strrep(fname,desc_name,file_ext);
        end
        desc_train(lasti)=tmp.desc;
        desc_train(lasti).sift = single(desc_train(lasti).sift);
        lasti=lasti+1;
     end
end

% Load pre-computed SIFT features for test images 
lasti=1;
for i = 1:length(data)
     images_descs = get_descriptors_files(data,i,file_ext,desc_name,do_spatial_info,'test');
     for j = 1:length(images_descs) 
        fname = fullfile(basepath,'img',dataset_dir,data(i).classname,images_descs{j});
        fprintf('Loading %s \n',fname);
        tmp = load(fname,'-mat');
        tmp.desc.class=i;
%         tmp.desc.imgfname=regexprep(fname,['.' desc_name],'.jpg');
        if do_spatial_info
            base = strcat('_spinf.',desc_name);
            alter = strcat('.',file_ext);            
            tmp.desc.imgfname=strrep(fname,base,alter);
        else
            tmp.desc.imgfname=strrep(fname,desc_name,file_ext);
        end
        desc_test(lasti)=tmp.desc;
        desc_test(lasti).sift = single(desc_test(lasti).sift);
        lasti=lasti+1;
     end
end
