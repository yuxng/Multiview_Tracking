function add_aspect_part(issave)

% load cad model
object = load('car.mat');
cad = object.car;

% for each annotaion file
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
        % load the annotation
        file_ann = fullfile(root_path, dir_names{i}, 'gt', files(k).name);
        image = load(file_ann);
        if isfield(image, 'record') == 0
            continue;
        end
        if isfield(image.record.objects(1), 'anchors') == 0
            continue;
        end        
        record = image.record;
        
        if issave == 0
            file_img = fullfile(root_path, dir_names{i}, 'img', [files(k).name(1:end-4) ext]);
            I = imread(file_img);
        end        
        
        % number of objects
        n = numel(record.objects);
        for j = 1:n
            object = record.objects(j);
            % check if the object is car or not
            if strcmp(object.class, cls) == 0
                continue;
            end            
            record.objects(j).parts = generate_part_locations(cls, object, cad);
        end
        if issave == 1
            save(file_ann, 'record');
        else
            imshow(I);
            hold on;
            for j = 1:n
                parts = record.objects(j).parts;
                if isempty(parts) == 1
                    continue;
                end
                pnames = cad(record.objects(j).cad_index).aspect;
                a = record.objects(j).viewpoint.azimuth;
                e = record.objects(j).viewpoint.elevation;
                d = record.objects(j).viewpoint.distance;                
                for p = 1:numel(pnames)
                    if isempty(parts.(pnames{p}).center) == 0
                        center = parts.(pnames{p}).center;
                        part = parts.(pnames{p}).shape;
                        part = part + repmat(center, size(part,1), 1);
                        patch(part(:,1), part(:,2), 'r', 'EdgeColor', 'r', 'FaceAlpha', 0.3);
                        plot(center(1), center(2), 'ro', 'LineWidth', 16);

                    end
                end
                til = sprintf('azimuth=%.2f, elevation=%.2f, distance=%.2f', a, e, d);
                title(til);
            end
            pause;
            hold off;
        end
    end
end

% project the CAD model to generate aspect part locations
function parts = generate_part_locations(cls, object, cads)

% index of the CAD model
cad_index = object.cad_index;
cad = cads(cad_index);

% load the 3D points
x3d = [];
pnames = cad.aspect;
for i = 1:numel(pnames)
    X = cad.(pnames{i});
    x3d = [x3d; X];
end

% project the 3D points
viewpoint = object.viewpoint;
a = viewpoint.azimuth*pi/180;
e = viewpoint.elevation*pi/180;
d = viewpoint.distance;
f = viewpoint.focal;
theta = viewpoint.theta*pi/180;
principal = [viewpoint.px viewpoint.py];

if d == 0
    parts = [];
    fprintf('error\n');
    return;
end

% camera center
C = zeros(3,1);
C(1) = d*cos(e)*sin(a);
C(2) = -d*cos(e)*cos(a);
C(3) = d*sin(e);

a = -a;
e = -(pi/2-e);

% rotation matrix
Rz = [cos(a) -sin(a) 0; sin(a) cos(a) 0; 0 0 1];   %rotate by a
Rx = [1 0 0; 0 cos(e) -sin(e); 0 sin(e) cos(e)];   %rotate by e
R = Rx*Rz;

% perspective project matrix
M = 3000;
P = [M*f 0 0; 0 M*f 0; 0 0 -1] * [R -R*C];

% project
x = P*[x3d ones(size(x3d,1), 1)]';
x(1,:) = x(1,:) ./ x(3,:);
x(2,:) = x(2,:) ./ x(3,:);
x = x(1:2,:);

% rotation matrix 2D
R2d = [cos(theta) -sin(theta); sin(theta) cos(theta)];
x = (R2d * x)';

% transform to image coordinates
x(:,2) = -1 * x(:,2);
x = x + repmat(principal, size(x,1), 1);

% construct the part structure
addpath('../CAD');
part2d = generate_2d_parts(cls, viewpoint.azimuth, viewpoint.elevation, viewpoint.distance);
for i = 1:numel(pnames)
    if isempty(part2d.(pnames{i})) == 0
        parts.(pnames{i}).center = x(i,:);
        parts.(pnames{i}).shape = part2d.(pnames{i});
    else
        parts.(pnames{i}).center = [];
        parts.(pnames{i}).shape = [];
    end
end