% Object recognition using Bag of Features with Matlab
% algorithm used are: SURF
% Selecting feature point locations using the Grid method
% Using K-Means clustering to create a word visual vocabulary
% Matlab example: https://it.mathworks.com/content/dam/mathworks/tag-team/Objects/i/88400_93009v00_Image_Class_Bag_Features_2016.pdf

% dataset Cagliari
url_cagliari = 'https://github.com/bellisanogiu/MonuFind/raw/master/matlabExample/dataset_front_low.zip';
outputFolder = fullfile(tempdir, 'datasetlow'); % define output folder; tempdir is the name of temporary folder for the system

% download only once
if ~exist(outputFolder, 'dir') 
 disp('Downloading Cagliari data set...');
 unzip(url_cagliari, outputFolder);
end

rootFolder = fullfile(outputFolder, 'dataset_front_low');

% create a collection of images (basilicaBonaria, bastione, carloFelice)
% imgSets = [imageSet(fullfile(rootFolder, 'basilicaBonaria')), ...
% imageSet(fullfile(rootFolder, 'carloFelice')), ...
% imageSet(fullfile(rootFolder, 'bastione'))];

categories = {'basilicaBonaria', 'bastione', 'carloFelice', 'cattedraleSantaMaria', 'cittadellaMusei', 'collegiataAnna', 'legioneCarabinieri', 'portaCristina', 'galleriaComunale', 'torreElefante'};
% categories = {'basilicaBonaria', 'bastione', 'carloFelice'};
imds = imageDatastore(fullfile(rootFolder, categories), 'LabelSource', 'foldernames');

tbl = countEachLabel(imds)
minSetCount = min(tbl{:,2}); % determine the smallest amount of images in a category

% Use splitEachLabel method to trim the set.
imds = splitEachLabel(imds, minSetCount, 'randomize');

% Notice that each set now has exactly the same number of images.
countEachLabel(imds)

% minSetCount = min([imgSets.Count]); % determine the smallest amount of images in a category
% % Use partition method to trim the set.
% imgSets = partition(imgSets, minSetCount, 'randomize');
% % Notice that each set now has exactly the same number of images

[trainingSet, validationSet] = splitEachLabel(imds, 0.3, 'randomize');

% Find the first instance of an image for each category
basilicaBonaria = find(trainingSet.Labels == 'basilicaBonaria', 1);
bastione = find(trainingSet.Labels == 'bastione', 1);
carloFelice = find(trainingSet.Labels == 'carloFelice', 1);
cattedraleSantaMaria = find(trainingSet.Labels == 'cattedraleSantaMaria', 1);
cittadellaMusei = find(trainingSet.Labels == 'cittadellaMusei', 1);
collegiataAnna = find(trainingSet.Labels == 'collegiataAnna', 1);
legioneCarabinieri = find(trainingSet.Labels == 'legioneCarabinieri', 1);
portaCristina = find(trainingSet.Labels == 'portaCristina', 1);
galleriaComunale = find(trainingSet.Labels == 'galleriaComunale', 1);
torreElefante = find(trainingSet.Labels == 'torreElefante', 1);

% figure
subplot(1,3,1);
imshow(readimage(trainingSet,cattedraleSantaMaria))
subplot(1,3,2);
imshow(readimage(trainingSet,legioneCarabinieri))
subplot(1,3,3);
imshow(readimage(trainingSet,portaCristina))

bag = bagOfFeatures(trainingSet);

img = readimage(imds, 1);
featureVector = encode(bag, img);

% Plot the histogram of visual word occurrences
figure
bar(featureVector)
title('Visual word occurrences')
xlabel('Visual word index')
ylabel('Frequency of occurrence')


% img = read(imgSets(1), 1);
% featureVector = encode(bag, img);
% 
% % Plot the histogram of visual word occurrences
% figure
% bar(featureVector)
% title('Visual word occurrences')
% xlabel('Visual word index')
% ylabel('Frequency of occurrence')

% This histogram forms a basis for training a classifier and for the actual image classification. In essence, it encodes an image into a feature vector. 
% The above function utilizes the encode method of the input bag object to formulate feature vectors representing each image category from the  trainingSet.
categoryClassifier = trainImageCategoryClassifier(trainingSet, bag);

% Evalutate test set
confMatrix = evaluate(categoryClassifier, trainingSet);

% Evalutate validation set
confMatrix = evaluate(categoryClassifier, validationSet);

% Compute average accuracy
mean(diag(confMatrix));

% Trying the Newly Trained Classifier on Test Images
img = imread(fullfile(rootFolder, 'test', 'TorreElefanteWeb2.jpg'));
[labelIdx, scores] = predict(categoryClassifier, img);
categoryClassifier.Labels(labelIdx)