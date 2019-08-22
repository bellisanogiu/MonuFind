% Build visual vocabulary using k-means
function [VC] = visual_vocab_builder(data, desc_train, num_train_img, nfeat_codebook, nwords_codebook, max_km_iters)
fprintf('\nBuild visual vocabulary:\n');

% concatenate all descriptors from all images into a n x d matrix
DESC = [];
labels_train = cat(1,desc_train.class);
for i=1:length(data)
    desc_class = desc_train(labels_train==i);
    randimages = randperm(num_train_img);
    randimages=randimages(1:5);
    DESC = vertcat(DESC,desc_class(randimages).sift);
end

% sample random M (e.g. M=20,000) descriptors from all training descriptors
r = randperm(size(DESC,1));
r = r(1:min(length(r),nfeat_codebook));

DESC = DESC(r,:);

% run k-means
K = nwords_codebook; % size of visual vocabulary
fprintf('running k-means clustering of %d points into %d clusters...\n', size(DESC,1),K)
% input matrix needs to be transposed as the k-means function expects
% one point per column rather than per row

% form options structure for clustering
cluster_options.maxiters = max_km_iters;
cluster_options.verbose  = 1;

[VC] = kmeans_bo(double(DESC),K,max_km_iters);%visual codebook
VC = VC';%transpose for compatibility with following functions
clear DESC;