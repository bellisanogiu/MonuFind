function perform_image_retrieval(im_dir,file_ext,desc_name,do_spatial_info,VC,nwords_codebook,norm_bof_hist,bof_train,labels_train,classes,desc_train)
%     d = dir(image_dir);
%     d = d(3:end); %remove . and ..
    
    dd = dir(fullfile(im_dir,'*.jpg'));
    
    sample_extract_sift_features(im_dir,desc_name,do_spatial_info);
%     perform image retrieval
    
    for i = 1:length(dd)
        
        filePath = fullfile(im_dir,dd(i).name);
        I=imread(filePath);
        fprintf('Image %s loaded with success\n',filePath);
        
        [desc_sample] = sample_load_precomputed_features(filePath, file_ext, desc_name, do_spatial_info);
        
%       Feature visualization
%         feature_visualizer(desc_sample,1);
        
        [desc_sample] = sample_feature_quantization(desc_sample, VC);
        
        num_words = 10;
%         visual_word_visualizer(num_words, desc_sample);
        
        [desc_sample] = sample_compute_norm_histgrm(VC, desc_sample, nwords_codebook, norm_bof_hist);
        
        % Concatenate bof-histograms into training and test matrices 
        bof_sample=cat(1,desc_sample.bof);
        
        % Construct label Concatenate bof-histograms into training and test matrices 
        labels_sample = cat(1,desc_sample.class);    
        
        bof_chi2dist = zeros(size(bof_sample,1),size(bof_train,1));
    
        % bof_chi2dist = slmetric_pw(bof_train, bof_test, 'chisq');
        for j = 1:size(bof_sample,1)
            for k = 1:size(bof_train,1)
                bof_chi2dist(j,k) = chi2(bof_sample(j,:),bof_train(k,:)); 
            end
        end
        
        % Nearest neighbor classification (1-NN) using Chi2 distance
        [mv,mi] = min(bof_chi2dist,[],2);
        bof_chi2lab = labels_train(mi);   
        fprintf('The choosen image:%s has been classified as: %s\n',filePath,classes{bof_chi2lab});
        
        num_img = 10
        [fst_values, fst_ind] = mink(bof_chi2dist,num_img);
        
        figure;
        for im=1:num_img
            subplot(2,num_img/2,im);
            I = imread(desc_train(fst_ind(im)).imgfname);
            showimage(I);
            im_label = labels_train(fst_ind(im));
            title(sprintf('Image %d - Category: %s',im,classes{im_label}))
        end
        
%          imgmiss={};
%     if length(indmiss)
%         for j=1:length(indmiss)
%             imgmiss{end+1}=imread(desc_test(indmiss(j)).imgfname);
%         end
%         subplot(1,2,2), showimage(combimage(imgmiss,[],1))
%         title(sprintf('%d Miss-classified %s images',length(indmiss),classes{i}))
%     end
        
        
        
%         acc=sum(bof_chi2lab==labels_test)/length(labels_test);
%         fprintf('*** NN Chi-2 ***\nAccuracy = %1.4f%% (classification)\n',acc*100);
        
%       extract the first 20 images from bof_chi2dist and then perform SVM.
        
%         [precomp_chi2_svm_lab,conf] = SVM_CHI2_classification(bof_train, bof_sample, labels_train, labels_sample);
%         method_name='SVM Chi2';
        % Compute classification accuracy
%         [method_name,acc] = compute_accuracy(data,labels_test,precomp_chi2_svm_lab,classes,method_name,desc_test,...
%                           visualize_confmat & have_screen,... 
%                           visualize_res & have_screen);
        
    end
    
    