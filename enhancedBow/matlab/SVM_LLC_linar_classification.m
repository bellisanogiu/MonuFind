% LLC LINEAR SVM
function [svm_llc_lab] = SVM_LLC_linar_classification(labels_test, llc_test, labels_train, llc_train)
% cross-validation
    C_vals=log2space(7,10,5);
    for i=1:length(C_vals)
        opt_string=['-t 0  -v 5 -c ' num2str(C_vals(i))];
        xval_acc(i)=svmtrain(labels_train,llc_train,opt_string);
    end
    %select the best C among C_vals and test your model on the testing set.
    [v,ind]=max(xval_acc);

    % train the model and test
    model=svmtrain(labels_train,llc_train,['-t 0 -c ' num2str(C_vals(ind))]);
    disp('*** SVM - linear LLC max-pooling ***');
    svm_llc_lab=svmpredict(labels_test,llc_test,model);
    