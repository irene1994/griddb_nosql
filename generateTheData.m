%~~~~~~~~~~~~~~~~~~~~~Compile TrainingInfo~~~~~~~~~~~~~~~~~~~~~
clearvars

%Go to the image directory and get a reference for each image
%sourceImagesPath = uigetdir('C:\Users\Irene\Desktop', 'Select Input Data Folder'); %Select input data folder
sourceImagesPath = 'C:\Users\Irene\Desktop\OldFolder';
outputPath = uigetdir('C:\Users\Irene\Desktop', 'select out folder'); %Select output folder

trainingPositiveSuffix = fullfile(sourceImagesPath,'Training', 'Positives');
trainingNegativeSuffix = fullfile(sourceImagesPath,'Training','Negatives');
testingPositiveSuffix = fullfile(sourceImagesPath,'Test','Positives');
testingNegativeSuffix = fullfile(sourceImagesPath,'Test','Negatives');


%Now start with the Positive Training initializations
imagefiles = dir(fullfile(trainingPositiveSuffix,'*.png'));
trainingPositiveInfo = struct;

%Create the sub-Struct array for the Training Positives
for i=1:length(imagefiles)
    trainingPositiveInfo(i, 1).names = fullfile(imagefiles(i).folder, imagefiles(i).name);
    trainingPositiveInfo(i, 1).classes = '1';
end

%Now do the Training Negatives initializations
imagefiles = dir(fullfile(trainingNegativeSuffix,'*.png'));
trainingNegativeInfo = struct;

%Create the sub-Struct array for the Training Negatives
for i=1 : length(imagefiles);
    trainingNegativeInfo(i, 1).names = fullfile(imagefiles(i).folder, imagefiles(i).name);
    trainingNegativeInfo(i, 1).classes = '0';
end

%Properly transform struct array into cell array
trainingInfo = vertcat(trainingPositiveInfo, trainingNegativeInfo);
trainingInfoCell = struct2cell(trainingInfo);
trainingInfoCell = trainingInfoCell';

%Create the CSV file for the full Training Info (Positives & Negatives)
cell2csv(fullfile(outputPath,'TrainingInfo.csv'), trainingInfoCell);




%~~~~~~~~~~~~~~~~~~~~~Compile TestInfo~~~~~~~~~~~~~~~~~~~~~clearvars

%Now start with the Positive Training initializations
imagefiles = dir(fullfile(testingPositiveSuffix,'*.png'));
testingPositiveInfo = struct;

%Create the sub-Struct array for the Testing Positives
for i=1:length(imagefiles)
    testingPositiveInfo(i, 1).names = fullfile(imagefiles(i).folder, imagefiles(i).name);
    testingPositiveInfo(i, 1).classes = '1';
end

%Now do the Testing Negatives initializations
imagefiles = dir(fullfile(testingNegativeSuffix,'*.png'));
testingNegativeInfo = struct;

%Create the sub-Struct array for the Testing Negatives
for i=1 : length(imagefiles);
    testingNegativeInfo(i, 1).names = fullfile(imagefiles(i).folder, imagefiles(i).name);
    testingNegativeInfo(i, 1).classes = '0';
end

%Properly transform struct array into cell array
testingInfo = vertcat(testingPositiveInfo, testingNegativeInfo);
testingInfoCell = struct2cell(testingInfo);
testingInfoCell = testingInfoCell';

%Create the CSV file for the full Testing Info (Positives & Negatives)
cell2csv(fullfile(outputPath,'TestingInfo.csv'), testingInfoCell);

%~~~~~~~~~~~~~~~~~~~~~Compile positiveTrainingSet~~~~~~~~~~~~~~~~~~~~~



%Go to the image directory and get a reference for each image
imagefiles = dir(fullfile(trainingPositiveSuffix,'*.png'));
nfiles = length(imagefiles);    % Number of files found
nfiles = 10; %-------------WEeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-----------

flag = 0; %Used to properly create the array
%Produce HOG feature vector from each Training Positive image
for i=1:nfiles
   currentfilename = fullfile(imagefiles(i).folder, imagefiles(i).name);
   currentimage = imread(currentfilename);
   images{i} = currentimage;
   resultHOG = hog_feature_vector(currentimage);
   if flag == 0 %One time only, create the featureHOG array
        featureHOG = zeros(nfiles, length(resultHOG));
        flag = 1;
   end
   featureHOG(i,:) = resultHOG;
end

