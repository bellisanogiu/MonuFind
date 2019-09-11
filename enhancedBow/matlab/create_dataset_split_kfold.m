function data = create_dataset_split_kfold(main_dir,kfold,file_ext)

% new
category_dirs = dir(main_dir);
category_dirs(~cellfun(@isempty, regexp({category_dirs.name}, '\.*')))=[];
category_dirs(strcmp({category_dirs.name},'split.mat'))=[]; 

nr_directory = length(category_dirs);

for c = 1:nr_directory
    file = dir(fullfile(main_dir,category_dirs(c).name, ['*.' file_ext]));
    nr_file = length(file);
    nr_file_group = floor(nr_file / kfold);
    ids = randperm(nr_file);     
    
    for ik = 1:kfold
        if (ik==1)
            start = 1;
            stop = nr_file_group;
        else
            start = stop+1;
            stop = start + nr_file_group - 1;
        end
        data(c,ik).n_images = nr_file_group;
        data(c,ik).classname = category_dirs(c).name;
        data(c,ik).files = {file(ids(start:stop)).name};
        
        data(c,ik).train_id = false(1,data(c).n_images);
        data(c,ik).train_id(ids(start:stop))=true;
       
        data(c,ik).test_id = false(1,data(c).n_images);
        data(c, ik).test_id = ~data(c,ik).train_id;
%         data(c,ik).test_id(ids(nr_file_group+1:nr_file_group+min(Ntest,data(c).n_images-Ntrain)))=true;
    end 
end
end