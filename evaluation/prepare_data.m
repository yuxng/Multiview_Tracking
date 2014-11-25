function [X, Y] = prepare_data

% images
root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/car_3D/img';
filenames = dir(fullfile(root_path, '*.jpg'));
N = numel(filenames);

% load DPM detections
result_path = '../result/DPM_VOC2007/car_3D';
det_DPM = zeros(N, 4);
for i = 1:N
    filename = fullfile(result_path, [filenames(i).name(1:end-3) 'mat']);
    object = load(filename, 'det');
    det = object.det;
    % [x1 y1 x2 y2]
    det_DPM(i,:) = det(1,1:4);
end

% load ALM detections
addpath('/home/yuxiang/Projects/Multiview_Tracking/evaluation');
filename = '../result/ALM_old/car_3D.pre';
cad = load('../evaluation/car.mat');
cad = cad.car;
examples = read_samples(filename, cad, N);
det_ALM = zeros(N, 4);
for i = 1:N
    % get predicted bounding box
    det_ALM(i,:) = examples{i}(1).bbox;
end

% load ground truth bounding boxes
gt_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/car_3D/gt';
det_gt = zeros(N, 4);
for i = 1:N
    filename = fullfile(gt_path, [filenames(i).name(1:end-3) 'mat']);
    object = load(filename);
    det = object.record.objects(1).bbox;
    % [x1 y1 x2 y2]
    det_gt(i,:) = [det(1) det(2) det(1)+det(3) det(2)+det(4)];
end

X = [det_DPM det_ALM];
Y = det_gt;