function make_result_video_DPM_ALM

% seq_names = {'BMW_1', 'drift_1', 'FLUFFYJET_1', 'FLUFFYJET_2',...
%     'FLUFFYJET_3', 'FLUFFYJET_4', 'FLUFFYJET_5', 'FLUFFYJET_6', 'TOYOTA_1'};

seq_names = {'06_car'};

for i = 1:numel(seq_names)
    make_result_video_DPM_ALM_one(seq_names{i});
end

function make_result_video_DPM_ALM_one(seq_name)

% prepare the file name for each image
% root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/YOUTUBE/';
root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/TLD/';
filenames = textread(fullfile(root_path, seq_name, 'img', 'imlist.txt'), '%s');
nframes = numel(filenames);
s_frames = cell(nframes,1);
for t = 1:nframes
    s_frames{t} = fullfile(root_path, seq_name, 'img', filenames{t});
end
N = numel(s_frames);

% load DPM detections
result_path = fullfile('../result/DPM_VOC2007/', seq_name);
det_DPM = zeros(N, 4);
for i = 1:N
    filename = fullfile(result_path, [filenames{i}(1:end-3) 'mat']);
    object = load(filename, 'det');
    det = object.det;
    % [x1 y1 x2 y2]
    det_DPM(i,:) = det(1,1:4);
end

% load ALM detections
cad = load('car.mat');
cad = cad.car;
pnames = cad.pnames;
part_num = 6;
filename = sprintf('../result/ALM_old/%s.pre', seq_name);
cad = load('car.mat');
cad = cad.car;
examples = read_samples(filename, cad, N);
det_ALM = zeros(N, 4);
for i = 1:N
    % get predicted bounding box
    det_ALM(i,:) = examples{i}(1).bbox;
end

% create the video
file_video = sprintf('../result/%s_DPM_ALM.avi', seq_name);
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

    % draw DPM detection
    bbox_pr = det_DPM(i, :);
    bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
    rectangle('Position', bbox_draw, 'EdgeColor', 'b', 'LineWidth', 4); 
    
    % draw ALM detection
    bbox_pr = det_ALM(i, :);
    bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
    rectangle('Position', bbox_draw, 'EdgeColor', 'r', 'LineWidth', 4);
    
    example = examples{i};
    k = 1;
    view_label = example(k).view_label;
    part2d = cad.parts2d(view_label);
%     til = sprintf('%d, %s: a=%.2f, e=%.2f, d=%.2f', i, filenames{i}(1:end-4), part2d.azimuth, part2d.elevation, part2d.distance);
    part_label = example(k).part_label;
    for a = 1:part_num
        if isempty(part2d.homographies{a}) == 0 && part_label(a,1) ~= 0 && part_label(a,2) ~= 0
            plot(part_label(a,1), part_label(a,2), 'ro', 'MarkerSize', 4, 'MarkerFaceColor', 'r');
            % render parts
            part = part2d.(pnames{a}) + repmat(part_label(a,:), 5, 1);
            patch('Faces', [1 2 3 4 5], 'Vertices', part, 'FaceColor', 'r',...
                'EdgeColor', 'r', 'FaceAlpha', 0.1, 'LineWidth', 4);           
        end
    end
    
    hold off;
    if i == 1
        pause;
    end     
%     pause;
    writeVideo(aviobj,getframe(figure));
end

close(aviobj);
close all;