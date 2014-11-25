% compute the viewpoints for pascal objects
function compute_viewpoint(cls, issave)

% load cad model
kernel = load(sprintf('%s.mat',cls));
cad = kernel.(cls);

% root_path = '../dataset/YOUTUBE';
% dir_names = {'BMW_1', 'drift_1', 'drift_2', 'FLUFFYJET_1', 'FLUFFYJET_2',...
%     'FLUFFYJET_3', 'FLUFFYJET_4', 'FLUFFYJET_5', 'FLUFFYJET_6', 'TOYOTA_1'};
% exts = {'.jpg', '.jpg', '.png', '.png', '.png', '.png', '.png', '.png', '.png', '.jpg'};


root_path = '/home/yuxiang/Projects/Multiview_Tracking/dataset/KITTI/multi_car';
dir_names = {'seq0001_00', 'seq0001_01', 'seq0001_02', 'seq0001_03', ...
    'seq0002_00', 'seq0002_01', 'seq0002_02', 'seq0002_03', ...
    'seq0002_04', 'seq0007_00', 'seq0012_00', 'seq0015_00', ...
    'seq0015_01', 'seq0015_02', 'seq0015_03'};
ext = '.png';

cls = 'car';
N = numel(dir_names);
for i = 1:N
    disp(dir_names{i});
    filename = fullfile(root_path, dir_names{i}, 'gt', '*.mat');
    files = dir(filename);
    for k = 1:numel(files)
        file_ann = fullfile(root_path, dir_names{i}, 'gt', files(k).name);
        image = load(file_ann);
        if isfield(image, 'record') == 0
            continue;
        end
        record = image.record;
        
        % compute viewpoint
        if isfield(record.objects(1), 'anchors') == 0
            continue;
        end
        disp(file_ann);
        [azimuth, elevation, azi_co, ele_co, distance, focal, px, py,...
            theta, error, interval_azimuth, interval_elevation, num_anchor, ob_index]...
            = view_estimator(cls, record, cad);

        if issave == 0
            file_img = fullfile(root_path, dir_names{i}, 'img', [files(k).name(1:end-4) ext]);
            I = imread(file_img);
        end

        for j = 1:length(ob_index)
            record.objects(ob_index(j)).viewpoint.azimuth = azimuth(j);
            record.objects(ob_index(j)).viewpoint.elevation = elevation(j);
            record.objects(ob_index(j)).viewpoint.distance = distance(j);
            record.objects(ob_index(j)).viewpoint.focal = focal(j);
            record.objects(ob_index(j)).viewpoint.px = px(j);
            record.objects(ob_index(j)).viewpoint.py = py(j);
            record.objects(ob_index(j)).viewpoint.theta = theta(j);
            record.objects(ob_index(j)).viewpoint.error = error(j);
            record.objects(ob_index(j)).viewpoint.interval_azimuth = interval_azimuth(j);
            record.objects(ob_index(j)).viewpoint.interval_elevation = interval_elevation(j);
            record.objects(ob_index(j)).viewpoint.num_anchor = num_anchor(j);
            if issave == 1
                save(file_ann, 'record');
            else
                imshow(I);
                hold on;
                til = sprintf('a=%.2f(%.2f), e=%.2f(%.2f), d=%.2f, f=%.2f, theta=%.2f\n', azimuth(j), azi_co(j), elevation(j),...
                    ele_co(j), distance(j), focal(j), theta(j));
                title(til);
                plot(px(j), py(j), 'ro');
                bbox = record.objects(ob_index(j)).bbox;
                bbox_draw = bbox;
                rectangle('Position', bbox_draw, 'EdgeColor', 'g');
                pause;
                hold off;
            end
        end
    end
end