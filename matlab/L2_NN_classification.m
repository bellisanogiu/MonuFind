% NN classification
function [bof_l2lab] = L2_NN_classification(bof_test, bof_train, labels_test, labels_train)
% Compute L2 distance between BOFs of test and training images
    bof_l2dist=eucliddist(bof_test,bof_train);
    
    % Nearest neighbor classification (1-NN) using L2 distance
    [mv,mi] = min(bof_l2dist,[],2);
    bof_l2lab = labels_train(mi);  
    
    acc=sum(bof_l2lab==labels_test)/length(labels_test);
    fprintf('\n*** NN L2 ***\nAccuracy = %1.4f%% (classification)\n',acc*100);    