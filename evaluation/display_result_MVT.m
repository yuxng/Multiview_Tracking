function display_result_MVT(seq_name, post)

% load cad model
cad = load('car.mat');
cad = cad.car;

param.cad = cad;
param.category = 'car';

pnames = cad.pnames(1:numel(cad.parts));
part_num = numel(pnames);

%prepare the file name for each image
% root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/YOUTUBE/';
root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/KITTI/multi_car';
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

figure;
for i = 1:N
%     if i ~= 1 && mod(i-1, 8) == 0
%         pause;
%     end
%     ind = mod(i-1,8)+1;
    
    I = imread(s_frames{i});
%     subplot(4, 2, ind);
    imshow(I);
    hold on;

    % get predicted bounding box
    bbox_pr = res(i, 2:5);
    
    viewobj = viewpoint_from_aed(param, res(i,6:8));
    til = sprintf('%s: a=%.2f, e=%.2f, d=%.2f', filenames{i}, res(i,6), res(i,7), res(i,8));
    title(til);
    for p = 1:part_num
        if viewobj.parts{p}.is_occluded == 0
            center = [res(i,2*p+9) + res(i,9) res(i,2*p+10) + res(i,10)];
            plot(center(1), center(2), 'ro');
            % render parts
            part = viewobj.parts{p}.shape + repmat(center, 5, 1);
            patch('Faces', [1 2 3 4 5], 'Vertices', part, 'FaceColor', 'r', 'EdgeColor', 'r', 'FaceAlpha', 0.1);           
        end
    end
    % draw bounding box
    bbox_draw = bbox_pr;
    rectangle('Position', bbox_draw, 'EdgeColor', 'g', 'LineWidth',2);
    
%     subplot(4, 2, ind);
    hold off;
    pause;
end    