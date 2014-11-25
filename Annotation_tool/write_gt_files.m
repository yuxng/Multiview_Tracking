function write_gt_files(cls)

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

N = numel(dir_names);
for i = 1:N
    disp(dir_names{i});
    filename = fullfile(root_path, dir_names{i}, 'gt', '*.mat');
    files = dir(filename);
    j = 1;
    disp(files(j).name);
    file_ann = fullfile(root_path, dir_names{i}, 'gt', files(j).name);
    image = load(file_ann);
    if isfield(image, 'record') == 0
        continue;
    end
    bbox = image.record.objects(1).bbox;
    % write gt file
    fid = fopen(fullfile(root_path, dir_names{i}, [dir_names{i} '_gt.txt']), 'w');
    fprintf(fid, '%f, %f, %f, %f\n', bbox(1), bbox(2), bbox(3), bbox(4));
    fclose(fid);
    % write frame file
    fid = fopen(fullfile(root_path, dir_names{i}, [dir_names{i} '_frames.txt']), 'w');
    index_start = str2double(files(1).name(1:end-4));
    index_end = str2double(files(end).name(1:end-4));
    fprintf(fid, '%d, %d\n', index_start, index_end);
    fclose(fid);    
end