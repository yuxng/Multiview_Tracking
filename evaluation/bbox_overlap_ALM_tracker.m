function overlaps = bbox_overlap_ALM_tracker

clc;
root_path = '../dataset/YOUTUBE';
dir_names = {'BMW_1', 'drift_1', 'drift_2', 'FLUFFYJET_1', 'FLUFFYJET_2',...
    'FLUFFYJET_3', 'FLUFFYJET_4', 'FLUFFYJET_5', 'FLUFFYJET_6', 'TOYOTA_1'};
num = numel(dir_names);
result_path = '../result/ALM_Tracker';
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
    filename = fullfile(result_path, sprintf('%s.mat', dir_name));
    object = load(filename);
    boxes = object.bboxes_tracked;
    bbox_pr = zeros(N, 4);
    for i = 1:N
        if isempty(boxes(i).bbox) == 1  
            continue;
        end
        bbox_pr(i,1) = boxes(i).bbox(1);
        bbox_pr(i,2) = boxes(i).bbox(2);
        bbox_pr(i,3) = boxes(i).bbox(3);
        bbox_pr(i,4) = boxes(i).bbox(4);
    end
    
    % compute overlap
    overlaps{k} = zeros(N, 1);
    for i = 2:N
        overlaps{k}(i) = box_overlap(bbox_gt(i,:), bbox_pr(i,:));
    end
    fprintf('%s mean overlap ratio %.2f\n', dir_name, sum(overlaps{k}(2:N)) / (N-1));
    mostly_tracked = numel(find(overlaps{k}(2:N) > 0.5)) / (N-1);
    fprintf('%s mostly tracked %.2f\n', dir_name, mostly_tracked);
    mostly_lost = numel(find(overlaps{k}(2:N) < 0.2)) / (N-1);
    fprintf('%s mostly lost %.2f\n', dir_name, mostly_lost);
    fprintf('%s partial tracked %.2f\n\n', dir_name, 1-mostly_lost-mostly_tracked); 
end