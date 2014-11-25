function create_annotations_KITTI_multi_car

root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/KITTI/multi_car';

seq_names = {'seq0001_00', 'seq0001_01', 'seq0001_02', 'seq0001_03', ...
    'seq0002_00', 'seq0002_01', 'seq0002_02', 'seq0002_03', ...
    'seq0002_04', 'seq0007_00', 'seq0012_00', 'seq0015_00', ...
    'seq0015_01', 'seq0015_02', 'seq0015_03'};

for s = 1:numel(seq_names)
    seq_name = seq_names{s};
    disp(seq_name);
    % load annotation
    filename = fullfile(root_path, seq_name, [seq_name '.mat']);
    object = load(filename);
    data = object.data;
    
    % read the file name for each image
    filenames = textread(fullfile(root_path, seq_name, 'img', 'imlist.txt'), '%s');
    N = numel(filenames);
    % write the annotation file
    for i = 1:N
        filename = fullfile(root_path, seq_name, 'gt', [filenames{i}(1:end-3) 'mat']);
        record.filename = filenames{i};
        bbox = [data(i,1) data(i,2) data(i,3)-data(i,1) data(i,4)-data(i,2)];
        record.objects(1).bbox = bbox;
        record.objects(1).class = 'car';
%         alpha = data(i,5)*180/pi;
%         if alpha < 0
%             alpha = alpha + 360;
%         end
%         alpha = alpha - 90;
%         if alpha < 0
%             alpha = alpha + 360;
%         end        
%         record.objects(1).viewpoint.azimuth_KITTI = alpha;
        save(filename, 'record');
    end
end