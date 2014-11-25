function show_annotation(cls)

% path_image = sprintf('../dataset/YOUTUBE/%s/img', cls);
% path_ann = sprintf('../dataset/YOUTUBE/%s/gt', cls);

path_image = sprintf('../dataset/KITTI/multi_car/%s/img', cls);
path_ann = sprintf('../dataset/KITTI/multi_car/%s/gt', cls);

figure;
files = dir(path_image);
N = numel(files);
i = 1;
while i <= N
    if files(i).isdir == 0
        filename = files(i).name;
        [pathstr, name, ext] = fileparts(filename);
        if isempty(imformats(ext(2:end))) == 0
            disp(filename);
            I = imread(fullfile(path_image, filename));
            imshow(I);
            hold on;

            % load annotation
            filename_ann = sprintf('%s/%s.mat', path_ann, name);

            if exist(filename_ann) == 0
                errordlg('No annotation available for the image');
            else
                object = load(filename_ann);
                record = object.record;

                % show the bounding box
                for j = 1:numel(record.objects)
                    if strcmp(record.objects(j).class, 'car') == 1
                        bbox = record.objects(j).bbox;
                        bbox_draw = bbox;
                        rectangle('Position', bbox_draw, 'EdgeColor', 'g');
                        % show anchor points
                        if isfield(record.objects(j), 'anchors') == 1 && isempty(record.objects(j).anchors) == 0
                            names = fieldnames(record.objects(j).anchors);
                            for k = 1:numel(names)
                                if record.objects(j).anchors.(names{k}).status == 1
                                    x = record.objects(j).anchors.(names{k}).location(1);
                                    y = record.objects(j).anchors.(names{k}).location(2);
                                    plot(x, y, 'ro', 'LineWidth', 2);
                                end
                            end
                        end
                        % show aspect parts 
                        if isfield(record.objects(j), 'parts') == 1 && isempty(record.objects(j).parts) == 0
                            pnames = fieldnames(record.objects(j).parts);
                            parts = record.objects(j).parts;
                            for p = 1:numel(pnames)
                                if isempty(parts.(pnames{p}).center) == 0
                                    center = parts.(pnames{p}).center;
                                    part = parts.(pnames{p}).shape;
                                    part = part + repmat(center, size(part,1), 1);
                                    patch(part(:,1), part(:,2), 'r', 'EdgeColor', 'r', 'FaceAlpha', 0.3);
                                    plot(center(1), center(2), 'ro', 'LineWidth', 2);
                                end
                            end
                        end
                    end
                end             
            end
            hold off;
            pause;
        end
    end
    i = i + 1;
end