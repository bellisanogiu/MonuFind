function sample_extract_sift_features(im_dir,file_ext,do_spatial_info)

    if strcmp(file_ext,'dsift')
        % DENSE SIFT
        scales = [32];
        detect_features_dsift(im_dir,file_ext,do_spatial_info,scales);
    elseif strcmp(file_ext,'msdsift')
        % MULTI-SCALE DENSE SIFT
        scales = [16 24 32 48];
        detect_features_dsift(im_dir,file_ext,do_spatial_info,scales);
    elseif strcmp(file_ext,'sift')
        % SPARSE SIFT
        detect_features(im_dir,file_ext,do_spatial_info);
     end