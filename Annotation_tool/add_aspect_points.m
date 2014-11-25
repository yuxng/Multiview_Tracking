function cad = add_aspect_points(cls, cad)

switch cls
    case 'car'
        names = {'sedan_03', 'sedan_05', 'SUV_02', 'SUV_04', 'SUV_09'};
        path = '../dataset/YOUTUBE/CAD/';
        aspect = {'head', 'left', 'right', 'front', 'back', 'tail'};
end

N = numel(names);
for i = 1:N
    disp(names{i});
    name = names{i};
    cad(i).aspect = aspect;
    for j = 1:numel(aspect)
        filename = fullfile(path, sprintf('%s_%s.off', name, aspect{j}));
        if exist(filename) == 0
            fprintf('file %s not exist\n', filename);
            cad(i).(aspect{j}) = [];
        else
            X = load_off_file(filename);
            if size(X,1) > 1
                X = mean(X);
            end
            cad(i).(aspect{j}) = X;
        end
    end    
end