% Object recognition using Bag of Features with Matlab
% algorithm used are: SURF
% Selecting feature point locations using the Grid method
% Using K-Means clustering to create a word visual vocabulary
% Matlab example: https://it.mathworks.com/content/dam/mathworks/tag-team/Objects/i/88400_93009v00_Image_Class_Bag_Features_2016.pdf
% dataset: http://www.vision.caltech.edu/Image_Datasets/Caltech101/101_ObjectCategories.tar.gz

% dataset Cagliari
url_cagliari = '/home/pino/PycharmProjects/MonuFind/dataset.tar.gz';
outputFolder = fullfile(tempdir, 'dataset'); % define output folder; tempdir is the name of temporary folder for the system

% download only once
if ~exist(outputFolder, 'dir') 
 disp('Downloading Cagliari data set...');
 untar(url_cagliari, outputFolder);
end

rootFolder = fullfile(outputFolder, 'dataset');

% create a collection of images (airplanes, ferry, laptop)
imgSets = [imageSet(fullfile(rootFolder, 'basilicaBonaria')), ...
imageSet(fullfile(rootFolder, 'carloFelice')), ...
imageSet(fullfile(rootFolder, 'bastione'))];

minSetCount = min([imgSets.Count]); % determine the smallest amount of images in a category
% Use partition method to trim the set.
imgSets = partition(imgSets, minSetCount, 'randomize');
% Notice that each set now has exactly the same number of images

[trainingSets, validationSets] = partition(imgSets, 0.3, 'randomize');

bonaria = read(trainingSets(1),1);
carloFelice = read(trainingSets(2),1);
bastione = read(trainingSets(3),1);

figure

subplot(1,3,1);
imshow(bonaria)
subplot(1,3,2);
imshow(carloFelice)
subplot(1,3,3);
imshow(bastione)

bag = bagOfFeatures(trainingSets);

img = read(imgSets(1), 1);
featureVector = encode(bag, img);

% Plot the histogram of visual word occurrences
figure
bar(featureVector)
title('Visual word occurrences')
xlabel('Visual word index')
ylabel('Frequency of occurrence')

categoryClassifier = trainImageCategoryClassifier(trainingSets, bag);

% Evalutate test set
confMatrix = evaluate(categoryClassifier, trainingSets);

% Evalutate validation set
confMatrix = evaluate(categoryClassifier, validationSets);

% Trying the Newly Trained Classifier on Test Images
img = imread(fullfile(rootFolder, 'bastione', 'Bast97.jpg'));
[labelIdx, scores] = predict(categoryClassifier, img);
categoryClassifier.Labels(labelIdx)