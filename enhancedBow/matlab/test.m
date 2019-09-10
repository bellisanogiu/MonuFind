dataset_dir='12_CagliariMonuments';

% PATHS
basepath = '..';
wdir = pwd;
libsvmpath = [wdir(1:end-6) fullfile('lib','libsvm-3.11','matlab')];
% add library folder to search path
addpath(libsvmpath)

num_train_img = 30;
% number of images selected for test (e.g. 50 for Caltech-101)
num_test_img = 20;

% image file extension
file_ext='jpg';

ds_dir = fullfile(basepath, 'img', dataset_dir);

% TEST
 data = create_dataset_split_structure(fullfile(basepath, 'img', dataset_dir), num_train_img, num_test_img, file_ext);
 
 main_dir = ds_dir;
 category_dirs = dir(main_dir);
 
 category_dirs(~cellfun(@isempty, regexp({category_dirs.name}, '\.*')))=[];
 category_dirs(strcmp({category_dirs.name},'split.mat'))=[]; 
 
 for c = 1:length(category_dirs)
     
 end
 