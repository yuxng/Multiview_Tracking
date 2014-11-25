function show_results(X, Y, Y_hat)

% prepare the file name for each image
root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/car_3D/img';
filenames = dir(fullfile(root_path, '*.jpg'));
nframes = numel(filenames);
s_frames = cell(nframes,1);
for t = 1:nframes
    s_frames{t} = fullfile(root_path, filenames(t).name);
end
N = numel(s_frames);

figure;
for i = 1:N
    det_DPM = X(i,1:4);
    det_ALM = X(i,5:8);
    det_gt = Y(i,:);
    det_pr = Y_hat(i,:);
    
    if i ~= 1 && mod(i-1, 16) == 0
        pause;
    end
    ind = mod(i-1,16)+1;
    
    I = imread(s_frames{i});
    subplot(4, 4, ind);
    imshow(I);
    hold on;

    % draw bounding boxes
    bbox_pr = det_DPM;
    bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
    rectangle('Position', bbox_draw, 'EdgeColor', 'b', 'LineWidth',2);
    
    bbox_pr = det_ALM;
    bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
    rectangle('Position', bbox_draw, 'EdgeColor', 'r', 'LineWidth',2);
    
    bbox_pr = det_gt;
    bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
    rectangle('Position', bbox_draw, 'EdgeColor', 'g', 'LineWidth',2);
    
    bbox_pr = det_pr;
    bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
    rectangle('Position', bbox_draw, 'EdgeColor', 'y', 'LineWidth',2);    
    
    subplot(4, 4, ind);
    hold off;
end