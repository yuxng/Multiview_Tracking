function initialize_class

root_path = '../dataset/YOUTUBE';
dir_names = {'BMW_1', 'drift_1', 'drift_2', 'FLUFFYJET_1', 'FLUFFYJET_2',...
    'FLUFFYJET_3', 'FLUFFYJET_4', 'FLUFFYJET_5', 'FLUFFYJET_6', 'TOYOTA_1'};
cls = 'car';
N = numel(dir_names);
for i = 1:N
    disp(dir_names{i});
    filename = fullfile(root_path, dir_names{i}, 'gt', '*.mat');
    files = dir(filename);
    for j = 1:numel(files)
        disp(files(j).name);
        file_ann = fullfile(root_path, dir_names{i}, 'gt', files(j).name);
        image = load(file_ann);
        if isfield(image, 'record') == 0
            continue;
        end
        record = image.record;
        for k = 1:numel(record.objects)
            record.objects(k).class = cls;
        end
        save(file_ann, 'record');
    end
end