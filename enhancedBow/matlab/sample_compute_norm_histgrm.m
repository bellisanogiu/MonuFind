
function [desc_sample] = sample_compute_norm_histgrm(VC, desc_sample, nwords_codebook, norm_bof_hist)

N = size(VC,1); % number of visual words

for i=1:length(desc_sample) 
    visword = desc_sample(i).visword;
    H = histc(visword,(1:nwords_codebook));
  
    % normalize bow-hist (L1 norm)
    if norm_bof_hist
        H = H/sum(H);
    end
    % save histograms
    desc_sample(i).bof=H(:)';
end