function make_result_video_online

% root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/YOUTUBE/';
% seq_names = {'BMW_1', 'drift_1', 'FLUFFYJET_1', 'FLUFFYJET_2',...
%     'FLUFFYJET_3', 'FLUFFYJET_4', 'FLUFFYJET_5', 'FLUFFYJET_6', 'TOYOTA_1'};

% root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/KITTI/multi_car';
% 
% seq_names = {'seq0001_00', 'seq0001_01', 'seq0001_02', 'seq0001_03', ...
%     'seq0002_00', 'seq0002_01', 'seq0002_02', 'seq0002_03', ...
%     'seq0002_04', 'seq0007_00', 'seq0012_00', 'seq0015_00', ...
%     'seq0015_01', 'seq0015_02', 'seq0015_03'};

root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/TLD';
seq_names = {'06_car'}; 

for i = 1:numel(seq_names)
    make_result_video_online_one(root_path, seq_names{i});
end

function make_result_video_online_one(root_path, seq_name)

% prepare the file name for each image
filenames = textread(fullfile(root_path, seq_name, 'img', 'imlist.txt'), '%s');
nframes = numel(filenames);
s_frames = cell(nframes,1);
for t = 1:nframes
    s_frames{t} = fullfile(root_path, seq_name, 'img', filenames{t});
end
N = numel(s_frames);

% load MIL tracking results
filename = sprintf('../result/MIL/%s/MIL.txt', seq_name);
fid = fopen(filename);
C = textscan(fid, '%s %f %f %f %f');
fclose(fid);
bbox_MIL = zeros(N, 4);
bbox_MIL(2:end,1) = C{2};
bbox_MIL(2:end,2) = C{3};
bbox_MIL(2:end,3) = C{2}+C{4};
bbox_MIL(2:end,4) = C{3}+C{5};

% load L1 tracking results
result_path = '../result/L1_APG';
filename = fullfile(result_path, seq_name, sprintf('%s_L1_APG_1.mat', seq_name));
object = load(filename);
tracking_res = object.tracking_res;
sz_T = object.sz_T;
boxes = aff2image(tracking_res, sz_T);
bbox_L1 = zeros(N, 4);
for i = 1:N
    rect= boxes(:,i);
    inp	= reshape(rect,2,4);
    topleft_r = inp(1,1);
    topleft_c = inp(2,1);
    botright_r = inp(1,4);
    botright_c = inp(2,4);        
    bbox_L1(i,1) = topleft_c;
    bbox_L1(i,2) = topleft_r;
    bbox_L1(i,3) = botright_c;
    bbox_L1(i,4) = botright_r;
end

% load TLD tracking results
result_path = '../result/OpenTLD';
filename = fullfile(result_path, seq_name, 'tld.txt');
fid = fopen(filename);
C = textscan(fid, '%f %f %f %f %f', 'delimiter', ',');
fclose(fid);
bbox_TLD = zeros(N, 4);
bbox_TLD(:,1) = C{1};
bbox_TLD(:,2) = C{2};
bbox_TLD(:,3) = C{3};
bbox_TLD(:,4) = C{4};

% load Struct tracking results
result_path = '../result/Struct';
filename = fullfile(result_path, [seq_name '.txt']);
fid = fopen(filename);
C = textscan(fid, '%f %f %f %f', 'delimiter', ',');
fclose(fid);
bbox_Struct = zeros(N, 4);
bbox_Struct(:,1) = C{1};
bbox_Struct(:,2) = C{2};
bbox_Struct(:,3) = C{1}+C{3};
bbox_Struct(:,4) = C{2}+C{4};

% create the video
file_video = sprintf('../result/%s_online.avi', seq_name);
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

    % draw MIL detection
    if i == 1
        bbox_pr = bbox_TLD(1,:);
    else
        bbox_pr = bbox_MIL(i, :);
    end
    bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
    rectangle('Position', bbox_draw, 'EdgeColor', 'g', 'LineWidth', 4);    
    
    % draw L1 detection
    bbox_pr = bbox_L1(i, :);
    bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
    rectangle('Position', bbox_draw, 'EdgeColor', 'y', 'LineWidth', 4);      
    
    % draw TLD detection
    bbox_pr = bbox_TLD(i, :);
    if isnan(bbox_pr(1)) == 0
        bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
        rectangle('Position', bbox_draw, 'EdgeColor', 'c', 'LineWidth', 4);
%     else
%         title('TLD lost');
    end
    
    % draw Struct detection
    bbox_pr = bbox_Struct(i, :);
    bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
    rectangle('Position', bbox_draw, 'EdgeColor', 'm', 'LineWidth', 4); 
    
    hold off;
%     pause;
    writeVideo(aviobj,getframe(figure));
end

close(aviobj);
close all;