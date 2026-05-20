close all
clear
clc

%Jonathan Bradford
%CSCI 158 Assign. 2

origImg = imread("binary7.png");    %Store img to variable
[x1, y1, ~] = size(origImg);        %Set x1/y1 to image height/width
binImg(x1, y1) = 255;               %binImg will hold the binary image
labImg = zeros(x1,y1)+255;          %Will hold equivalence class values to
                                    %be labeled 
colorImg = zeros(x1, y1, 3, 'uint8');        %final color image
eqClass(floor((x1*y1/100)),2) = zeros();     %equiv. class obj. can hold 
                                             %large size of components
eqCnt = 0;   

%initializes the equiv. class up to an extreme length
for i = 1:(x1*y1/100)
        eqClass(i,1) = i;       %1st col of our eq class holds its own indx
        eqClass(i,2) = 1;       %2nd col just holds 1 for now
end

%Lazily sets pixels from original image to full-contrast
%bw image and stores them in binImg variable.
for i = 1:x1
    for j = 1:y1
        if origImg(i,j) < 255
            binImg(i,j) = 0;
        else 
            binImg(i,j) = 255;
        end
    end
end

%Function does the binary image scan and assigns objects their reference
%values in the new label image variable.
for i = 1:x1
    for j = 1:y1
        if binImg(i,j) == 0     %if pixel isn't a background pixel:
            %if pixel has no left/up neighbors that aren't labeled as an
            %object, then assign pixel a new object value.
            if (labImg(i,j-1) > (eqCnt + 1) && (labImg(i-1,j) > (eqCnt + 1)))
                labImg(i,j) = eqCnt + 1;
                eqCnt = eqCnt + 1;
                eqClass(eqCnt,2) = eqCnt;
            %else, set label image to lowest value of the two neighbor pixels    
            else 
                labImg(i,j) = min(labImg(i,j-1),labImg(i-1,j));
                %if the neighbors clash, set the index value in equivalence
                %class of the larger neighbor to point to the smaller value
                if (labImg(i,j-1) ~= labImg(i-1,j))
                    eqClass((max(labImg(i,j-1),labImg(i-1,j))),2) = min(labImg(i,j-1),labImg(i-1,j));
                end
            end
        end
    end
end

%This function will seed our equivalence class, where equivalences will
%point to their lowest possible connected base value pair
for i = eqCnt:-1:1                          %start at top and move down
    if (eqClass(i,1) ~= eqClass(i,2))       %if eqClass indexes differ:
        j = i;
        counter = 1;
        %While the eqClass index values differ, add index value to seed
        %vector and continue down until they do equal. Once they do, we
        %know this is the true object reference value.
        while (eqClass(j,1) ~= (eqClass(j,2)))
            seeds(counter) = eqClass(j,1);
            j = eqClass(j,2);
            counter = counter + 1;
        end
        %Set the eqClass indexes added to the seed to their true obj. val
        for k = 1:length(seeds)
            eqClass(seeds(k),2) = eqClass(j,2);
        end
        seeds = [];     %reset seed to null vector
    end
end


rgbVec = zeros(eqCnt, 3);     %will hold random rgb values

%Function creates random RGB vector in the locations where the equivalence
%Class is a unique identifying value
for i = 1:eqCnt
    if (eqClass(i,1) == eqClass(i,2))   %if eqClass = base pointer
        rgbVec(i,1) = randi([0 255]);
        rgbVec(i,2) = randi([0 255]);
        rgbVec(i,3) = randi([0 255]);
    end
end

%Function to assign RGB index values to final output image by scanning
%the labeled image and indexing color according to the equivalence class
for i = 1:x1
    for j = 1:y1
        if (labImg(i,j) ~= 255) %if labelImg(i,j) isn't a background pixel:
            %then assign color image the randomly generated values at the
            %proper equiv. class index value
            colorImg(i,j,1) = rgbVec(eqClass((labImg(i,j)),2),1);
            colorImg(i,j,2) = rgbVec(eqClass((labImg(i,j)),2),2);
            colorImg(i,j,3) = rgbVec(eqClass((labImg(i,j)),2),3);
        end
    end
end

%Show original image in figure 1
figure(1)
imshow(binImg);

%Show colored image in figure 2
figure(2)
imshow(colorImg);