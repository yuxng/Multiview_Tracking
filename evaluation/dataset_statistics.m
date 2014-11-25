function dataset_statistics

clc;
% root_path = '../dataset/YOUTUBE';
% dir_names = {'BMW_1', 'drift_1', 'drift_2', 'FLUFFYJET_1', 'FLUFFYJET_2',...
%     'FLUFFYJET_3', 'FLUFFYJET_4', 'FLUFFYJET_5', 'FLUFFYJET_6', 'TOYOTA_1'};

root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/KITTI/multi_car';

dir_names = {'seq0001_00', 'seq0001_01', 'seq0001_02', 'seq0001_03', ...
    'seq0002_00', 'seq0002_01', 'seq0002_02', 'seq0002_03', ...
    'seq0002_04', 'seq0007_00', 'seq0012_00', 'seq0015_00', ...
    'seq0015_01', 'seq0015_02', 'seq0015_03'};

num = numel(dir_names);

count = 0;
for k = 1:num
    dir_name = dir_names{k};
    
    % read ground truth bounding box
    filename = fullfile(root_path, dir_name, 'gt', '*.mat');
    files = dir(filename);
    N = numel(files);
    count = count + N;
    
    object = load(fullfile(root_path, dir_name, 'gt', files(1).name));
    aprev = object.record.objects(1).viewpoint.azimuth;
    eprev = object.record.objects(1).viewpoint.elevation;
    dprev = object.record.objects(1).viewpoint.distance;
    bbox = object.record.objects(1).bbox;
    sprev = bbox(3)*bbox(4);
    adiff = 0;
    ediff = 0;
    ddiff = 0;
    sdiff = 0;
    for i = 2:N
        object = load(fullfile(root_path, dir_name, 'gt', files(i).name));
        object = object.record.objects(1);
        bbox = object.bbox;
        s = bbox(3)*bbox(4);
        sdiff = sdiff + max(s/sprev, sprev/s) - 1;
        sprev = s;
        if isfield(object, 'viewpoint') == 1
            a = object.viewpoint.azimuth;
            e = object.viewpoint.elevation;
            d = object.viewpoint.distance;
            tmp1 = a - aprev;
            if tmp1 < 0
                tmp1 = 360 + tmp1;
            end
            tmp2 = aprev - a;
            if tmp2 < 0
                tmp2 = 360 + tmp2;
            end
            adiff = adiff + min(tmp1, tmp2);
            ediff = ediff + abs(e - eprev);
            ddiff = ddiff + abs(d - dprev);
            aprev = a;
            eprev = e;
            dprev = d;
        end
    end
    fprintf('%s: length %d azimuth change %.2f/%.2f, elevation change %.2f/%.2f, distance change %.2f/%.2f, scale change %.2f/%.2f\n', ...
        dir_name, N, adiff, adiff/N, ediff, ediff/N, ddiff, ddiff/N, sdiff, sdiff/N);
end
disp(count);