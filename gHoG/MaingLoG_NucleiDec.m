%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is designed by Hongming Xu,
% Deptment of Eletrical and Computer Engineering,
% University of Alberta, Canada.  1th April, 2016
% If you have any problem feel free to contact me.
% Please address questions or comments to: mxu@ualberta.ca

% The techique is mainly based on the following paper:
% Xu, Hongming, et al. "Automatic Nuclei Detection based on Generalized Laplacian of Gaussian Filters." (2016).

% Terms of use: You are free to copy,
% distribute, display, and use this work, under the following
% conditions. (1) You must give the original authors credit. (2) You may
% not use or redistribute this work for commercial purposes. (3) You may
% not alter, transform, or build upon this work. (4) For any reuse or
% distribution, you must make clear to others the license terms of this
% work. (5) Any of these conditions can be waived if you get permission
% from the authors.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function MaingLoG_NucleiDec
close all;
clear all;

%% %% add the function into MATLAB searching path and enter the test dataset
p = mfilename('fullpath');
t = findstr(p,'/');
p = p(1:t(end));
addpath(p);
cd(p);
delete('seed_coordinates.mat');
cd('images');
list=dir('*.jpg');

%% %% create list to store lists with seed coordinates for each image
seed_coordinates=cell(length(list), 1);

for index=1:length(list)
    filename=list(index).name;
    I=imread(filename);
    gray=rgb2gray(I);
    
    
    %% binary mask to fiter false seeds
    thr1=0.85; %% gray values below 0.85 are considered as nuclear pixels
    % if you feel there are many false seeds in background regions, you can
    % reduce this value according to your appliacation
    bwn=~im2bw(gray,thr1);
    
    
    %% Nuclei seeds detections by gLoG kernels
    Para.thetaStep=pi/9;
    Para.largeSigma=6;
    Para.smallSigma=3;
    Para.sigmaStep=-1;
    Para.kerSize=Para.largeSigma*4;
    Para.bandwidth=4;
    cs=xp_NucleiSeedsDetection(gray,bwn,Para);
    
    
    %% show the results--remove nuclear seeds on image borders
    dis=3; % if the seeds is close to image borders less than 3 pixels, it removed for consideration.
    ind1=find(cs(:,1)<dis | (size(gray,1)-cs(:,1))<dis);
    if ~isempty(ind1)
        cs(ind1,:)=[];
    end
    ind1=find(cs(:,2)<dis | (size(gray,2)-cs(:,2))<dis);
    if ~isempty(ind1)
        cs(ind1,:)=[];
    end
    %% add coordinates to list storing coordinates for each images
    seed_coordinates{index} = cs;
    rs5=cs(:,1);cs5=cs(:,2);
    figure,imshow(I);
    hold on,plot(cs5,rs5,'r+','MarkerSize',2,'LineWidth',2);
end
%% %% save seed coordinates in gHoG folder
cd('..');
save('seed_coordinates.mat', 'seed_coordinates');
end