flag = 0; %Used to properly create the array
%Apply PCA to each Training Positive image
for i =1:nfiles
   currentfilename = fullfile(imagefiles(i).folder, imagefiles(i).name);
   currentimage = imread(currentfilename);
   images{i} = currentimage;
    
    %Extract RGB values from image
    currentimage = im2double(currentimage);
    RED = currentimage(:,:,1);
    RED = RED(:);
    GREEN = currentimage(:,:,2);
    GREEN = GREEN(:);
    BLUE = currentimage(:,:,3);
    BLUE = BLUE(:);
    RGB = [RED,GREEN,BLUE];
    
    resultPCA =  pca(RGB);
    resultPCA = reshape(resultPCA, [1,9]);
    
    if flag == 0
        featurePCA = zeros(nfiles, length(resultPCA));
        flag = 1;
    end
    featurePCA(i,:) = resultPCA(:);
end

flag = 0; %Used to properly create the array
%Apply LBP to each Training Positive image
for i=1:nfiles    %Read next image and perform LBP to it
   currentfilename = fullfile(imagefiles(i).folder, imagefiles(i).name);
   currentimage = imread(currentfilename);
   images{i} = currentimage;
   
   resultLBP = efficientLBP(currentimage);
   if flag == 0
        featureLBP = zeros(nfiles, length(resultLBP));
        flag = 1;
    end
   featureLBP(i,:) = resultLBP(:);
end

%Stitch the results together
positiveTrainingSet = [featureHOG featurePCA featureLBP];

%--------------------Compile negativeTrainingSet------------------

%Go to the image directory and get a reference for each image
cd(strcat(sourceImagesPath,trainingNegativeSuffix));
imagefiles = dir('*.png');
nfiles = length(imagefiles);    % Number of files found
nfiles = 10; %-------------WEeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-----------

flag = 0; %Used to properly create the array
%Produce HOG feature vector from each Training Negative image
for i=1:nfiles
   currentfilename = fullfile(imagefiles(i).folder, imagefiles(i).name);
   currentimage = imread(currentfilename);
   images{i} = currentimage;
   resultHOG = hog_feature_vector(currentimage);
   if flag == 0 %One time only, create the featureHOG array
        featureHOG = zeros(nfiles, length(resultHOG));
        flag = 1;
   end
   featureHOG(i,:) = resultHOG;
end

flag = 0; %Used to properly create the array
%Apply PCA to each Training Negative image
for i =1:nfiles
    currentfilename = fullfile(imagefiles(i).folder, imagefiles(i).name);
   currentimage = imread(currentfilename);
   images{i} = currentimage;
    
    %Extract RGB values from image
    currentimage = im2double(currentimage);
    RED = currentimage(:,:,1);
    RED = RED(:);
    GREEN = currentimage(:,:,2);
    GREEN = GREEN(:);
    BLUE = currentimage(:,:,3);
    BLUE = BLUE(:);
    RGB = [RED,GREEN,BLUE];
    
    resultPCA =  pca(RGB);
    resultPCA = reshape(resultPCA, [1,9]);
    
    if flag == 0
        featurePCA = zeros(nfiles, length(resultPCA));
        flag = 1;
    end
    featurePCA(i,:) = resultPCA(:);
end

flag = 0; %Used to properly create the array
%Apply LBP to each Training Negative image
for i=1:nfiles    %Read next image and perform LBP to it
   currentfilename = fullfile(imagefiles(i).folder, imagefiles(i).name);
   currentimage = imread(currentfilename);
   images{i} = currentimage;
   
   resultLBP = efficientLBP(currentimage);
   if flag == 0
        featureLBP = zeros(nfiles, length(resultLBP));
        flag = 1;
    end
   featureLBP(i,:) = resultLBP(:);
end

%Stitch the results together
negativeTrainingSet = [featureHOG featurePCA featureLBP];

%------------Stitch Positives and Negatives Together and produce a csv file---------------
trainingSet = vertcat(positiveTrainingSet, negativeTrainingSet);
cell2csv(strcat(outputPath,'\\TrainingSet.csv'),trainingSet);


%~~~~~~~~~~~~~~~~~~~~~Compile positiveTestingSet~~~~~~~~~~~~~~~~~~~~~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



%Go to the image directory and get a reference for each image
cd(strcat(sourceImagesPath,testingPositiveSuffix));
imagefiles = dir('*.png');
nfiles = length(imagefiles);    % Number of files found
nfiles = 10; %-------------WEeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-----------

