function data = create_dataset_split_kfold_1d(main_dir,kfold,file_ext)

category_dirs = dir(main_dir);
category_dirs(~cellfun(@isempty, regexp({category_dirs.name}, '\.*')))=[];
category_dirs(strcmp({category_dirs.name},'split.mat'))=[]; 

nr_directory = length(category_dirs); % 12

for c = 1:nr_directory % 1:12
    imgdir = dir(fullfile(main_dir,category_dirs(c).name, ['*.' file_ext]));
    nr_file = length(imgdir); % file per directory-label
    nr_file_group = floor(nr_file / kfold); % file per ogni k-fold
    ids = randperm(nr_file);     
    
    for ik = 1:kfold
        if (ik==1)
            start = 1;
            stop = nr_file_group;
        else
            start = stop+1;
            stop = start + nr_file_group - 1;
        end
        data(c).n_images = nr_file;
        data(c).classname = category_dirs(c).name;
        %data(c).files = {file(ids(start:stop)).name};
        data(c).files = {imgdir(:).name};
        
        data(c).train_id = false(1,data(c).n_images);
        data(c).train_id(ids(start:stop))=true;
       
        data(c).test_id = false(1,data(c).n_images);
        data(c).test_id = ~data(c).train_id;
        
    end 
end
end