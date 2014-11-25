function display_result_TLD(seq_name)

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
result_path = '../result/OpenTLD';
result_file = fullfile(result_path, seq_name, 'tld.txt');
fid = fopen(result_file);
C = textscan(fid, '%f %f %f %f %f', 'delimiter', ',');
fclose(fid);
det = [C{1} C{2} C{3}-C{1} C{4}-C{2}];

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
    if isnan(det(i,1)) == 0
        bbox_draw = det(i,:);
        rectangle('Position', bbox_draw, 'EdgeColor', 'g', 'LineWidth',2);
    end
    
    subplot(4, 4, ind);
    hold off;
end