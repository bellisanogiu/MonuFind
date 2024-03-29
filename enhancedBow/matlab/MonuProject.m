    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ICPR 2014 Tutorial                                                     %
%  Hands on Advanced Bag-of-Words Models for Visual Recognition           %
%                                                                         %
%  Instructors:                                                           %
%  L. Ballan                                                              %
%  L. Seidenari                                                           %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%   BOW pipeline: Image classification using bag-of-features

%   Part 1:  Load and quantize pre-computed image features                %
%   Part 2:  Represent images by histograms of quantized features         %
%   Part 3:  Classify images with nearest neighbor classifier             %

clear;
close all;
clc

%% **** INITIALIZATION ****

% DATASET
% dataset_dir='4_ObjectCategories';
% dataset_dir='12_CagliariMonuments';
dataset_dir='13_CagliariMonuments';
%dataset_dir = '15_ObjectCategories';

% RETRIEVAL
retrieval_dir = 'imageSamples';

% FEATURES extraction methods 

% 'sift' for sparse features detection 
% (SIFT descriptors computed at Harris-Laplace keypoints)
% 'dsift' for dense features detection
% (SIFT descriptors computed at a grid of overlapped patches)

%desc_name = 'sift';
%desc_name = 'dsift';
%desc_name = 'msdsift';

desc_name = ["msdsift"];

% FLAGS
% Initial settings
do_feat_extraction = 1;
do_split_sets = 0;

do_form_codebook = 0;
do_feat_quantization = 1;

do_cross_validation = 0;
do_spatial_info = 1;

% Classifier selection
do_L2_NN_classification = 0;
do_svm_linar_classification = 0;
do_chi2_NN_classification = 1;
do_svm_llc_linar_classification = 0;
do_svm_precomp_linear_classification = 0;
do_svm_inter_classification = 0;
do_svm_chi2_classification = 1;

% Initialization of variables
steps = 1; % nr.passi di cui si incrementa il codeword
incr = 250; % incremento desiderato per il codeword
%nwords = zeros(steps,1);
list_method = {};

L2_NN_acc = zeros(steps,1);
svm_linar_acc = zeros(steps,1);
chi2_NN_acc = zeros(steps,1);
svm_llc_linar_acc = zeros(steps,1);
svm_precomp_linea_acc = zeros(steps,1);
svm_inter_acc = zeros(steps,1);
svm_chi2_acc = zeros(steps,1);

% Visualization options
visualize_feat = 0; % error!
visualize_words = 0; % error!
visualize_confmat = 0; % confusion matrix
visualize_res = 0;
have_screen = isempty(getenv('DISPLAY'));

% PATHS
basepath = '..';
wdir = pwd;
libsvmpath = [wdir(1:end-6) fullfile('lib','libsvm-3.11','matlab')];
% add library folder to search path
addpath(libsvmpath)

% BOW PARAMETERS
max_km_iters = 50; % maximum number of iterations for k-means
nfeat_codebook = 60000; % number of descriptors used by k-means for the codebook generation
norm_bof_hist = 1;

% number of images selected for training (e.g. 30 for Caltech-101)
num_train_img = 49;
% number of images selected for test (e.g. 50 for Caltech-101)
num_test_img = 1;
% sum of training and test images split values
num_tot_img = num_train_img + num_test_img;

% table of result
TotSiftTable = table();

% image file extension
file_ext='jpg';

split_valid = check_img_quantity(num_tot_img, fullfile(basepath, 'img', dataset_dir), file_ext);

