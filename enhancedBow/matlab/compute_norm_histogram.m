% Represent each image by the normalized histogram of visual
% word labels of its features. Compute word histogram H over 
% the whole image, normalize histograms w.r.t. L1-norm.
%
% TODO:
% 2.1 for each training and test image compute H. Hint: use
%     Matlab function 'histc' to compute histograms.
function [desc_train, desc_test] = compute_norm_histogram(VC, desc_train, desc_test, nwords_codebook, norm_bof_hist)

N = size(VC,1); % number of visual words

for i=1:length(desc_train) 
    visword = desc_train(i).visword;
    H = histc(visword,(1:nwords_codebook));
  
    % normalize bow-hist (L1 norm)
    if norm_bof_hist
        H = H/sum(H);
    end
    % save histograms
    desc_train(i).bof=H(:)';
end

for i=1:length(desc_test) 
    visword = desc_test(i).visword;
    H = histc(visword,(1:nwords_codebook));
  
    % normalize bow-hist (L1 norm)
    if norm_bof_hist
        H = H/sum(H);
    end  
    % save histograms
    desc_test(i).bof=H(:)';
end