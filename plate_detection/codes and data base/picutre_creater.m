
[file,path]=uigetfile({'*.jpg;*.bmp;*.png;*.tif'},'Choose an image');
s=[path,file];
picture=imread(s);

imgray = im2gray(picture);
threshold = graythresh(imgray);
imbin =~im2bw(imgray,threshold);
picture = bwareaopen(imbin,20)
figure
imshow(picture)
imwrite(picture,'persian images/hey.jpg')