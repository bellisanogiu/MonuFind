

dataset_dir='12_CagliariMonuments';
basepath = '..';
basepath2 = 'enhancedBow';
imageFolder = fullfile(basepath, basepath2,  'img' ,dataset_dir);
flowerImageSet = imageDatastore(imageFolder,'LabelSource','foldernames','IncludeSubfolders',true,'FileExtensions','.jpg');

% Total number of images in the data set
numel(flowerImageSet.Files);

% STEP 1
% Select the Image Features for Retrieval
figure
I = imread(flowerImageSet.Files{1});
imshow(I);


% STEP algorithm used to extract color features from a given image
[features, metrics] = exampleBagOfFeaturesColorExtractor(I);
doTraining = true;

if doTraining
    %Pick a random subset of the flower images
    trainingSet = splitEachLabel(flowerImageSet, 0.6, 'randomized');
    
    % Create a custom bag of features using the 'CustomExtractor' option
    colorBag = bagOfFeatures(trainingSet, ...
        'CustomExtractor', @exampleBagOfFeaturesColorExtractor, ...
        'VocabularySize', 10000);
    save('savedColorBagOfFeatures.mat','colorBag');
else
    % Load a pretrained bagOfFeatures
    load('savedColorBagOfFeatures.mat','colorBag');
end

% Indexing
if doTraining
    % Create a search index
    flowerImageIndex = indexImages(flowerImageSet,colorBag,'SaveFeatureLocations',false);
    save('savedColorBagOfFeatures.mat','flowerImageIndex');
else
    % Load a saved index
    load('savedColorBagOfFeatures.mat','flowerImageIndex');
end

% Define a query image
queryImage = readimage(flowerImageSet,200);

figure
imshow(queryImage)

% Search for the top 5 images with similar color content
[imageIDs, scores] = retrieveImages(queryImage, flowerImageIndex,'NumResults',15);

figure
montage(flowerImageSet.Files(imageIDs),'ThumbnailSize',[200 200])