if split_valid
    
    sift_mods = size(desc_name,2); 
    % Create a new dataset split
    file_split = 'split.mat';
    if do_cross_validation
        split_steps = num_tot_img / num_test_img;
    else
        split_steps = 1;
    end
    
    for s = 1:(split_steps)     
        
        if do_cross_validation
            % Create a new dataset split
            base_name ='split';
            ext = '.mat';
            sep ='_';
            file_split = strcat(base_name,sep,int2str(num_test_img),sep,int2str(s),ext);
        end
        
        if do_split_sets
            data = create_dataset_split_structure(fullfile(basepath, 'img', dataset_dir), num_train_img, num_test_img, file_ext, do_cross_validation, s);
            save(fullfile(basepath,'img',dataset_dir,file_split),'data');
        else
             if exist(fullfile(basepath, 'img',dataset_dir,file_split), 'file') == 2
                 load(fullfile(basepath,'img',dataset_dir,file_split));
             else
                 data = create_dataset_split_structure(fullfile(basepath, 'img', dataset_dir), num_train_img, num_test_img, file_ext, do_cross_validation, s);
                 save(fullfile(basepath,'img',dataset_dir,file_split),'data');
            end
        end

        classes = {data.classname}; % create cell array of class name strings

            

        for s_iter = 1:sift_mods

            % number of codewords (i.e. K for the k-means algorithm)
            nwords_codebook = 700;

            % Extract SIFT features fon training and test images
            if do_feat_extraction
                extract_sift_features(fullfile('..','img',dataset_dir),desc_name(s_iter),do_spatial_info);
            end

            %% **** PART 1: quantize pre-computed image features ****

            [desc_train, desc_test] = load_precomputed_features(data, file_ext, desc_name(s_iter), dataset_dir, basepath, do_spatial_info);

            if (visualize_feat && have_screen)
                num_images = 10;
                feature_visualizer(desc_train, num_images);
            end

            for iter = 1:steps % calculate steps

                % Build visual vocabulary using k-means
                if do_cross_validation
                    fileName = strcat('vocab_crsval', desc_name(s_iter), int2str(nwords_codebook), '.mat');
                else
                    fileName = strcat('vocab', desc_name(s_iter), int2str(nwords_codebook), '.mat');
                end
                
                if do_form_codebook
                    [VC] = visual_vocab_builder(data, desc_train, num_train_img, nfeat_codebook, nwords_codebook, max_km_iters);            
                    save(fileName,'VC');
                else            
                    if exist(fileName, 'file') == 2
                        load(fileName,'VC');
                    else
                        [VC] = visual_vocab_builder(data, desc_train, num_train_img, nfeat_codebook, nwords_codebook, max_km_iters);            
                        save(fileName,'VC');
                    end
                end

                % Quantization: assign each feature to the most representative visual word
                if do_feat_quantization
                    [desc_train, desc_test] = feature_quantization_executor(desc_train, desc_test, VC);
                end

                %  Visualize visual words (i.e. clusters)
                if (visualize_words && have_screen)
                    num_words = 10;
                    visual_word_visualizer(num_words, desc_train);
                end


                %% **** PART 2: represent images with BOF histograms ****

                % Bag-of-Features image classification 
                [desc_train, desc_test] = compute_norm_histogram(VC, desc_train, desc_test, nwords_codebook, norm_bof_hist);

                %%%%LLC Coding
                if do_svm_llc_linar_classification
                    for i=1:length(desc_train)
                        disp(desc_train(i).imgfname);
                        desc_train(i).llc = max(LLC_coding_appr(VC,desc_train(i).sift)); %max-pooling
                        desc_train(i).llc=desc_train(i).llc/norm(desc_train(i).llc); %L2 normalization
                    end
                    for i=1:length(desc_test) 
                        disp(desc_test(i).imgfname);
                        desc_test(i).llc = max(LLC_coding_appr(VC,desc_test(i).sift));
                        desc_test(i).llc=desc_test(i).llc/norm(desc_test(i).llc);
                    end
                end
                %%%%end LLC coding


                %% **** PART 3: image classification ****

                % Concatenate bof-histograms into training and test matrices 
                bof_train=cat(1,desc_train.bof);
                bof_test=cat(1,desc_test.bof);
                if do_svm_llc_linar_classification
                    llc_train = cat(1,desc_train.llc);
                    llc_test = cat(1,desc_test.llc);
                end

                % Construct label Concatenate bof-histograms into training and test matrices 
                labels_train=cat(1,desc_train.class);
                labels_test=cat(1,desc_test.class);

                % L2 NN classification
                if do_L2_NN_classification
                    [bof_l2lab] = L2_NN_classification(bof_test, bof_train, labels_test, labels_train);

                    method_name='NN L2';
                    % Compute classification accuracy
                    [method_name, acc] = compute_accuracy(data,labels_test,bof_l2lab,classes,method_name,desc_test,...
                                      visualize_confmat & have_screen,... 
                                      visualize_res & have_screen);

                    L2_NN_acc(iter) = acc;    
                end

                % LINEAR SVM
                if do_svm_linar_classification
                    [svm_lab] = SVM_linear_classification(bof_test, bof_train, labels_test, labels_train);

                    method_name='SVM linear';
                    % Compute classification accuracy
                    [method_name, acc] = compute_accuracy(data,labels_test,svm_lab,classes,method_name,desc_test,...
                                      visualize_confmat & have_screen,... 
                                      visualize_res & have_screen);

                    SVM_linar_acc(iter) = acc;
                end

                % CHI2 NN classification
                if do_chi2_NN_classification
                    [bof_chi2lab] = CHI2_NN_classification(bof_test, bof_train, labels_test, labels_train);

                    method_name='NN Chi-2';
                    % Compute classification accuracy
                    [method_name, acc] = compute_accuracy(data,labels_test,bof_chi2lab,classes,method_name,desc_test,...
                                      visualize_confmat & have_screen,... 
                                      visualize_res & have_screen);

                    chi2_NN_acc(iter) = acc;
                end

                % LLC LINEAR SVM
                if do_svm_llc_linar_classification
                    [svm_llc_lab] = SVM_LLC_linar_classification(labels_test, llc_test, labels_train, llc_train);

                    method_name='llc+max-pooling';
                    [method_name, acc] = compute_accuracy(data,labels_test,svm_llc_lab,classes,method_name,desc_test,...
                                      visualize_confmat & have_screen,... 
                                      visualize_res & have_screen);

                    svm_llc_linar_acc(iter) = acc;
                end

                % SVM image classification with pre-computed LINEAR KERNELS    
                if do_svm_precomp_linear_classification
                    [precomp_svm_lab] = SVM_PC_linear_classification(bof_train, bof_test, labels_test, labels_train);
                    method_name='SVM precomp linear';
                    % Compute classification accuracy
                    [method_name, acc] = compute_accuracy(data,labels_test,precomp_svm_lab,classes,method_name,desc_test,...
                                      visualize_confmat & have_screen,... 
                                      visualize_res & have_screen);
                    % result is the same??? must be!

                    svm_precomp_linea_acc(iter) = acc;
                end

                % Non-linear SVM with the histogram intersection kernel
                if do_svm_inter_classification
                    [precomp_ik_svm_lab,conf] = SVM_inter_classification(bof_train, bof_test, labels_train, labels_test);
                    method_name='SVM IK';
                    % Compute classification accuracy
                    [method_name, acc] = compute_accuracy(data,labels_test,precomp_ik_svm_lab,classes,method_name,desc_test,...
                                      visualize_confmat & have_screen,... 
                                      visualize_res & have_screen);

                    svm_inter_acc(iter) = acc;
                end

                % CHI-2 KERNEL (pre-compute kernel)
                if do_svm_chi2_classification
                    [precomp_chi2_svm_lab,conf] = SVM_CHI2_classification(bof_train, bof_test, labels_train, labels_test);
                    method_name='SVM Chi2';
                    % Compute classification accuracy
                    [method_name,acc] = compute_accuracy(data,labels_test,precomp_chi2_svm_lab,classes,method_name,desc_test,...
                                      visualize_confmat & have_screen,... 
                                      visualize_res & have_screen);
                    svm_chi2_acc(iter) = acc;
                end

                nwords(iter) = nwords_codebook;
                % number of codewords increment
                nwords_codebook = nwords_codebook + incr;
            end
            
            siftMode = ones(size(nwords,2),1)*s_iter;
            splitIndicator = ones(size(nwords,2),1)*s;
            
            T.SplitNumber = splitIndicator;
            T.SiftMode = siftMode;
            T.WordsNumber = nwords';            
            T.NNCHI2 = chi2_NN_acc;            
            T.SVMCHI2 = svm_chi2_acc;
            SiftModeTable = struct2table(T);
                        
            TotSiftTable = [TotSiftTable ; SiftModeTable];
            
            if (desc_name(s_iter)=="sift")                
                sift_chi2_NN = chi2_NN_acc;
                sift_svm_chi2 = svm_chi2_acc;
            end
            if (desc_name(s_iter)=="dsift")                
                dsift_chi2_NN = chi2_NN_acc;
                dsift_svm_chi2 = svm_chi2_acc;
            end
            if (desc_name(s_iter)=="msdsift")
                msdsift_chi2_NN = chi2_NN_acc;
                msdsift_svm_chi2 = svm_chi2_acc;
            end
        end    
    end
    
    % ---Show table---
    TotSiftTable
    if do_cross_validation == 0     
        % ---Plot bar---
        for s_iter = 1:sift_mods
            
            figure(s_iter+50);
            for m = 1:steps 
                if (desc_name(s_iter)=="sift")  
                    iterData = [sift_chi2_NN(m), sift_svm_chi2(m)];
                end
                if (desc_name(s_iter)=="dsift")
                    iterData = [dsift_chi2_NN(m), dsift_svm_chi2(m)];
                end
                if (desc_name(s_iter)=="msdsift")
                    iterData = [msdsift_chi2_NN(m), msdsift_svm_chi2(m)];
                end                
                ax1 = subplot(1,steps,m);
                c = categorical({'NN-CHI2' 'SVM-CHI2'});
                b = bar(ax1,c,iterData);
                b.FaceColor = 'flat';
                b.CData(1,:) = [1,0,0];
                b.CData(2,:) = [0,1,0];
                ylim([0 1])
                titleIterBar = sprintf('%s - Accuracy, DIM = %d', desc_name(s_iter), nwords(m));
                title(titleIterBar)
            end             
        end
        
    end
     
%     Perform image retrieval
     retrieval_path = fullfile(basepath, 'img', retrieval_dir);
     perform_image_retrieval(retrieval_path,file_ext,desc_name(1),do_spatial_info,VC,nwords(iter),norm_bof_hist,bof_train,labels_train,classes,desc_train);
end


% Create structure
% for i = 1:steps
%     E(i).type = 'chi2_NN';
%     E(i).acc = chi2_NN_acc(i);
%     E(i).vwords = nwords(i);
%     R(i).type = 'svm_inter';
%     R(i).acc = svm_inter_acc(i);
%     R(i).vwords = nwords(i);
%     W(i).type = 'svm chi2';
%     W(i).acc = svm_chi2_acc(i);
%     W(i).vwords = nwords(i);
% end

% Create cumulative table from structure
% T1 = struct2table(E);
% T2 = struct2table(R);
% T3 = struct2table(W);
% tableTotal = [T1; T2; T3];

% Sort table (Acc)
% tableTotal_sort = sortrows(tableTotal,acc);