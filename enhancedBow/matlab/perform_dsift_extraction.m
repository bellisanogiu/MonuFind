function [sift, rad, c, r] = perform_dsift_extraction(scales, stride, img)

    % scale
    %scales = [16 24 32 48];        
    sift_cell = cell(1,length(scales));
    rad = cell(1,length(scales));
    gx = cell(1,length(scales));
    gy = cell(1,length(scales));
    
    for psize=1:length(scales)
        [sift_tmp,gx{psize},gy{psize}]=sp_dense_sift(img,stride,scales(psize));
        sift_cell{psize}=reshape(sift_tmp,[size(sift_tmp,1)*size(sift_tmp,2) size(sift_tmp,3)]);
        rad{psize} = scales(psize)*ones(1,size(sift_cell{psize},1))';
    end
    sift = cell2mat(sift_cell');

    rad = cell2mat(rad');
    [gx] = cellfun(@(C)(C(:)),gx,'UniformOutput',false); %make each grid  of coordinates in the cell a vector
    c = cell2mat(gx'); % generate vector of coordinates

    [gy] = cellfun(@(C)(C(:)),gy,'UniformOutput',false); %make each grid of coordinates in the cell a vector
    r = cell2mat(gy');  % generate vector of coordinates