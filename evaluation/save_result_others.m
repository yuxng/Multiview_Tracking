function save_result_others(seq_name)

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
color = ['r','y','b','c','w','m'];

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

% show the results
% output directory
out_path = ['/home/yuxiang/Projects/Multiview_Tracking/result/ALM/' seq_name '/'];
if exist(out_path, 'dir') == 0
    mkdir(out_path);
end
for i = 2:N
    hf = figure(1);
    I = imread(s_frames{i});
    imshow(I);
    hold on;  

%     % draw DPM detection
%     bbox_pr = det_DPM(i, :);
%     bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
%     rectangle('Position', bbox_draw, 'EdgeColor', 'b', 'LineWidth', 2); 
%     
    % draw ALM detection
    bbox_pr = det_ALM(i, :);
    bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
    rectangle('Position', bbox_draw, 'EdgeColor', 'g', 'LineWidth', 2);
    
    example = examples{i};
    k = 1;
    view_label = example(k).view_label;
    part2d = cad.parts2d(view_label);
    til = sprintf('%d, %s: a=%.2f, e=%.2f, d=%.2f', i, filenames{i}(1:end-4), part2d.azimuth, part2d.elevation, part2d.distance);
    part_label = example(k).part_label;
    for a = 1:part_num
        if isempty(part2d.homographies{a}) == 0 && part_label(a,1) ~= 0 && part_label(a,2) ~= 0
            plot(part_label(a,1), part_label(a,2), [color(a) 'o'], 'MarkerSize', 4, 'MarkerFaceColor', color(a));
            % render parts
            part = part2d.(pnames{a}) + repmat(part_label(a,:), 5, 1);
            patch('Faces', [1 2 3 4 5], 'Vertices', part, 'FaceColor', color(a),...
                'EdgeColor', color(a), 'FaceAlpha', 0.1, 'LineWidth', 2);           
        end
    end
    title(til);
    
%     % draw MIL detection
%     bbox_pr = bbox_MIL(i, :);
%     bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
%     rectangle('Position', bbox_draw, 'EdgeColor', 'g', 'LineWidth', 2);    
%     
%     % draw L1 detection
%     bbox_pr = bbox_L1(i, :);
%     bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
%     rectangle('Position', bbox_draw, 'EdgeColor', 'y', 'LineWidth', 2);      
    
%     % draw TLD detection
%     bbox_pr = bbox_TLD(i, :);
%     if isnan(bbox_pr(1)) == 0
%         bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
%         rectangle('Position', bbox_draw, 'EdgeColor', 'c', 'LineWidth', 4);
%     else
%         title('TLD lost');
%     end
    
%     % draw Struct detection
%     bbox_pr = bbox_Struct(i, :);
%     bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
%     rectangle('Position', bbox_draw, 'EdgeColor', 'm', 'LineWidth', 2);      
    
    hold off;
    filename = fullfile(out_path, [filenames{i}(1:end-4) '_ALM.png']);
    saveas(hf, filename);
    close all;    
%     pause;
end