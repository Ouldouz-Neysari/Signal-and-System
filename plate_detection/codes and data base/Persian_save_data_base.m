clc;           
clear;        
close all;  


di=dir('persian images');
st={di.name};
nam=st(3:end);
len=length(nam);


per_train=cell(2,len);
for i=1:len
   pic=imread(['persian images','\',cell2mat(nam(i))]);
   imgray = im2gray(pic);
   threshold = graythresh(imgray);
   imbin =im2bw(imgray,threshold);
   pic2=imresize(imbin,[42,24]);
   figure
   imshow(pic2)
   per_train(1,i)={pic2};
   temp=cell2mat(nam(i));
   per_train(2,i)={temp(1)};
end

save('per_train.mat','per_train');
clear;