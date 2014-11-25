function make_result_video_bbox(seq_name)

% prepare the file name for each image
root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/YOUTUBE/';
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
% filename = sprintf('../result/ALM_old/%s.pre', seq_name);
% cad = load('car.mat');
% cad = cad.car;
% examples = read_samples(filename, cad, N);
% det_ALM = zeros(N, 4);
% for i = 1:N
%     % get predicted bounding box
%     det_ALM(i,:) = examples{i}(1).bbox;
% end

% load DPM+PF detections
filename = sprintf('../result/MVT/MVT_%s_DPM.txt', seq_name);
res = textread(filename);
det_DPM_PF = res(:,2:5);

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
file_video = sprintf('../result/%s_bbox.avi', seq_name);
aviobj = VideoWriter(file_video);
aviobj.FrameRate = 6;
open(aviobj);

figure = subplot(1,1,1);
fontsize_frame = 20;
fontcolor_frame = 'yellow';
axis equal;
for i = 1:N    
    I = imread(s_frames{i});
    imshow(I,'Parent',figure);
    hold on;
    
    % frame number
    text(fontsize_frame,fontsize_frame,filenames{i}(1:end-4),'FontSize',fontsize_frame,'Color',fontcolor_frame);    

    % draw DPM detection
    bbox_pr = det_DPM(i, :);
    bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
    h1 = rectangle('Position', bbox_draw, 'EdgeColor', 'b', 'LineWidth', 4);
    
    % draw DPM+PF detection
    bbox_pr = det_DPM_PF(i, :);
    bbox_draw = bbox_pr;
    h2 = rectangle('Position', bbox_draw, 'EdgeColor', 'r', 'LineWidth', 4);    
    
    % draw ALM detection
%     bbox_pr = det_ALM(i, :);
%     bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
%     h2 = rectangle('Position', bbox_draw, 'EdgeColor', 'r', 'LineWidth', 4);
    
    % draw GT detection
    bbox_pr = det_gt(i, :);
    bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
    h3 = rectangle('Position', bbox_draw, 'EdgeColor', 'g', 'LineWidth', 4);    
    
    rect_legend([h1 h2 h3], {'DPM', 'DPM+PF', 'GT'});
    
    hold off;
    writeVideo(aviobj,getframe(figure));
end

close(aviobj);
close all;

function rect_legend(h,str)

p = zeros(length(h),1);
for n = 1:length(h)
    p(n)=plot(nan,nan,'s','markeredgecolor',get(h(n),'edgecolor'),...
    'markerfacecolor',get(h(n),'facecolor'));
end
h = legend(p, str);
set(h, 'FontSize', 30);