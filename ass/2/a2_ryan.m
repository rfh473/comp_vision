close all;
clear all;
im1 = imread('im2.png');
im1_grey = im1(:,:,2);
h = fspecial('gaussian',15,3);
im1_filter = imfilter(im1_grey, h);
im1_edge = edge (im1_filter, 'sobel');
figure;
imshow(im1_edge);
im1_edge2 = edge(im1_edge, 'canny');

x_max = size(im1_edge, 1);
y_max = size(im1_edge, 2);

% radii to check in hough function
r_min = 20;
r_max = 150;
h = hough2(im1_edge, r_min, r_max);

h(h<100) = 0; % threshold

% tolerance for remove duplicates function 
x_tol = 50;
y_tol = 50;
r_tol = 50;
h = remove_duplicates(h, x_tol, y_tol, r_tol);

circles = zeros(x_max, y_max);
cnt = 0;

for x = 1:x_max
    for y = 1:y_max
        for r = r_min:r_max
            if(h(x, y, r - r_min + 1) > 0)
                circles = circles + draw_circle(circles, x, y, r);
                %im1_grey = insertShape(im1_grey, 'circle', [x, y, r]);
                disp(strcat('circle at x = ', num2str(x), ' y = ', num2str(y), ' with radius = ', num2str(r)));
                cnt = cnt + 1;
            end
        end
    end
end

disp(strcat(num2str(cnt), ' total circles'));

figure;
imshow(circles);
%figure;
%imshow(im1_grey);

function accumulator = hough2(input, r_min, r_max)
    accumulator = zeros(size(input, 1), size(input, 2), (r_max - r_min + 1));
    for r = r_min:r_max
        accumulator_r = zeros(size(input, 1), size(input, 2));
        for x = 1:size(input, 1)
            for y = 1:size(input, 2)
                if(input(x, y) == 1) % only edges
                    for t = 1:360 % theta
                        x_a = round(x - r * cos(t));
                        y_a = round(y - r * sin(t));
                        if(x_a > 0 && x_a < size(input, 1) && y_a > 0 && y_a < size(input, 2)) % out of bounds check
                            accumulator_r(x_a, y_a) = accumulator_r(x_a, y_a) + 1;
                        end
                    end
                end
            end
        end
        
        % get local maxima
        accumulator_r(accumulator_r<max(accumulator_r(:))) = 0;
        accumulator(:,:,r - r_min + 1) = accumulator_r;
    end
end

function circle = draw_circle(input, x, y, r)
    circle = zeros(size(input, 1), size(input, 2));
    for t = 1:360
        i = round(x - r * cos(t));
        j = round(y - r * sin(t));
        if(i > 0 && i < size(input, 1) && j > 0 && j < size(input, 2)) % out of bounds check
            circle(i, j) = circle(i, j) + 1;
        end
    end
end

function output = remove_duplicates(input, x_tol, y_tol, r_tol)
    x_max = size(input, 1);
    y_max = size(input, 2);
    r_max = size(input, 3);
    
    for x = 1:x_max
        for y = 1:y_max
            for r = 1:r_max
                if(input(x,y,r) > 0)
                    
                    x_bound_1 = x - x_tol;
                    x_bound_2 = x + x_tol;
                    y_bound_1 = y - y_tol;
                    y_bound_2 = y + y_tol;
                    r_bound_1 = r - r_tol;
                    r_bound_2 = r + r_tol;
                    
                    if(x_bound_1 < 1); x_bound_1 = 1; end
                    if(x_bound_2 > x_max); x_bound_2 = x_max; end
                    if(y_bound_1 < 1); y_bound_1 = 1; end
                    if(y_bound_2 > y_max); y_bound_2 = y_max; end
                    if(r_bound_1 < 1); r_bound_1 = 1; end
                    if(r_bound_2 > r_max); r_bound_2 = r_max; end
                    
                    cluster = max(input(x_bound_1:x_bound_2, y_bound_1:y_bound_2, r_bound_1:r_bound_2));
                    local_max = max(cluster(:));
                    input(x_bound_1:x_bound_2, y_bound_1:y_bound_2, r_bound_1:r_bound_2) = 0;
                    input(x, y, r) = local_max;
                    
                end
            end
        end
    end
    output = input;
end


