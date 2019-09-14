% K-means descriptor quantization means assignment of each feature
function [desc_sample] = sample_feature_quantization(desc_sample, VC)
fprintf('\nFeature quantization (hard-assignment)...\n');
    for i=1:length(desc_sample)  
      sift = desc_sample(i).sift(:,:);
      dmat = eucliddist(sift,VC);
      [quantdist,visword] = min(dmat,[],2); 
      % save feature labels
      desc_sample(i).visword = visword;
      desc_sample(i).quantdist = quantdist;
    end