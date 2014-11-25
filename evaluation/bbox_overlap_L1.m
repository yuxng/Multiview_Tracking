function overlaps = bbox_overlap_L1(cls)

clc;
switch cls
    case 'YOUTUBE'
        root_path = '../dataset/YOUTUBE';
        dir_names = {'BMW_1', 'drift_1', 'drift_2', 'FLUFFYJET_1', 'FLUFFYJET_2',...
            'FLUFFYJET_3', 'FLUFFYJET_4', 'FLUFFYJET_5', 'FLUFFYJET_6', 'TOYOTA_1'};
    case 'KITTI'
        root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/KITTI/multi_car';
        dir_names = {'seq0001_00', 'seq0001_01', 'seq0001_02', 'seq0001_03', ...
            'seq0002_00', 'seq0002_01', 'seq0002_02', 'seq0002_03', ...
            'seq0002_04', 'seq0007_00', 'seq0012_00', 'seq0015_00', ...
            'seq0015_01', 'seq0015_02', 'seq0015_03'};
    case 'TLD'
        root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/TLD';
        dir_names = {'06_car'};        
end
num = numel(dir_names);
result_path = '../result/L1_APG';
overlaps = cell(num, 1);

for k = 1:num
    dir_name = dir_names{k};
    
    % read ground truth bounding box
    filename = fullfile(root_path, dir_name, 'gt', '*.mat');
    files = dir(filename);
    N = numel(files);
    bbox_gt = zeros(N, 4);
    for i = 1:N
        object = load(fullfile(root_path, dir_name, 'gt', files(i).name));
        % bbox in [x y w h];
        bbox_gt(i,:) = object.record.objects(1).bbox;
    end
    % bbox in [x1 y1 x2 y2];
    bbox_gt(:,3) = bbox_gt(:,1) + bbox_gt(:,3);
    bbox_gt(:,4) = bbox_gt(:,2) + bbox_gt(:,4);
    
    % read tracking results
    filename = fullfile(result_path, dir_name, sprintf('%s_L1_APG_1.mat', dir_name));
    object = load(filename);
    tracking_res = object.tracking_res;
    sz_T = object.sz_T;
    boxes = aff2image(tracking_res, sz_T);
    bbox_pr = zeros(N, 4);
    for i = 1:N
        rect= boxes(:,i);
        inp	= reshape(rect,2,4);
        topleft_r = inp(1,1);
        topleft_c = inp(2,1);
        botright_r = inp(1,4);
        botright_c = inp(2,4);        
        bbox_pr(i,1) = topleft_c;
        bbox_pr(i,2) = topleft_r;
        bbox_pr(i,3) = botright_c;
        bbox_pr(i,4) = botright_r;
    end
    
    % compute overlap
    overlaps{k} = zeros(N, 1);
    count = 0;
    for i = 2:N
        if isnan(bbox_gt(i,1)) == 0
            overlaps{k}(i) = box_overlap(bbox_gt(i,:), bbox_pr(i,:));
            count = count + 1;
        end
    end
    fprintf('%s mean overlap ratio %.2f\n', dir_name, sum(overlaps{k}(2:N)) / count);
%     mostly_tracked = numel(find(overlaps{k}(2:N) > 0.5)) / (N-1);
%     fprintf('%s mostly tracked %.2f\n', dir_name, mostly_tracked);
%     mostly_lost = numel(find(overlaps{k}(2:N) < 0.2)) / (N-1);
%     fprintf('%s mostly lost %.2f\n', dir_name, mostly_lost);
%     fprintf('%s partial tracked %.2f\n\n', dir_name, 1-mostly_lost-mostly_tracked); 
end