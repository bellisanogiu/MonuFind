% SVM classification (using libsvm)
%
% Use cross-validation to tune parameters:
% - the -v 5 options performs 5-fold cross-validation, this is useful to tune 
% parameters
% - the result of the 5 fold train/test split is averaged and reported
%
% example: for the parameter C (soft margin) use log2space to generate 
%          (say 5) different C values to test
%          xval_acc=svmtrain(labels_train,bof_train,'-t 0 -v 5');
function [svm_lab] = SVM_linear_classification(bof_test, bof_train, labels_test, labels_train)
    % cross-validation
    C_vals=log2space(7,10,5);
    for i=1:length(C_vals)
        opt_string=['-t 0  -v 5 -c ' num2str(C_vals(i))];
        xval_acc(i)=svmtrain(labels_train,bof_train,opt_string);
    end
    
    %select the best C among C_vals and test your model on the testing set.
    [v,ind]=max(xval_acc);

    % train the model and test
    model=svmtrain(labels_train,bof_train,['-t 0 -c ' num2str(C_vals(ind))]);
    disp('*** SVM - linear ***');
    svm_lab=svmpredict(labels_test,bof_test,model);