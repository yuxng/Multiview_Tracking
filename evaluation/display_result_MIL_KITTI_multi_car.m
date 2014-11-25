function display_result_MIL_KITTI_multi_car

root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/KITTI/multi_car';

seq_names = {'seq0001_00', 'seq0001_01', 'seq0001_02', 'seq0001_03', ...
    'seq0002_00', 'seq0002_01', 'seq0002_02', 'seq0002_03', ...
    'seq0002_04', 'seq0007_00', 'seq0012_00', 'seq0015_00', ...
    'seq0015_01', 'seq0015_02', 'seq0015_03'};

for s = 1:numel(seq_names)
    seq_name = seq_names{s};
    disp(seq_name);
    % prepare the file name for each image
    filenames = textread(fullfile(root_path, seq_name, 'img', 'imlist.txt'), '%s');
    nframes = numel(filenames);
    s_frames = cell(nframes,1);
    for t = 1:nframes
        s_frames{t} = fullfile(root_path, seq_name, 'img', filenames{t});
    end
    N = numel(s_frames);

    % get tracking results
    result_path = '../result/MIL';
    filename = fullfile(result_path, seq_name, 'MIL.txt');
    fid = fopen(filename);
    C = textscan(fid, '%s %f %f %f %f');
    fclose(fid);
    bbox_pr = zeros(N, 4);
    bbox_pr(2:end,1) = C{2};
    bbox_pr(2:end,2) = C{3};
    bbox_pr(2:end,3) = C{4};
    bbox_pr(2:end,4) = C{5};

    figure(1);
    for i = 2:N
        I = imread(s_frames{i});
        imshow(I);
        hold on;
        
        % get predicted bounding box
        bbox_draw = bbox_pr(i,:);
        rectangle('Position', bbox_draw, 'EdgeColor', 'g', 'LineWidth',2);

        hold off;
        pause;
    end
end