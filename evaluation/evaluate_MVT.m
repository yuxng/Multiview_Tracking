function evaluate_MVT

clc;
modules = {'DPMALMMIL'}; %'DPMALM' 'DPMALMMIL'};
n_modules = numel(modules);

is_box_prediction = 0;
if is_box_prediction == 1
    object = load('box_prediction_weights');
    B = object.B;
end

for m = 1:n_modules
    
    module = modules{m};

    fprintf('\n\n%s\n',module);

    postfix = '';

    % load cad model
    cad = load('car.mat');
    cad = cad.car;
    param.cad = cad;
    param.category = 'car';

    homd_path = '/home/yuxiang/Projects/Multiview_Tracking/mvt/';
    gt_path = [homd_path 'gt/'];
    dir_names = {'FLUFFYJET_1', 'FLUFFYJET_2', 'FLUFFYJET_3', ...
                 'FLUFFYJET_4', 'FLUFFYJET_5', 'FLUFFYJET_6', ...
                 'drift_1', 'BMW_1', 'TOYOTA_1', 'drift_2'};
    num = numel(dir_names);
    result_path = '/home/yuxiang/Projects/Multiview_Tracking/result/MVT';
    overlaps = cell(num, 1);

    for k = 1:9
        dir_name = dir_names{k};
        
        % read ground truth annotations
        filename = fullfile(gt_path, dir_name, 'gt', '*.mat');
        files = dir(filename);
        N = numel(files);
        bbox_gt = zeros(N, 4);
        view_gt = zeros(N, 1);
        elevation_gt = zeros(N, 1);
        part_gt = cell(N, 1);
        for i = 1:N
            object = load(fullfile(gt_path, dir_name, 'gt', files(i).name));
            object = object.record.objects(1);
            bbox_gt(i,:) = object.bbox;
            if isfield(object, 'viewpoint') == 1 && isempty(object.parts) == 0
                view_gt(i) = object.viewpoint.azimuth;
                elevation_gt(i) = object.viewpoint.elevation;
                part_gt{i} = object.parts;
            else
                view_gt(i) = -1;
                elevation_gt(i) = -1;
                part_gt{i} = [];
            end
        end
        % bbox in [x1 y1 x2 y2];
        bbox_gt(:,3) = bbox_gt(:,1) + bbox_gt(:,3);
        bbox_gt(:,4) = bbox_gt(:,2) + bbox_gt(:,4);
        
        % read tracking results
        filename = fullfile(result_path, sprintf(['MVT_%s_' module postfix '.txt'], dir_name));
        res = textread(filename);
        assert(N == size(res, 1));
        bbox_pr = zeros(N, 4);
        view_pr = zeros(N, 1);
        elevation_pr = zeros(N, 1);
        part_pr = cell(N, 1);
        for i = 1:N
            bbox_DPM = [res(i,2) res(i,3) res(i,2)+res(i,4) res(i,3)+res(i,5)];
            view_pr(i) = res(i, 6);
            elevation_pr(i) = res(i, 7);
            viewobj_track = viewpoint_from_aed( param, res(i,6:8));
            part_pr{i} = viewobj_track.parts;
            bbox_ALM = compute_bbox_ALM(part_pr{i}, res(i,:));
            if is_box_prediction == 1
                bbox_pr(i,:) = [bbox_DPM bbox_ALM] * B;
            else
                bbox_pr(i,:) = bbox_DPM;
            end
        end        
        
        % compute bbox overlap
        overlaps{k} = zeros(N, 1);
        for i = 2:N
            overlaps{k}(i) = box_overlap(bbox_gt(i,:), bbox_pr(i,:));
        end
        fprintf('%s mean overlap ratio %.2f\n', dir_name, sum(overlaps{k}(2:N)) / (N-1));
%         mostly_tracked = numel(find(overlaps{k}(2:N) > 0.5)) / (N-1);
%         fprintf('%s mostly tracked %.2f\n', dir_name, mostly_tracked);
%         mostly_lost = numel(find(overlaps{k}(2:N) < 0.2)) / (N-1);
%         fprintf('%s mostly lost %.2f\n', dir_name, mostly_lost);
%         fprintf('%s partial tracked %.2f\n', dir_name, 1-mostly_lost-mostly_tracked);
        
        % viewpoint accuracy
        TP = 0;
        FP = 0;
        azimuth_diff = 0;
        elevation_diff = 0;
        diffs = [];
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
                diffs = [diffs diff];
                
                elevation_diff = elevation_diff + abs(elevation_gt(i) - elevation_pr(i));
            end
        end
        accuracy = TP / (TP + FP);
        abs_diff = azimuth_diff / (TP + FP);
        ele_diff = elevation_diff / (TP + FP);
        fprintf('%s viewpoint accurarcy %.2f, absolute difference in azimuth %.2f, in elevation %.2f, std %.2f\n', dir_name, accuracy, abs_diff, ele_diff, std(diffs));
        
        % part overlapping ratio
        count = 0;
        ratio_sum = 0;
        pnames = cad.pnames(1:numel(cad.parts));
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
                    if  part_pr{i}{j}.is_occluded == 0
%                         count = count + 1;
                        % predicted part center and shape
                        
                        x_shape_pr = part_pr{i}{j}.shape(:,1) + res(i,2*j+9) + res(i,9);
                        y_shape_pr = part_pr{i}{j}.shape(:,2) + res(i,2*j+10) + res(i,10);                        
                        [xi, yi] = polybool('intersection', ...
                                            x_shape_gt, y_shape_gt, ...
                                            x_shape_pr, y_shape_pr );
                        area_gt = polyarea(x_shape_gt, y_shape_gt);
                        area_pr = polyarea(x_shape_pr, y_shape_pr);
                        area_over = polyarea(xi,yi);

                        area_union = area_gt + area_pr - area_over;
                        ratio = area_over / area_union;
%                         ratio_sum = ratio_sum + ratio;
                    else
                        ratio = 0;
                    end
                    ratio_sum = ratio_sum + ratio;
                end
            end
        end
        fprintf('%s mean part localization overlapping ratio %.2f\n\n', dir_name, ratio_sum / count);
    end
end

% get the bounding box from aspect parts
function bbox = compute_bbox_ALM(parts, res)

part_num = numel(parts);
bbox = [inf inf -inf -inf];

for p = 1:part_num-8
   if parts{p}.is_occluded == 0
        center = [res(2*p+9) + res(9) res(2*p+10) + res(10)];
        % render parts
        part = parts{p}.shape + repmat(center, 5, 1);
        bbox(1) = min(bbox(1), min(part(:,1)));
        bbox(2) = min(bbox(2), min(part(:,2)));
        bbox(3) = max(bbox(3), max(part(:,1)));
        bbox(4) = max(bbox(4), max(part(:,2)));
    end
end
