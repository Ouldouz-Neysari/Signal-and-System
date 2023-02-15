clc
close all;
clear;
load per_train;
totalLetters=size(per_train,2);

% SELECTING THE TEST DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[file,path]=uigetfile({'*.jpg;*.bmp;*.png;*.tif'},'Choose an image');
s=[path,file];
picture=imread(s);
picture=imresize(picture,[300 500]);



%RGB2GRAY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
picture=rgb2gray(picture);
% THRESHOLDIG and CONVERSION TO A BINARY IMAGE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
threshold = graythresh(picture);
picture =~im2bw(picture,threshold);

% Removing the small objects and background
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

picture = bwareaopen(picture,300); 
background=bwareaopen(picture,6000);
picture2=picture-background;



% Labeling connected components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
imshow(picture2)
[L,Ne]=bwlabel(picture2);
propied=regionprops(L,'BoundingBox');
hold on
for n=1:size(propied,1)
    rectangle('Position',propied(n).BoundingBox,'EdgeColor','g','LineWidth',2);
end
hold off

% Decision Making
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
final_output=[];
t=[];
for n=1:Ne
    [r,c] = find(L==n);
    min_r=min(r);
    max_r=max(r);
    min_c=min(c);
    max_c=max(c);
    count =0;
    if n == 3
       [my_r,my_c] = find(L==4);
       if max_c > min(c)
           if min(my_r) < min_r
              min_r = min(my_r);
              count = 1;
           end
           if max_r < max(my_r)
              max_r = max(my_r);
           end
       end
    end
    Y=picture2(min_r:max_r,min_c:max_c);
    Y=imresize(Y,[42,24]);
    ro=zeros(1,totalLetters);
    for k=1:totalLetters   
        ro(k)=corr2(per_train{1,k},Y);
    end
    [MAXRO,pos]=max(ro);
    if MAXRO>.40
        out=cell2mat(per_train(2,pos));
        if n == 4 & out == '0'
            out = '';
        end
        if n ~= 3 & (out == 'B' | out == 'c' | out == 'H' | out == 'J' | out == 'l' | out == 'm' | ...
                out == 'n' | out =='q' | out == 's' | out == 't'| out == 'v' | out == 'y')
            out = '';
        end
        final_output=[final_output out];
    end
end




% Printing the plate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
file = fopen('number_Plate2.txt', 'wt');
fprintf(file,'%s\n',final_output);
fclose(file);
winopen('number_Plate2.txt')