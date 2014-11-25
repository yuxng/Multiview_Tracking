function display_result_struct(seq_name)

% prepare the file name for each image
root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/YOUTUBE/';
filenames = textread(fullfile(root_path, seq_name, 'img', 'imlist.txt'), '%s');
nframes = numel(filenames);
s_frames = cell(nframes,1);
for t = 1:nframes
    s_frames{t} = fullfile(root_path, seq_name, 'img', filenames{t});
end
N = numel(s_frames);

% get detection results
result_path = '../result/Struct';
result_file = fullfile(result_path, [seq_name '.txt']);
fid = fopen(result_file);
C = textscan(fid, '%d%d%d%d', 'delimiter', ',');
det = [C{1} C{2} C{3} C{4}];

figure;
for i = 1:N
    if i ~= 1 && mod(i-1, 16) == 0
        pause;
    end
    ind = mod(i-1,16)+1;
    
    I = imread(s_frames{i});
    subplot(4, 4, ind);
    imshow(I);
    hold on;

    % get predicted bounding box
    bbox_draw = det(1,:);
    rectangle('Position', bbox_draw, 'EdgeColor', 'g', 'LineWidth',2);
    
    subplot(4, 4, ind);
    hold off;
end