function [I_plate, x1, x2, y1, y2] = extract_plate(I_BW)
% Given a pre-processed black and white image, determine the location of
% the license plate and extract it from the image

% Basically, we calculate the horizontal and vertical histogram of the
% image and find the largest width/height given some pre-defined threshold

[M, N] = size(I_BW);

% horizontal difference
I_BW_horizontal_diff = zeros(M-1, N);
for i = 1: M-1
    I_BW_horizontal_diff(i, :) = I_BW(i+1, :) - I_BW(i, :);
end

% vertical difference
I_BW_vertical_diff = zeros(M, N-1);
for i = 1:N-1
    I_BW_vertical_diff(:, i) = I_BW(:, i+1) - I_BW(:, i);
end

% set horizontal and vertical threshold
coef = .25;
horiThre = max(max(I_BW_horizontal_diff))*coef;
vertiThre = max(max(I_BW_vertical_diff))*coef;

horiHist = zeros(N, 1);
vertiHist = zeros(M, 1);

% iterate each column, only add diff greater than threshold to sum
for i = 1:N
    sum = 0;
    for j = 1:M-1
        if I_BW_horizontal_diff(j, i) > horiThre
            sum = sum + I_BW_horizontal_diff(j, i);
        end
    end
    horiHist(i) = sum;
end

% iterate each row, only add diff greater than threshold to sum
for i = 1:M
    sum = 0;
    for j = 1:N-1
        if I_BW_vertical_diff(i, j) > vertiThre
            sum = sum + I_BW_vertical_diff(i, j);
        end
    end
    vertiHist(i) = sum;
end

% set horizontal and vertical histogram threshold
horiHistThre = max(horiHist)*0.25;
vertiHistThre = max(vertiHist)*0.25;

% store pairs of start point and end point
horiCoordinate = [];
vertiCoordinate = [];

% find firstly appered point greater than threshold, mark it as starting
% point. Keep finding until there is point smaller than threshold, mark it
% as end point. Iterate until the end of image.

% find horizontal start point and end point
flag = false;
y_startPt = 0; y_endPt = 0;
for i = 1:N
    if horiHist(i) > horiHistThre && flag == false
        y_startPt = i;
        flag = true;
    end
    
    if horiHist(i) <= horiHistThre && flag == true
        y_endPt = i-1;
        horiCoordinate = [horiCoordinate; y_startPt y_endPt];
        flag = false;
    end
end

y_diff = horiCoordinate(:, 2) - horiCoordinate(:, 1);
[mx, y_index] = max(y_diff);

% find vertical start point and end point
flag = false;
x_startPt = 0; x_endPt = 0;
for i = 1:M
    if vertiHist(i) > vertiHistThre && flag == false
        x_startPt = i;
        flag = true;
    end
    
    if vertiHist(i) <= vertiHistThre && flag == true
        x_endPt = i-1;
        vertiCoordinate = [vertiCoordinate; x_startPt x_endPt];
        flag = false;
    end
end

x_diff = vertiCoordinate(:, 2) - vertiCoordinate(:, 1);
[my, x_index] = max(x_diff);

% I_plate = I_BW(vertiCoordinate(x_index,1):vertiCoordinate(x_index,2), ...
%      horiCoordinate(y_index, 1):horiCoordinate(y_index, 2));

I_plate = I_BW(vertiCoordinate(x_index,1):vertiCoordinate(x_index,2), 1:N);

x1 = vertiCoordinate(x_index,1);
x2 = vertiCoordinate(x_index,2);
% y1 = horiCoordinate(y_index, 1);
% y2 = horiCoordinate(y_index, 2);
y1 = 1;
y2 = N;

end

