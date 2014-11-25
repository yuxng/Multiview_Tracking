function display_result_DPM_car_3D

% prepare the file name for each image
root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/car_3D/img';
filenames = dir(fullfile(root_path, '*.jpg'));
nframes = numel(filenames);
s_frames = cell(nframes,1);
for t = 1:nframes
    s_frames{t} = fullfile(root_path, filenames(t).name);
end
N = numel(s_frames);

% get detection results
result_path = '../result/DPM_VOC2007/car_3D';

figure;
for i = 1:N
    filename = fullfile(result_path, [filenames(i).name(1:end-3) 'mat']);
    object = load(filename, 'det');
    det = object.det;
    
    if i ~= 1 && mod(i-1, 16) == 0
        pause;
    end
    ind = mod(i-1,16)+1;
    
    I = imread(s_frames{i});
    subplot(4, 4, ind);
    imshow(I);
    hold on;

    for k = 1:1
        % get predicted bounding box
        bbox_pr = det(k,1:4);
        bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
        rectangle('Position', bbox_draw, 'EdgeColor', 'g', 'LineWidth',2);
    end
    
    subplot(4, 4, ind);
    hold off;
end