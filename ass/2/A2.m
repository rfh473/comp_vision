im1 = imread('im1.png');
im1_grey = im1(:,:,2);
figure(1);
imshow(im1_grey);

h = fspecial('gaussian',15,3);

im1_filter = imfilter(im1_grey, h);
figure(2);
%subplot(2,2,1);
imshow(im1_filter);

im1_edge = edge (im1_filter, 'sobel');
figure(3)
imshow(im1_edge);
im1_edge2 = edge(im1_edge, 'canny');
figure(4);
%subplot(2,2,2);
imshow(im1_edge2);

k = 1;

for i = 1:size(im1_edge, 1)
    for j = 1:size(im1_edge, 2)
        if im1_edge2(i,j) == 1
            for r = 1:100
                for y = j:(j+100)
                    for x = i:(i+100)
                        if (r^2 - (x-i)^2 - (y-j)^2 < 1)
                            P(k,1:3) = [x, y, r];
                        end
                    end
                   
                end
            end
        end
    end 
end  

M = zeros(size(x0), size(y0), size(r));

for i = 1:size(P,1)
    M(round(P(i,1)), round(P(i,2)), round(P(i,3))) = M(round(P(i,1)), round(P(i,2)), round(P(i,3))) +1;
end

[H,T,R] = hough(im1_edge2,'RhoResolution',0.5,'Theta',-90:0.5:89);
figure(5);
%subplot(2,2,3);
imshow(imadjust(rescale(H)),'XData',T,'YData',R,...
      'InitialMagnification','fit');
title('Hough transform of gantrycrane.png');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
colormap(gca,hot);
%H = round(H);
%T = round(T);
%R = round(R);
%for r = rmin, r<= rmax, r++


%P(x0,y0,r) = P(x0,y0,r) +1
P = zeros(size(H,1),size(H,2));
for x = 1:848
    for y = 1:1199
        if im1_edge2(x, y) == 1
            for i = 1:5871
                for j = 1:359
                    x0 = abs(round(x-R(i)*cos(T(j))));
                    y0 = abs(round(y-R(i)*sin(T(j))));
                    P(x0, y0) = P(x0, y0) +1;
                end
            end
        end
    end
end

M = max(P);

