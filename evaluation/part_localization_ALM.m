function part_localization_ALM

clc;  
root_path = '../dataset/YOUTUBE';
dir_names = {'BMW_1', 'drift_1', 'drift_2', 'FLUFFYJET_1', 'FLUFFYJET_2',...
    'FLUFFYJET_3', 'FLUFFYJET_4', 'FLUFFYJET_5', 'FLUFFYJET_6', 'TOYOTA_1'};
num = numel(dir_names);
result_path = '../result/ALM_old';
object = load('car.mat');
cad = object.car;
pnames = cad.pnames(1:numel(cad.parts));

results = zeros(num, 1);
for k = 1:num
    dir_name = dir_names{k};
    
    % read ground viewpoint
    filename = fullfile(root_path, dir_name, 'gt', '*.mat');
    files = dir(filename);
    N = numel(files);
    bbox_gt = zeros(N, 4);
    part_gt = cell(N, 1);
    for i = 1:N
        object = load(fullfile(root_path, dir_name, 'gt', files(i).name));
        object = object.record.objects(1);
        bbox_gt(i,:) = object.bbox;
        if isfield(object, 'viewpoint') == 1
            part_gt{i} = object.parts;
        else
            part_gt{i} = [];
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
    part_pr = cell(N, 1);
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
        view_pr(i) = example(index).view_label;
        part_pr{i} = example(index).part_label;
    end
    
    % part overlapping ratio
    count = 0;
    ratio_sum = 0;
    for i = 1:N
        o = box_overlap(bbox_gt(i,:), bbox_pr(i,:));
        if isempty(part_gt{i}) == 1 || o < 0.5  
            continue;
        end
        for j = 1:numel(pnames)
            % ground truth part center and shape
            center_gt = part_gt{i}.(pnames{j}).center;
            shape_gt = part_gt{i}.(pnames{j}).shape;
            if isempty(center_gt) == 0
                count = count + 1;
                x_shape_gt    = shape_gt(:,1) + center_gt(1);
                y_shape_gt    = shape_gt(:,2) + center_gt(2);
                if part_pr{i}(j,1) ~= 0 && part_pr{i}(j,2) ~= 0
%                   count = count + 1;
                    % predicted part center and shape
                    center_pr = part_pr{i}(j,:);
                    shape_pr = cad.parts2d(view_pr(i)).(pnames{j});
                    x_shape_pr = shape_pr(:,1) + center_pr(1);
                    y_shape_pr = shape_pr(:,2) + center_pr(2);
                    [xi, yi] = polybool('intersection', ...
                                        x_shape_gt, y_shape_gt, ...
                                        x_shape_pr, y_shape_pr );
                    area_gt = polyarea(x_shape_gt, y_shape_gt);
                    area_pr = polyarea(x_shape_pr, y_shape_pr);
                    area_over = polyarea(xi,yi);

                    area_union = area_gt + area_pr - area_over;
                    ratio = area_over / area_union;
%                     ratio_sum = ratio_sum + ratio;
                else
                    ratio = 0;
                end
                ratio_sum = ratio_sum + ratio;
            end
        end
    end
    fprintf('%s mean part localization overlapping ratio %.2f\n', dir_name, ratio_sum / count);
    results(k) = ratio_sum / count;
end
fprintf('Mean overlapping ratio %.2f\n', mean(results));