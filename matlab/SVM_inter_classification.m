% INTERSECTION KERNEL (pre-compute kernel)
% Non-linear SVM with the histogram intersection kernel!
function [precomp_ik_svm_lab,conf] = SVM_inter_classification(bof_train, bof_test, labels_train, labels_test)

    Ktrain=zeros(size(bof_train,1),size(bof_train,1));
    for i=1:size(bof_train,1)
        for j=1:size(bof_train,1)
            hists = [bof_train(i,:);bof_train(j,:)];
            Ktrain(i,j)=sum(min(hists));
        end
    end

    Ktest=zeros(size(bof_test,1),size(bof_train,1));
    for i=1:size(bof_test,1)
        for j=1:size(bof_train,1)
            hists = [bof_test(i,:);bof_train(j,:)];
            Ktest(i,j)=sum(min(hists));
        end
    end

    % cross-validation
    C_vals=log2space(3,10,5);
    for i=1:length(C_vals)
        opt_string=['-t 4  -v 5 -c ' num2str(C_vals(i))];
        xval_acc(i)=svmtrain(labels_train,[(1:size(Ktrain,1))' Ktrain],opt_string);
    end
    [v,ind]=max(xval_acc);

    % train the model and test
    model=svmtrain(labels_train,[(1:size(Ktrain,1))' Ktrain],['-t 4 -c ' num2str(C_vals(ind))] );
    % we supply the missing scalar product (actually the values of non-support vectors could be left as zeros.... consider this if the kernel is computationally inefficient.
    disp('*** SVM - intersection kernel ***');
    [precomp_ik_svm_lab,conf]=svmpredict(labels_test,[(1:size(Ktest,1))' Ktest],model);
    
    
    