function display_result_DPM_KITTI_multi_car

root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/KITTI/multi_car';

seq_names = {'seq0001_00', 'seq0001_01', 'seq0001_02', 'seq0001_03', ...
    'seq0002_00', 'seq0002_01', 'seq0002_02', 'seq0002_03', ...
    'seq0002_04', 'seq0007_00', 'seq0012_00', 'seq0015_00', ...
    'seq0015_01', 'seq0015_02', 'seq0015_03'};

for s = 1:numel(seq_names)
    seq_name = seq_names{s};
    % prepare the file name for each image
    filenames = textread(fullfile(root_path, seq_name, 'img', 'imlist.txt'), '%s');
    nframes = numel(filenames);
    s_frames = cell(nframes,1);
    for t = 1:nframes
        s_frames{t} = fullfile(root_path, seq_name, 'img', filenames{t});
    end
    N = numel(s_frames);

    % get detection results
    result_path = '../result/DPM_VOC2007';

    figure(1);
    for i = 1:N
        filename = fullfile(result_path, seq_name, [filenames{i}(1:end-3) 'mat']);
        object = load(filename, 'det');
        det = object.det;

        I = imread(s_frames{i});
        imshow(I);
        hold on;

        for k = 1:5
            % get predicted bounding box
            bbox_pr = det(k,1:4);
            bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
            rectangle('Position', bbox_draw, 'EdgeColor', 'g', 'LineWidth',2);
            score = det(k, 5);
            tit = sprintf('%s: %.2f', filenames{i}(1:end-4), score);
            title(tit);
        end

        hold off;
        pause;
    end
end