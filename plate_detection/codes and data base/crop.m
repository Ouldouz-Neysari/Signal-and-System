clc;           
clear;        
close all;  
% SELECTING THE TEST DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[file,path]=uigetfile({'*.jpg;*.bmp;*.png;*.tif'},'Choose an image');
s=[path,file];
picture=imread(s);
picture=imresize(picture,[1500 2000]);

%RGB2GRAY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
picture=rgb2gray(picture);


% THRESHOLDIG and CONVERSION TO A BINARY IMAGE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
threshold = graythresh(picture);
picture =~im2bw(picture,threshold);

% Removing the small objects and background
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
picture2 = bwareaopen(picture,300);
background=bwareaopen(picture2,5000);
figure
imshow(background);
pic = picture2 - background;

% Croping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
imshow(pic);
im = edge(pic, 'prewitt');
figure
imshow(im)
[x,y] = size(im);
xs = [];
my_df = [];
my_un = [-1,0,1];
for n=1:x
    line=diff(im(n,:));
    repeated = histc(line,my_un);
    if repeated(1) + repeated(3) > 35
        xs = [xs n];
    end
    my_df=[my_df; line];
end
disp(xs);
my_min = min(xs);
my_max = max(xs);
final = imcrop(picture,[1,my_min-50,y,2*(my_max-my_min)+10]);

% Making rectangle for every letter and number
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
imshow(final);
im = edge(final, 'prewitt');
Iprops=regionprops(im,'BoundingBox','Area', 'Image');
area = Iprops.Area;
count = numel(Iprops);
maxa= area;
boundingBox = Iprops.BoundingBox;

for i=1:count
   if maxa<Iprops(i).Area
      maxa=Iprops(i).Area;
      boundingBox=Iprops(i).BoundingBox;
   end
end

my_cor = [];
my_cor=boundingBox;
my_cor(3) = my_cor(3) + 150;
im = imcrop(final, my_cor);
im = bwareaopen(im, 200);
figure
imshow(im);