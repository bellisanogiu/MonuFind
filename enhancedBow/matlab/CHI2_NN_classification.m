% NN classification
function [bof_chi2lab] = CHI2_NN_classification(bof_test, bof_train, labels_test, labels_train)
% compute pair-wise CHI2
    bof_chi2dist = zeros(size(bof_test,1),size(bof_train,1));
    
    % bof_chi2dist = slmetric_pw(bof_train, bof_test, 'chisq');
    for i = 1:size(bof_test,1)
        for j = 1:size(bof_train,1)
            bof_chi2dist(i,j) = chi2(bof_test(i,:),bof_train(j,:)); 
        end
    end

    % Nearest neighbor classification (1-NN) using Chi2 distance
    [mv,mi] = min(bof_chi2dist,[],2);
    bof_chi2lab = labels_train(mi);

    acc=sum(bof_chi2lab==labels_test)/length(labels_test);
    fprintf('*** NN Chi-2 ***\nAccuracy = %1.4f%% (classification)\n',acc*100);
 