function viewpoint_ALM(cls)

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
result_path = '../result/ALM_old';
object = load('car.mat');
cad = object.car;

accuracy = zeros(num, 1);
abs_diff = zeros(num, 1);

for k = 1:num
    dir_name = dir_names{k};
    
    % read ground viewpoint
    filename = fullfile(root_path, dir_name, 'gt', '*.mat');
    files = dir(filename);
    N = numel(files);
    bbox_gt = zeros(N, 4);
    view_gt = zeros(N, 1);
    for i = 1:N
        object = load(fullfile(root_path, dir_name, 'gt', files(i).name));
        object = object.record.objects(1);
        bbox_gt(i,:) = object.bbox;
        if isfield(object, 'viewpoint') == 1
            view_gt(i) = object.viewpoint.azimuth;
        else
            view_gt(i) = -1;
        end
    end
    % bbox in [x1 y1 x2 y2];
    bbox_gt(:,3) = bbox_gt(:,1) + bbox_gt(:,3);
    bbox_gt(:,4) = bbox_gt(:,2) + bbox_gt(:,4);    
    
    % read detection results
    filename = fullfile(result_path, [dir_name '.pre']);
    examples = read_samples(filename, cad, N);
    assert(N == numel(examples));
    bbox_pr = zeros(N, 4);
    view_pr = zeros(N, 1);
    for i = 1:N
        % assign bbox
        example = examples{i};
        bbox = extractfield(example, 'bbox')';
        bbox = reshape(bbox, 4, numel(example));
        bbox = bbox';
        o = box_overlap(bbox, bbox_gt(i,:));
        index = find(o > 0.5);
        if isempty(index) == 1
            [~, index] = max(o);
        else
            index = index(1);
        end
        
        bbox_pr(i,:) = example(index).bbox;
        view_label = example(index).view_label;
        view_pr(i) = cad.parts2d(view_label).azimuth;
    end
    
    % viewpoint accuracy
    TP = 0;
    FP = 0;
    azimuth_diff = 0;
    for i = 1:N
        o = box_overlap(bbox_gt(i,:), bbox_pr(i,:));
        if view_gt(i) ~= -1 && o > 0.5
            amax = max(view_gt(i), view_pr(i));
            amin = min(view_gt(i), view_pr(i));
            diff = min(amax - amin, 360 - amax + amin);
            if diff < 15
                TP = TP + 1;
            else
                FP = FP + 1;
            end
            azimuth_diff = azimuth_diff + diff;
        end
    end
    accuracy(k) = TP / (TP + FP);
    abs_diff(k) = azimuth_diff / (TP + FP);
    fprintf('%s viewpoint accurarcy %.2f, absolute difference in azimuth %.2f\n', dir_name, accuracy(k), abs_diff(k));
end

fprintf('mean accuracy %.2f, mean azimuth difference %.2f\n', mean(accuracy), mean(abs_diff));

function ind = find_interval(azimuth, num)

if num == 8
    a = 22.5:45:337.5;
elseif num == 24
    a = 7.5:15:352.5;
elseif num == 16
    a = 11.25:22.5:348.75;
end

for i = 1:numel(a)
    if azimuth < a(i)
        break;
    end
end
ind = i;
if azimuth > a(end)
    ind = 1;
end