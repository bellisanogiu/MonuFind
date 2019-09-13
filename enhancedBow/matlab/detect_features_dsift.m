% function [] = detect_features_dsift(im_dir);
%
% Detect and describe features for all images in a directory 
%
% IN:   im_dir    ... directory of images (assumed to be *.jpg)
%       file_ext  ... a string (e.g. 'sift')       
%
% OUT:  for each image, a matlab file *.file_ext is created in directory 
%       im_dir, SIFT descriptors.
%
% The output Matlab file contains structure "desc" with fileds:
%
%  desc.r    ... row index of each feature
%  desc.c    ... column index of each feature
%  desc.rad  ... radius (scale) of each feature
%  desc.sift ... SIFT descriptor for each feature
%
%

function detect_features_dsift(im_dir,file_ext,do_spatial_info,varargin)
    
    stride = 6;
    do_resizeimage = 1;
    
    dd = dir(fullfile(im_dir,'*.jpg'));
    if nargin < 4
        scales = [32];
    else
        scales = cell2mat(varargin(1));
    end

%     parfor i = 1:length(dd)
    for i = 1:length(dd)
    
        fname = fullfile(im_dir,dd(i).name);
        I=imread(fname);
%         fname_out = [fname(1:end-3),file_ext];
        fname_out = strcat(fname(1:end-3),file_ext);
        if exist(fname_out,'file')
            fprintf('File exists! Skipping %s \n',fname_out);
            continue;
        end

        %resize the max dimension down to 300
        if do_resizeimage
            I = rescale_max_size(I, 300, 1);
            tmp_img = fullfile(im_dir,dd(i).name);
            tmp_img = [tmp_img(1:end-4),'_tmp.jpg'];
            %tmp_img = [tmp_img(1:end-4),'.jpg'];
            %imwrite(I, tmp_img, 'jpg', 'quality', 90);
        end
        
        fprintf('Detecting and describing features: %s \n',fname_out);

        fname_txt = [fname(1:end-3) 'txt' ];
        
        [sift, rad, c, r] = perform_dsift_extraction(scales, stride, I);
        
        if do_spatial_info
            
            fprintf('Computing spatial information...\n');
            
            [rows, columns, nColCnl] = size(I);
            width = columns/2;
            height = rows/2;

            I1 = imcrop(I, [0 0 width height]);
            I2 = imcrop(I, [width+1 0 width-1 height]);
            I3 = imcrop(I, [0 height+1 width height-1]);
            I4 = imcrop(I, [width+1 height+1 width-1 height-1]);
            
            [sift1, rad1, c1, r1] = perform_dsift_extraction(scales, stride, I1);
            [sift2, rad2, c2, r2] = perform_dsift_extraction(scales, stride, I2);
            [sift3, rad3, c3, r3] = perform_dsift_extraction(scales, stride, I3);
            [sift4, rad4, c4, r4] = perform_dsift_extraction(scales, stride, I4);
            
            sift = [sift;sift1;sift2;sift3;sift4];
            rad = [rad;rad1;rad2;rad3;rad4];
            c = [c;c1;c2;c3;c4];
            r = [r;r1;r2;r3;r4];
            
        end
        
        desc = struct('sift',uint8(512*sift),'r',r,'c',c,'rad',rad);

        iSave(desc,fname_out);
    end

end


function iSave(desc,fName)
    save(fName,'desc');
end

