function cad = cad_train_all(cls)

switch cls
    case 'car'
        names = {'sedan_03', 'sedan_05', 'SUV_02', 'SUV_04', 'SUV_09'};
        path = '../dataset/YOUTUBE/CAD/';
end

N = numel(names);
for i = 1:N
    disp(names{i});
    filename = fullfile(path, names{i});
    cad(i) = cad_train(cls, filename);
end