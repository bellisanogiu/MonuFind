%This function takes as input the directory containing the dataset.
%For example if we have 4 categories, say airplanes,faces,motorbikes and
%cars directory structure should be:   ./caltech4
%                                      ./caltech4/airplanes
%                                      ./caltech4/faces
%                                      ./caltech4/motorbikes
%                                      ./caltech4/cars
% This functions creates a random split of the dataset. For each category 
% selects Ntrain training images and min(N-Ntrain,Ntest) test images, where
% N is the amount of images of a given category.
% outputs a structure array with the following fields
%    n_images: 1074
%    classname: 'airplanes'; 
%    files: {1x1074 cell}; cell array with file names withouth path, e.g. img_100.jpg
%    train_id: [1x1074 logical]; Boolean array indicating training files
%    test_id: [1x1074 logical];  Boolean array indicating test files
% If the parameter do_cross_validation is set to true this function create
% the split considering the position (pos) to assign train and test images
function data = create_dataset_split_structure(main_dir,Ntrain,Ntest,file_ext, do_cross_validation, pos)
    category_dirs = dir(main_dir);
    
    if do_cross_validation
        Ntot = Ntrain + Ntest;
        stop = pos * Ntest;
        start = stop - (Ntest - 1);
    end
 
    %remove '..' and '.' directories
    category_dirs(~cellfun(@isempty, regexp({category_dirs.name}, '\.*')))=[];
    category_dirs(strcmp({category_dirs.name},'split.mat'))=[];
    
    for c = 1:length(category_dirs)
        if isdir(fullfile(main_dir,category_dirs(c).name)) && ~strcmp(category_dirs(c).name,'.') ...
                && ~strcmp(category_dirs(c).name,'..')
            imgdir = dir(fullfile(main_dir,category_dirs(c).name, ['*.' file_ext]));
            
            data(c).n_images = length(imgdir);
            data(c).classname = category_dirs(c).name;
            data(c).files = {imgdir(:).name};
            
            if do_cross_validation
                data(c).test_id = false(1,data(c).n_images);
                data(c).test_id(start:stop) = true;
            
                data(c).train_id = false(1,data(c).n_images);
                data(c).train_id(1:Ntot) = true;            
                data(c).train_id(start:stop) = false;
            else
                ids = randperm(length(imgdir));
                data(c).train_id = false(1,data(c).n_images);
                data(c).train_id(ids(1:Ntrain))=true;

                data(c).test_id = false(1,data(c).n_images);
                data(c).test_id(ids(Ntrain+1:Ntrain+min(Ntest,data(c).n_images-Ntrain)))=true;
            end
        end
    end
end
