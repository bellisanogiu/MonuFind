function result = perform_image_retrieval(image_dir)
    d = dir(image_dir);
    d = d(3:end); %remove . and ..
    dd = dir(fullfile(d,'*.jpg'));
    
    for i = 1:length(dd)
        
        fname = fullfile(im_dir,dd(i).name);
        I=imread(fname);
        fprintf('Image %s loaded with success\n',fname);
        
        
    end