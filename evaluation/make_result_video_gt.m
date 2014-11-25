function make_result_video_gt

root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/YOUTUBE/';
seq_names = {'BMW_1', 'drift_1', 'FLUFFYJET_1', 'FLUFFYJET_2',...
    'FLUFFYJET_3', 'FLUFFYJET_4', 'FLUFFYJET_5', 'FLUFFYJET_6', 'TOYOTA_1'};

% root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/KITTI/multi_car';
% 
% seq_names = {'seq0001_00', 'seq0001_01', 'seq0001_02', 'seq0001_03', ...
%     'seq0002_00', 'seq0002_01', 'seq0002_02', 'seq0002_03', ...
%     'seq0002_04', 'seq0007_00', 'seq0012_00', 'seq0015_00', ...
%     'seq0015_01', 'seq0015_02', 'seq0015_03'};

for i = 1:numel(seq_names)
    make_result_video_gt_one(root_path, seq_names{i});
end

function make_result_video_gt_one(root_path, seq_name)

% prepare the file name for each image
filenames = textread(fullfile(root_path, seq_name, 'img', 'imlist.txt'), '%s');
nframes = numel(filenames);
s_frames = cell(nframes,1);
for t = 1:nframes
    s_frames{t} = fullfile(root_path, seq_name, 'img', filenames{t});
end
N = numel(s_frames);

% load ground truth bounding boxes
gt_path = fullfile(root_path, seq_name, 'gt');
det_gt = zeros(N, 4);
for i = 1:N
    filename = fullfile(gt_path, [filenames{i}(1:end-3) 'mat']);
    object = load(filename);
    det = object.record.objects(1).bbox;
    % [x1 y1 x2 y2]
    det_gt(i,:) = [det(1) det(2) det(1)+det(3) det(2)+det(4)];
end

% create the video
file_video = sprintf('../result/%s_gt.avi', seq_name);
aviobj = VideoWriter(file_video);
aviobj.FrameRate = 9;
open(aviobj);

figure = subplot(1,1,1);
fontsize_frame = 20;
fontcolor_frame = 'yellow';
for i = 1:N    
    I = imread(s_frames{i});
    imshow(I,'Parent',figure);
    hold on;
    
    % frame number
    text(fontsize_frame, fontsize_frame, ['Frame ' num2str(i)], 'Color', fontcolor_frame, 'FontSize', fontsize_frame);  

    % draw GT detection
%     bbox_pr = det_gt(i, :);
%     bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
%     rectangle('Position', bbox_draw, 'EdgeColor', 'g', 'LineWidth', 4);     
    
    hold off;
%     pause;
    writeVideo(aviobj,getframe(figure));
end

close(aviobj);
close all;