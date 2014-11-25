function display_result_DPM_TLD(seq_name)

% prepare the file name for each image
root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/TLD';
filenames = dir(fullfile(root_path, seq_name, '*.jpg'));
nframes = numel(filenames);
s_frames = cell(nframes,1);
for t = 1:nframes
    s_frames{t} = fullfile(root_path, seq_name, filenames(t).name);
end
N = numel(s_frames);

% get detection results
result_path = '../result/DPM_VOC2007/TLD';

figure;
for i = 1:N
    filename = fullfile(result_path, seq_name, [filenames(i).name(1:end-3) 'mat']);
    object = load(filename, 'det');
    det = object.det;
    
    if i ~= 1 && mod(i-1, 8) == 0
        pause;
    end
    ind = mod(i-1,8)+1;
    
    I = imread(s_frames{i});
    subplot(4, 2, ind);
    imshow(I);
    hold on;

    for k = 1:min(5,size(det,1))
        % get predicted bounding box
        bbox_pr = det(k,1:4);
        bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
        rectangle('Position', bbox_draw, 'EdgeColor', 'g', 'LineWidth',2);
        text(bbox_pr(1), bbox_pr(2), num2str(k), 'FontSize', 16, 'BackgroundColor', 'r');
    end
%     tit = sprintf('%s: %.2f %.2f %.2f %.2f %.2f', filenames(i).name(1:end-4), det(1,5), det(2,5), det(3,5), det(4,5), det(5,5));
%     title(tit);
    
    subplot(4, 2, ind);
    hold off;
end