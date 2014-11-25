function save_figure_MVT(seq_name, post)

% load cad model
cad = load('car.mat');
cad = cad.car;

param.cad = cad;
param.category = 'car';

pnames = cad.pnames(1:numel(cad.parts));
part_num = numel(pnames);
color = ['r','y','b','c','w','m'];

%prepare the file name for each image
root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/YOUTUBE/';
% root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/KITTI/multi_car';
filenames = textread(fullfile(root_path, seq_name, 'img', 'imlist.txt'), '%s');
nframes = numel(filenames);
s_frames = cell(nframes,1);
for t = 1:nframes
    s_frames{t} = fullfile(root_path, seq_name, 'img', filenames{t});
end
N = numel(s_frames);

% open prediction file

filename = sprintf('../result/MVT/MVT_%s_%s.txt', seq_name, post);
res = textread(filename);

% output directory
% out_path = ['/home/yuxiang/Projects/Multiview_Tracking/result/MVT/KITTI/' seq_name '/'];
out_path = ['/home/yuxiang/Projects/Multiview_Tracking/result/MVT/YOUTUBE/' seq_name '/'];
if exist(out_path, 'dir') == 0
    mkdir(out_path);
end

for i = 1:N
    hf = figure(1);
    I = imread(s_frames{i});
    subplot(1,1,1);
    imshow(I);
    hold on;

    % get predicted bounding box
    bbox_pr = res(i, 2:5);
    
    viewobj = viewpoint_from_aed(param, res(i,6:8));
%     til = sprintf('%s: a=%.2f, e=%.2f, d=%.2f', filenames{i}(1:end-4), res(i,6), res(i,7), res(i,8));
%     title(til);
    for p = 1:part_num
        if viewobj.parts{p}.is_occluded == 0
            center = [res(i,2*p+9) + res(i,9) res(i,2*p+10) + res(i,10)];
            plot(center(1), center(2), [color(p) 'o'], 'MarkerSize', 4, 'MarkerFaceColor', color(p));
            % render parts
            part = viewobj.parts{p}.shape + repmat(center, 5, 1);
            patch('Faces', [1 2 3 4 5], 'Vertices', part, 'FaceColor', color(p), ...
                'EdgeColor', color(p), 'FaceAlpha', 0.1, 'LineWidth', 2);           
        end
    end
    % draw bounding box
    bbox_draw = bbox_pr;
    rectangle('Position', bbox_draw, 'EdgeColor', 'g', 'LineWidth', 2);
    text(20, 20, ['Frame ' num2str(i)], 'Color', 'y', 'FontSize', 20);
    
    % viewpoint indicator
    [height_img, width_img, ~] = size(I);
    rect_arrow = [width_img*9/10, 0, width_img/10, width_img/10];
    rectangle('Position',rect_arrow, ...
              'EdgeColor',[1 1 1], 'LineWidth', 4, 'FaceColor','w', 'Curvature', [1,1]);
    a = (-viewobj.aed(1)-90)*2*pi/360;
    arrow = [cos(a) sin(a); -sin(a) cos(a)] * [1 0]';
    arrow = arrow';
    arrow = arrow .* rect_arrow(3:4) / 2;
    center_arrow = [rect_arrow(1)+rect_arrow(3)/2, rect_arrow(2)+rect_arrow(4)/2];
    X = [center_arrow(1), center_arrow(1)+arrow(1)];
    Y = [center_arrow(2), center_arrow(2)+arrow(2)];
    line(X, Y, 'LineWidth', 4, 'Color', 'k');    
    
    hold off;
%     filename = fullfile(out_path, [filenames{i}(1:end-3) 'eps']);
%     saveas(hf, filename, 'psc2');
%     filename = fullfile(out_path, [filenames{i}(1:end-4) '_' post '.png']);
%     saveas(hf, filename);
%     close all;
    pause;
end    