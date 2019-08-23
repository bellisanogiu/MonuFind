% CHI-2 KERNEL (pre-compute kernel)
function [precomp_chi2_svm_lab,conf] = SVM_CHI2_classification(bof_train, bof_test, labels_train, labels_test)
    % compute kernel matrix
    Ktrain = kernel_expchi2(bof_train,bof_train);
    Ktest = kernel_expchi2(bof_test,bof_train);
    
    % cross-validation
    C_vals=log2space(2,10,5);
    for i=1:length(C_vals)
        opt_string=['-t 4  -v 5 -c ' num2str(C_vals(i))];
        xval_acc(i)=svmtrain(labels_train,[(1:size(Ktrain,1))' Ktrain],opt_string);
    end
    [v,ind]=max(xval_acc);

    % train the model and test
    model=svmtrain(labels_train,[(1:size(Ktrain,1))' Ktrain],['-t 4 -c ' num2str(C_vals(ind))] );
    % we supply the missing scalar product (actually the values of non-support vectors could be left as zeros.... 
    % consider this if the kernel is computationally inefficient.
    disp('*** SVM - Chi2 kernel ***');
    [precomp_chi2_svm_lab,conf]=svmpredict(labels_test,[(1:size(Ktest,1))' Ktest],model);

    