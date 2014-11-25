function display_result_ALM(seq_name)

% load cad model
cad = load('car.mat');
cad = cad.car;

pnames = cad.pnames;
part_num = numel(pnames);

% prepare the file name for each image
root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/KITTI/multi_car/';
% root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/YOUTUBE/';
% root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset';
filenames = textread(fullfile(root_path, seq_name, 'img', 'imlist.txt'), '%s');
nframes = numel(filenames);
s_frames = cell(nframes,1);
for t = 1:nframes
    s_frames{t} = fullfile(root_path, seq_name, 'img', filenames{t});
end
N = numel(s_frames);

% open prediction file

filename = sprintf('../result/ALM_old/%s.pre', seq_name);
examples = read_samples(filename, cad, N);

figure;
for i = 1:N
    example = examples{i};   
    
    if i ~= 1 && mod(i-1, 4) == 0
        pause;
    end
    ind = mod(i-1,4)+1;
    
    I = imread(s_frames{i});
    subplot(2, 2, ind);
    imshow(I);
    hold on;

    for k = 1:min(5,numel(example))
        % get predicted bounding box
        bbox_pr = example(k).bbox;
        view_label = example(k).view_label;
        part2d = cad.parts2d(view_label);
        til = sprintf('frame %d: a=%.2f, e=%.2f, d=%.2f', i, part2d.azimuth, part2d.elevation, part2d.distance);
        title(til);
        part_label = example(k).part_label;
        for a = 1:part_num
            if isempty(part2d.homographies{a}) == 0 && part_label(a,1) ~= 0 && part_label(a,2) ~= 0
                plot(part_label(a,1), part_label(a,2), 'ro');
                % render parts
                part = part2d.(pnames{a}) + repmat(part_label(a,:), 5, 1);
                patch('Faces', [1 2 3 4 5], 'Vertices', part, 'FaceColor', 'r', 'EdgeColor', 'r', 'FaceAlpha', 0.1);           
            end
        end
        % draw bounding box
        bbox_draw = [bbox_pr(1), bbox_pr(2), bbox_pr(3)-bbox_pr(1), bbox_pr(4)-bbox_pr(2)];
        rectangle('Position', bbox_draw, 'EdgeColor', 'g', 'LineWidth',2);
    end
    
    subplot(2, 2, ind);
    hold off;
end