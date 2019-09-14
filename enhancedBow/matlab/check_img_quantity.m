function result = check_img_quantity(num_tot_img, main_dir, file_ext)
    category_dirs = dir(main_dir);
    result = true;

    %remove '..' and '.' directories
    category_dirs(~cellfun(@isempty, regexp({category_dirs.name}, '\.*')))=[];
    category_dirs(strcmp({category_dirs.name},'split.mat'))=[]; 
    
    for c = 1:length(category_dirs)
        if isdir(fullfile(main_dir,category_dirs(c).name)) && ~strcmp(category_dirs(c).name,'.') ...
                && ~strcmp(category_dirs(c).name,'..')
            imgdir = dir(fullfile(main_dir,category_dirs(c).name, ['*.' file_ext]));
            
            if length(imgdir) < num_tot_img
                  fprintf('The directory %s does not contain %d images, try to choose another split values', category_dirs(c).name, num_tot_img);
                  result = false;
            end
        end
    end

    