function write_image_lists

% root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/YOUTUBE';
% dir_names = {'BMW_1', 'drift_1', 'drift_2', 'FLUFFYJET_1', 'FLUFFYJET_2',...
%     'FLUFFYJET_3', 'FLUFFYJET_4', 'FLUFFYJET_5', 'FLUFFYJET_6', 'TOYOTA_1'};
% exts = {'*.jpg', '*.jpg', '*.png', '*.png', '*.png', '*.png', '*.png', '*.png', '*.png', '*.jpg'};

% root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset';
% dir_names = {'car_3D'};
% exts = {'*.jpg'};

% root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/KITTI/multi_car';
% dir_names = {'seq0001_00', 'seq0001_01', 'seq0001_02', 'seq0001_03', ...
%     'seq0002_00', 'seq0002_01', 'seq0002_02', 'seq0002_03', ...
%     'seq0002_04', 'seq0007_00', 'seq0012_00', 'seq0015_00', ...
%     'seq0015_01', 'seq0015_02', 'seq0015_03'};
% ext = '*.png';

root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/TLD';
dir_names = {'06_car'};
ext = '*.jpg';

N = numel(dir_names);
for i = 1:N
    disp(dir_names{i});
    imfile = fullfile(root_path, dir_names{i}, 'img', 'imlist.txt');
    fid = fopen(imfile, 'w');
    
    filename = fullfile(root_path, dir_names{i}, 'img', ext);
    files = dir(filename);
    for j = 1:numel(files)
        disp(files(j).name);
        fprintf(fid, '%s\n', files(j).name);
    end
    fclose(fid);
end