flag = 0; %Used to properly create the array
%Produce HOG feature vector from each Training Positive image
for i=1:nfiles
   currentfilename = fullfile(imagefiles(i).folder, imagefiles(i).name);
   currentimage = imread(currentfilename);
   images{i} = currentimage;
   resultHOG = hog_feature_vector(currentimage);
   if flag == 0 %One time only, create the featureHOG array
        featureHOG = zeros(nfiles, length(resultHOG));
        flag = 1;
   end
   featureHOG(i,:) = resultHOG;
end

flag = 0; %Used to properly create the array
%Apply PCA to each Testing Positive image
for i =1:nfiles
    currentfilename = fullfile(imagefiles(i).folder, imagefiles(i).name);
   currentimage = imread(currentfilename);
   images{i} = currentimage;
    
    %Extract RGB values from image
    currentimage = im2double(currentimage);
    RED = currentimage(:,:,1);
    RED = RED(:);
    GREEN = currentimage(:,:,2);
    GREEN = GREEN(:);
    BLUE = currentimage(:,:,3);
    BLUE = BLUE(:);
    RGB = [RED,GREEN,BLUE];
    
    resultPCA =  pca(RGB);
    resultPCA = reshape(resultPCA, [1,9]);
    
    if flag == 0
        featurePCA = zeros(nfiles, length(resultPCA));
        flag = 1;
    end
    featurePCA(i,:) = resultPCA(:);
end

flag = 0; %Used to properly create the array
%Apply LBP to each Testing Positive image
for i=1:nfiles    %Read next image and perform LBP to it
   currentfilename = fullfile(imagefiles(i).folder, imagefiles(i).name);
   currentimage = imread(currentfilename);
   images{i} = currentimage;
   
   resultLBP = efficientLBP(currentimage);
   if flag == 0
        featureLBP = zeros(nfiles, length(resultLBP));
        flag = 1;
    end
   featureLBP(i,:) = resultLBP(:);
end

%Stitch the results together
positiveTestingSet = [featureHOG featurePCA featureLBP];

%--------------------Compile negativeTestingSet------------------

%Go to the image directory and get a reference for each image
cd(strcat(sourceImagesPath,testingNegativeSuffix));
imagefiles = dir('*.png');
nfiles = length(imagefiles);    % Number of files found
nfiles = 10; %-------------WEeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-----------

flag = 0; %Used to properly create the array
%Produce HOG feature vector from each Testing Negative image
for i=1:nfiles
   currentfilename = fullfile(imagefiles(i).folder, imagefiles(i).name);
   currentimage = imread(currentfilename);
   images{i} = currentimage;
   resultHOG = hog_feature_vector(currentimage);
   if flag == 0 %One time only, create the featureHOG array
        featureHOG = zeros(nfiles, length(resultHOG));
        flag = 1;
   end
   featureHOG(i,:) = resultHOG;
end

flag = 0; %Used to properly create the array
%Apply PCA to each Testing Negative image
for i =1:nfiles
    currentfilename = fullfile(imagefiles(i).folder, imagefiles(i).name);
   currentimage = imread(currentfilename);
   images{i} = currentimage;
    
    %Extract RGB values from image
    currentimage = im2double(currentimage);
    RED = currentimage(:,:,1);
    RED = RED(:);
    GREEN = currentimage(:,:,2);
    GREEN = GREEN(:);
    BLUE = currentimage(:,:,3);
    BLUE = BLUE(:);
    RGB = [RED,GREEN,BLUE];
    
    resultPCA =  pca(RGB);
    resultPCA = reshape(resultPCA, [1,9]);
    
    if flag == 0
        featurePCA = zeros(nfiles, length(resultPCA));
        flag = 1;
    end
    featurePCA(i,:) = resultPCA(:);
end

flag = 0; %Used to properly create the array
%Apply LBP to each Testing Negative image
for i=1:nfiles    %Read next image and perform LBP to it
   currentfilename = fullfile(imagefiles(i).folder, imagefiles(i).name);
   currentimage = imread(currentfilename);
   images{i} = currentimage;
   
   resultLBP = efficientLBP(currentimage);
   if flag == 0
        featureLBP = zeros(nfiles, length(resultLBP));
        flag = 1;
    end
   featureLBP(i,:) = resultLBP(:);
end

%Stitch the results together
negativeTestingSet = [featureHOG featurePCA featureLBP];

%------------Stitch Positives and Negatives Together and produce a csv file---------------
testingSet = vertcat(positiveTestingSet, negativeTestingSet);
cell2csv(strcat(outputPath,'\\TestingSet.csv'),testingSet);
