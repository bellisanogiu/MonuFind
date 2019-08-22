% SVM image classification with pre-computed LINEAR KERNELS
%     Compute the kernel matrix (i.e. a matrix of scalar products) and
%     use the LIBSVM precomputed kernel interface.
%     This should produce the same results.
function [precomp_svm_lab] = SVM_PC_linear_classification(bof_train, bof_test, labels_test, labels_train)
% compute kernel matrix
    Ktrain = bof_train*bof_train';
    Ktest = bof_test*bof_train';

    % cross-validation
    C_vals=log2space(7,10,5);
    for i=1:length(C_vals)
        opt_string=['-t 4  -v 5 -c ' num2str(C_vals(i))];
        xval_acc(i)=svmtrain(labels_train,[(1:size(Ktrain,1))' Ktrain],opt_string);
    end
    [v,ind]=max(xval_acc);
    
    % train the model and test
    model=svmtrain(labels_train,[(1:size(Ktrain,1))' Ktrain],['-t 4 -c ' num2str(C_vals(ind))]);
    % we supply the missing scalar product (actually the values of 
    % non-support vectors could be left as zeros.... 
    % consider this if the kernel is computationally inefficient.
    disp('*** SVM - precomputed linear kernel ***');
    precomp_svm_lab=svmpredict(labels_test,[(1:size(Ktest,1))' Ktest],model);
    