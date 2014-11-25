%% Bounding box method with combinded error definition
% error = weight * bbox method error + original method error 
% default weight = 1
% The file name should be changed into 'anchor_annotator.m' when you wan to use

function varargout = anchor_annotator(varargin)
% ANCHOR_ANNOTATOR M-file for anchor_annotator.fig
%      ANCHOR_ANNOTATOR, by itself, creates a new ANCHOR_ANNOTATOR or raises the existing
%      singleton*.
%
%      H = ANCHOR_ANNOTATOR returns the handle to a new ANCHOR_ANNOTATOR or the handle to
%      the existing singleton*.
%
%      ANCHOR_ANNOTATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANCHOR_ANNOTATOR.M with the given input arguments.
%
%      ANCHOR_ANNOTATOR('Property','Value',...) creates a new ANCHOR_ANNOTATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before anchor_annotator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to anchor_annotator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help anchor_annotator

% Last Modified by GUIDE v2.5 10-Jun-2013 11:56:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @anchor_annotator_OpeningFcn, ...
                   'gui_OutputFcn',  @anchor_annotator_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before anchor_annotator is made visible.
function anchor_annotator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to anchor_annotator (see VARARGIN)

% Choose default command line output for anchor_annotator
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes anchor_annotator wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = anchor_annotator_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_cad.
function pushbutton_cad_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load cad model
[FileName, PathName] = uigetfile('*.mat');
if isequal(FileName,0)
   return;
end
cad = load(fullfile(PathName, FileName));
cls = FileName(1:end-4);
cad = cad.(cls);
handles.cls = cls;
handles.cad = cad;
handles.cad_index = 1;
handles.part_num = numel(cad(handles.cad_index).pnames);

% display cad model
set(handles.figure1, 'CurrentAxes', handles.axes_cad);
cla;
trimesh(cad(handles.cad_index).faces, cad(handles.cad_index).vertices(:,1), cad(handles.cad_index).vertices(:,2), cad(handles.cad_index).vertices(:,3), 'EdgeColor', 'b');
axis equal;
hold on;

% display anchor points
for i = 1:numel(cad(handles.cad_index).pnames)
    X = cad(handles.cad_index).(cad(handles.cad_index).pnames{i});
    if isempty(X) == 0
        plot3(X(1), X(2), X(3), 'ro', 'LineWidth', 20);
    end
end
hold off;

handles.azimuth = 0;
handles.elevation = 0;
view(0, 0);
set(handles.edit_azimuth, 'String', '0');
set(handles.edit_elevation, 'String', '0');

guidata(hObject, handles);
set(handles.pushbutton_opendir, 'Enable', 'On');


% --- Executes on button press in pushbutton_opendir.
function pushbutton_opendir_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_opendir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

directory_name = uigetdir;
set(handles.text_src, 'String', directory_name);
if isequal(directory_name,0)
   return;
end
files = dir(directory_name);
N = numel(files);
i = 1;
flag = 0;
while i <= N && flag == 0
    if files(i).isdir == 0
        filename = files(i).name;
        [pathstr, name, ext] = fileparts(filename);
        if isempty(imformats(ext(2:end))) == 0
            I = imread(fullfile(directory_name, filename));
            set(handles.figure1, 'CurrentAxes', handles.axes_image);
            imshow(I);
            set(handles.text_filename, 'String', [filename '(' num2str(size(I,1)) ', ' num2str(size(I,2)) ')']);
            set(handles.pushbutton_dest, 'Enable', 'On');
            flag = 1;
        end
    end
    i = i + 1;
end
if flag == 0
    errordlg('No image file in the fold');
else    
    handles.image = I;
    handles.name = name;    
    handles.source_dir = directory_name;
    handles.files = files;
    handles.filepos = i;
    for i = 1:handles.part_num
        handles.(handles.cad(handles.cad_index).pnames{i}).location = [];
        handles.(handles.cad(handles.cad_index).pnames{i}).status = 0;
    end
    handles.partpos = 1;
    handles.partname = handles.cad(handles.cad_index).pnames{1};
    guidata(hObject, handles);
end


% --- Executes on button press in pushbutton_dest.
function pushbutton_dest_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_dest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

directory_name = uigetdir;
set(handles.text_dest, 'String', directory_name);

% load annotation
filename = sprintf('%s/%s.mat', directory_name, handles.name);

if exist(filename) == 0
    errordlg('No annotation available for the image');
else
    object = load(filename);
    record = object.record;
    handles.record = record;

    % show the annotations
    for i = 1:numel(record.objects)
        if strcmp(record.objects(i).class, handles.cls) == 1
            bbox = record.objects(i).bbox;
            bbox_draw = bbox;
            set(handles.figure1, 'CurrentAxes', handles.axes_image);
            cla;
            imshow(handles.image);
            hold on;
            rectangle('Position', bbox_draw, 'EdgeColor', 'g');
            handles.object_index = i;
            % show annotated anchor points
            if isfield(record.objects(i), 'anchors') == 1 && isempty(record.objects(i).anchors) == 0
                names = fieldnames(record.objects(i).anchors);
                for j = 1:numel(names)
                    if record.objects(i).anchors.(names{j}).status == 1
                        if isempty(record.objects(i).anchors.(names{j}).location) == 0
                            x = record.objects(i).anchors.(names{j}).location(1);
                            y = record.objects(i).anchors.(names{j}).location(2);
                            plot(x, y, 'ro', 'LineWidth', 10);
                        else
                            fprintf('anchor point %s is missing!\n', names{j});
                            set(handles.text_save, 'String', 'Re-annotate!');
                        end
                    end
                end                
            end
            hold off;            
            % show the cad model
            if isfield(record.objects(i), 'cad_index') == 1 && isempty(record.objects(i).cad_index) == 0
                handles.cad_index = record.objects(i).cad_index;
                set(handles.figure1, 'CurrentAxes', handles.axes_cad);
                cla;
                cad = handles.cad;
                trimesh(cad(handles.cad_index).faces, cad(handles.cad_index).vertices(:,1), cad(handles.cad_index).vertices(:,2), cad(handles.cad_index).vertices(:,3), 'EdgeColor', 'b');
                axis equal;
                hold on;
                
                handles.azimuth = record.objects(i).viewpoint.azimuth_coarse;
                handles.elevation = record.objects(i).viewpoint.elevation_coarse;
                view(handles.azimuth, handles.elevation);
                set(handles.edit_azimuth, 'String', num2str(handles.azimuth));
                set(handles.edit_elevation, 'String', num2str(handles.elevation));
                
                % check goodness
                ismiss = check_annotation(handles);
                if sum(ismiss) ~= 0
                    set(handles.text_save, 'String', 'Re-annotate!');
                end
                
                % display anchor points
                for j = 1:numel(cad(handles.cad_index).pnames)
                    X = cad(handles.cad_index).(cad(handles.cad_index).pnames{j});
                    if isempty(X) == 0 && ismiss(j) == 1
                        plot3(X(1), X(2), X(3), 'ro', 'LineWidth', 20);
                    end
                end
                hold off;                
            end
            break;
        end
    end     

    handles.dest_dir = directory_name;
    guidata(hObject, handles);
    
    set(handles.pushbutton_next, 'Enable', 'On');
    set(handles.pushbutton_prev, 'Enable', 'On');
    set(handles.pushbutton_next_ten, 'Enable', 'On');
    set(handles.pushbutton_nextcad, 'Enable', 'On');
    set(handles.pushbutton_prevcad, 'Enable', 'On');
    set(handles.pushbutton_left, 'Enable', 'On');
    set(handles.pushbutton_right, 'Enable', 'On');
    set(handles.pushbutton_up, 'Enable', 'On');
    set(handles.pushbutton_down, 'Enable', 'On');
    set(handles.pushbutton_ok, 'Enable', 'On');
end


% --- Executes on button press in pushbutton_next.
function pushbutton_next_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;
% check for next object first
is_next_object = 0;
record = handles.record;
for i = handles.object_index+1:numel(record.objects)
    if strcmp(record.objects(i).class, handles.cls) == 1
        is_next_object = 1;
        bbox = record.objects(i).bbox;
        bbox_draw = bbox;
        set(handles.figure1, 'CurrentAxes', handles.axes_image);
        cla;
        imshow(handles.image);
        hold on;
        rectangle('Position', bbox_draw, 'EdgeColor', 'g');
        % show annotated anchor points
        if isfield(record.objects(i), 'anchors') == 1 && isempty(record.objects(i).anchors) == 0
            names = fieldnames(record.objects(i).anchors);
            for j = 1:numel(names)
                if record.objects(i).anchors.(names{j}).status == 1
                    if isempty(record.objects(i).anchors.(names{j}).location) == 0
                        x = record.objects(i).anchors.(names{j}).location(1);
                        y = record.objects(i).anchors.(names{j}).location(2);
                        plot(x, y, 'ro', 'LineWidth', 10);
                    else
                        fprintf('anchor point %s is missing!\n', names{j});
                        set(handles.text_save, 'String', 'Re-annotate!');
                    end
                end
            end                
        end        
        hold off;
        handles.object_index = i;
        break;
    end
end

if is_next_object == 0
    directory_name = handles.source_dir;
    files = handles.files;
    i = handles.filepos;
    N = numel(files);
    flag = 0;

    while i <= N && flag == 0
        if files(i).isdir == 0
            filename = files(i).name;
            [pathstr, name, ext] = fileparts(filename);
            if isempty(imformats(ext(2:end))) == 0
                I = imread(fullfile(directory_name, filename));
                
                % load annotation
                filename_ann = sprintf('%s/%s.mat', handles.dest_dir, name);
                if exist(filename_ann) == 0
                    errordlg('No annotation available for the image');
                    return;
                else
                    object = load(filename_ann);
                    record = object.record;
                    handles.record = record;

                    % show the bounding box
                    for j = 1:numel(record.objects)
                        if strcmp(record.objects(j).class, handles.cls) == 1
                            bbox = record.objects(j).bbox;
                            bbox_draw = bbox;
                            set(handles.figure1, 'CurrentAxes', handles.axes_image);
                            cla;
                            imshow(I);
                            hold on;
                            rectangle('Position', bbox_draw, 'EdgeColor', 'g');
                            % show annotated anchor points
                            if isfield(record.objects(j), 'anchors') == 1 && isempty(record.objects(j).anchors) == 0
                                names = fieldnames(record.objects(j).anchors);
                                for k = 1:numel(names)
                                    if record.objects(j).anchors.(names{k}).status == 1
                                        if isempty(record.objects(j).anchors.(names{k}).location) == 0
                                            x = record.objects(j).anchors.(names{k}).location(1);
                                            y = record.objects(j).anchors.(names{k}).location(2);
                                            plot(x, y, 'ro', 'LineWidth', 10);
                                        else
                                            fprintf('anchor point %s is missing!\n', names{k});
                                            set(handles.text_save, 'String', 'Re-annotate!');
                                        end
                                    end
                                end                
                            end                            
                            hold off;
                            handles.object_index = j;
                            break;
                        end
                    end
                end
                
                set(handles.text_filename, 'String',  [filename '(' num2str(size(I,1)) ', ' num2str(size(I,2)) ')']);
                flag = 1;
            end
        end
        i = i + 1;
    end

    if flag == 0
        errordlg('No image file left');
        return;
    else
        handles.image = I;
        handles.name = name;    
        handles.filepos = i;
    end
end

if isfield(handles.record.objects(handles.object_index), 'cad_index') == 1 &&...
        isempty(handles.record.objects(handles.object_index).cad_index) == 0
    handles.cad_index = handles.record.objects(handles.object_index).cad_index;
end
for i = 1:handles.part_num
    handles.(handles.cad(handles.cad_index).pnames{i}).location = [];
    handles.(handles.cad(handles.cad_index).pnames{i}).status = 0;
end
handles.partpos = 1;
handles.partname = handles.cad(handles.cad_index).pnames{1};    

% display cad model
set(handles.figure1, 'CurrentAxes', handles.axes_cad);
cla;
cad = handles.cad;
trimesh(cad(handles.cad_index).faces, cad(handles.cad_index).vertices(:,1), cad(handles.cad_index).vertices(:,2), cad(handles.cad_index).vertices(:,3), 'EdgeColor', 'b');
axis equal;
hold on;

set(handles.text_save, 'String', ''); 
if isfield(handles.record.objects(handles.object_index), 'viewpoint') == 1 &&...
        isempty(handles.record.objects(handles.object_index).viewpoint) == 0
    handles.azimuth = handles.record.objects(handles.object_index).viewpoint.azimuth_coarse;
    handles.elevation = handles.record.objects(handles.object_index).viewpoint.elevation_coarse;
    % check goodness
    ismiss = check_annotation(handles);
    if sum(ismiss) ~= 0
        set(handles.text_save, 'String', 'Re-annotate!');
    end

    % display anchor points
    for j = 1:numel(cad(handles.cad_index).pnames)
        X = cad(handles.cad_index).(cad(handles.cad_index).pnames{j});
        if isempty(X) == 0 && ismiss(j) == 1
            plot3(X(1), X(2), X(3), 'ro', 'LineWidth', 20);
        end
    end
    hold off;    
else
    % display anchor points
    for j = 1:numel(cad(handles.cad_index).pnames)
        X = cad(handles.cad_index).(cad(handles.cad_index).pnames{j});
        if isempty(X) == 0
            plot3(X(1), X(2), X(3), 'ro', 'LineWidth', 20);
        end
    end
    hold off;    
end
view(handles.azimuth, handles.elevation);
set(handles.edit_azimuth, 'String', num2str(handles.azimuth));
set(handles.edit_elevation, 'String', num2str(handles.elevation));
guidata(hObject, handles);

set(handles.text_pname, 'String', '');
set(handles.radiobutton_visible, 'Value', 1.0);
set(handles.radiobutton_visible, 'Enable', 'Off');
set(handles.radiobutton_occld, 'Enable', 'Off');    
set(handles.radiobutton_occld_by, 'Enable', 'Off');
set(handles.radiobutton_trunc, 'Enable', 'Off');
set(handles.radiobutton_unknown, 'Enable', 'Off');
set(handles.pushbutton_part, 'Enable', 'Off');
set(handles.pushbutton_next_anchor, 'Enable', 'Off');
set(handles.pushbutton_prev_anchor, 'Enable', 'Off');
set(handles.pushbutton_save, 'Enable', 'Off');
set(handles.pushbutton_view, 'Enable', 'Off');
set(handles.edit1, 'String', '0');
set(handles.edit2, 'String', '0');


% --- Executes on button press in pushbutton_prev.
function pushbutton_prev_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clc;
% check for previous object first
is_prev_object = 0;
record = handles.record;
for i = handles.object_index-1:-1:1
    if strcmp(record.objects(i).class, handles.cls) == 1
        is_prev_object = 1;
        bbox = record.objects(i).bbox;
        bbox_draw = bbox;
        set(handles.figure1, 'CurrentAxes', handles.axes_image);
        cla;
        imshow(handles.image);
        hold on;
        rectangle('Position', bbox_draw, 'EdgeColor', 'g');
        % show annotated anchor points
        if isfield(record.objects(i), 'anchors') == 1 && isempty(record.objects(i).anchors) == 0
            names = fieldnames(record.objects(i).anchors);
            for j = 1:numel(names)
                if record.objects(i).anchors.(names{j}).status == 1
                    if isempty(record.objects(i).anchors.(names{j}).location) == 0
                        x = record.objects(i).anchors.(names{j}).location(1);
                        y = record.objects(i).anchors.(names{j}).location(2);
                        plot(x, y, 'ro', 'LineWidth', 10);
                    else
                        fprintf('anchor point %s is missing!\n', names{j});
                        set(handles.text_save, 'String', 'Re-annotate!');
                    end
                end
            end                
        end        
        hold off;
        handles.object_index = i;
        break;
    end
end

if is_prev_object == 0
    directory_name = handles.source_dir;
    files = handles.files;
    i = handles.filepos - 2;
    flag = 0;

    while i >= 1 && flag == 0
        if files(i).isdir == 0
            filename = files(i).name;
            [pathstr, name, ext] = fileparts(filename);
            if isempty(imformats(ext(2:end))) == 0
                I = imread(fullfile(directory_name, filename));
                
                % load annotation
                filename_ann = sprintf('%s/%s.mat', handles.dest_dir, name);
                if exist(filename_ann) == 0
                    errordlg('No annotation available for the image');
                    return;
                else
                    object = load(filename_ann);
                    record = object.record;
                    handles.record = record;

                    % show the bounding box
                    for j = 1:numel(record.objects)
                        if strcmp(record.objects(j).class, handles.cls) == 1
                            bbox = record.objects(j).bbox;
                            bbox_draw = bbox;
                            set(handles.figure1, 'CurrentAxes', handles.axes_image);
                            cla;
                            imshow(I);
                            hold on;
                            rectangle('Position', bbox_draw, 'EdgeColor', 'g');
                            % show annotated anchor points
                            if isfield(record.objects(j), 'anchors') == 1 && isempty(record.objects(j).anchors) == 0
                                names = fieldnames(record.objects(j).anchors);
                                for k = 1:numel(names)
                                    if record.objects(j).anchors.(names{k}).status == 1
                                        if isempty(record.objects(j).anchors.(names{k}).location) == 0
                                            x = record.objects(j).anchors.(names{k}).location(1);
                                            y = record.objects(j).anchors.(names{k}).location(2);
                                            plot(x, y, 'ro', 'LineWidth', 10);
                                        else
                                            fprintf('anchor point %s is missing!\n', names{k});
                                            set(handles.text_save, 'String', 'Re-annotate!');
                                        end
                                    end
                                end                
                            end                            
                            hold off;
                            handles.object_index = j;
                            break;
                        end
                    end
                end
                
                set(handles.text_filename, 'String',  [filename '(' num2str(size(I,1)) ', ' num2str(size(I,2)) ')']);
                flag = 1;
            end
        end
        i = i - 1;
    end

    if flag == 0
        errordlg('No previous image');
        return;
    else
        handles.image = I;
        handles.name = name;    
        handles.filepos = i + 2;
    end
end

if isfield(handles.record.objects(handles.object_index), 'cad_index') == 1 &&...
        isempty(handles.record.objects(handles.object_index).cad_index) == 0
    handles.cad_index = handles.record.objects(handles.object_index).cad_index;
end
for i = 1:handles.part_num
    handles.(handles.cad(handles.cad_index).pnames{i}).location = [];
    handles.(handles.cad(handles.cad_index).pnames{i}).status = 0;
end
handles.partpos = 1;
handles.partname = handles.cad(handles.cad_index).pnames{1};    

% display cad model
set(handles.figure1, 'CurrentAxes', handles.axes_cad);
cla;
cad = handles.cad;
trimesh(cad(handles.cad_index).faces, cad(handles.cad_index).vertices(:,1), cad(handles.cad_index).vertices(:,2), cad(handles.cad_index).vertices(:,3), 'EdgeColor', 'b');
axis equal;
hold on;

set(handles.text_save, 'String', ''); 
if isfield(handles.record.objects(handles.object_index), 'viewpoint') == 1 &&...
        isempty(handles.record.objects(handles.object_index).viewpoint) == 0
    handles.azimuth = handles.record.objects(handles.object_index).viewpoint.azimuth_coarse;
    handles.elevation = handles.record.objects(handles.object_index).viewpoint.elevation_coarse;
    % check goodness
    ismiss = check_annotation(handles);
    if sum(ismiss) ~= 0
        set(handles.text_save, 'String', 'Re-annotate!');
    end

    % display anchor points
    for j = 1:numel(cad(handles.cad_index).pnames)
        X = cad(handles.cad_index).(cad(handles.cad_index).pnames{j});
        if isempty(X) == 0 && ismiss(j) == 1
            plot3(X(1), X(2), X(3), 'ro', 'LineWidth', 20);
        end
    end
    hold off;    
else
    % display anchor points
    for j = 1:numel(cad(handles.cad_index).pnames)
        X = cad(handles.cad_index).(cad(handles.cad_index).pnames{j});
        if isempty(X) == 0
            plot3(X(1), X(2), X(3), 'ro', 'LineWidth', 20);
        end
    end
    hold off;    
end
view(handles.azimuth, handles.elevation);
set(handles.edit_azimuth, 'String', num2str(handles.azimuth));
set(handles.edit_elevation, 'String', num2str(handles.elevation));
guidata(hObject, handles);

set(handles.text_pname, 'String', '');
set(handles.radiobutton_visible, 'Value', 1.0);
set(handles.radiobutton_visible, 'Enable', 'Off');
set(handles.radiobutton_occld, 'Enable', 'Off');
set(handles.radiobutton_occld_by, 'Enable', 'Off');
set(handles.radiobutton_trunc, 'Enable', 'Off');
set(handles.radiobutton_unknown, 'Enable', 'Off');
set(handles.pushbutton_part, 'Enable', 'Off');
set(handles.pushbutton_next_anchor, 'Enable', 'Off');
set(handles.pushbutton_prev_anchor, 'Enable', 'Off');
set(handles.pushbutton_save, 'Enable', 'Off');
set(handles.pushbutton_view, 'Enable', 'Off');
set(handles.edit1, 'String', '0');
set(handles.edit2, 'String', '0');


% --- Executes on button press in pushbutton_next_ten.
function pushbutton_next_ten_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_next_ten (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clc;
directory_name = handles.source_dir;
files = handles.files;
i = handles.filepos + 4;
N = numel(files);
flag = 0;

while i <= N && flag == 0
    if files(i).isdir == 0
        filename = files(i).name;
        [pathstr, name, ext] = fileparts(filename);
        if isempty(imformats(ext(2:end))) == 0
            I = imread(fullfile(directory_name, filename));

            % load annotation
            filename_ann = sprintf('%s/%s.mat', handles.dest_dir, name);
            if exist(filename_ann) == 0
                errordlg('No annotation available for the image');
                return;
            else
                object = load(filename_ann);
                record = object.record;
                handles.record = record;

                % show the bounding box
                for j = 1:numel(record.objects)
                    if strcmp(record.objects(j).class, handles.cls) == 1
                        bbox = record.objects(j).bbox;
                        bbox_draw = bbox;
                        set(handles.figure1, 'CurrentAxes', handles.axes_image);
                        cla;
                        imshow(I);
                        hold on;
                        rectangle('Position', bbox_draw, 'EdgeColor', 'g');
                        % show annotated anchor points
                        if isfield(record.objects(j), 'anchors') == 1 && isempty(record.objects(j).anchors) == 0
                            names = fieldnames(record.objects(j).anchors);
                            for k = 1:numel(names)
                                if record.objects(j).anchors.(names{k}).status == 1
                                    if isempty(record.objects(j).anchors.(names{k}).location) == 0
                                        x = record.objects(j).anchors.(names{k}).location(1);
                                        y = record.objects(j).anchors.(names{k}).location(2);
                                        plot(x, y, 'ro', 'LineWidth', 10);
                                    else
                                        fprintf('anchor point %s is missing!\n', names{k});
                                        set(handles.text_save, 'String', 'Re-annotate!');
                                    end
                                end
                            end                
                        end                        
                        hold off;
                        handles.object_index = j;
                        break;
                    end
                end
            end

            set(handles.text_filename, 'String',  [filename '(' num2str(size(I,1)) ', ' num2str(size(I,2)) ')']);
            flag = 1;
        end
    end
    i = i + 1;
end

if flag == 0
    errordlg('No image file left');
    return;
else
    handles.image = I;
    handles.name = name;    
    handles.filepos = i;
end

if isfield(handles.record.objects(handles.object_index), 'cad_index') == 1 &&...
        isempty(handles.record.objects(handles.object_index).cad_index) == 0
    handles.cad_index = handles.record.objects(handles.object_index).cad_index;
end
for i = 1:handles.part_num
    handles.(handles.cad(handles.cad_index).pnames{i}).location = [];
    handles.(handles.cad(handles.cad_index).pnames{i}).status = 0;
end
handles.partpos = 1;
handles.partname = handles.cad(handles.cad_index).pnames{1};

% display cad model
set(handles.figure1, 'CurrentAxes', handles.axes_cad);
cla;
cad = handles.cad;
trimesh(cad(handles.cad_index).faces, cad(handles.cad_index).vertices(:,1), cad(handles.cad_index).vertices(:,2), cad(handles.cad_index).vertices(:,3), 'EdgeColor', 'b');
axis equal;
hold on;

set(handles.text_save, 'String', '');
if isfield(handles.record.objects(handles.object_index), 'viewpoint') == 1 && ...
        isempty(handles.record.objects(handles.object_index).viewpoint) == 0
    handles.azimuth = handles.record.objects(handles.object_index).viewpoint.azimuth_coarse;
    handles.elevation = handles.record.objects(handles.object_index).viewpoint.elevation_coarse;
    % check goodness
    ismiss = check_annotation(handles);
    if sum(ismiss) ~= 0
        set(handles.text_save, 'String', 'Re-annotate!');
    end

    % display anchor points
    for j = 1:numel(cad(handles.cad_index).pnames)
        X = cad(handles.cad_index).(cad(handles.cad_index).pnames{j});
        if isempty(X) == 0 && ismiss(j) == 1
            plot3(X(1), X(2), X(3), 'ro', 'LineWidth', 20);
        end
    end
    hold off;    
else
    % display anchor points
    for j = 1:numel(cad(handles.cad_index).pnames)
        X = cad(handles.cad_index).(cad(handles.cad_index).pnames{j});
        if isempty(X) == 0
            plot3(X(1), X(2), X(3), 'ro', 'LineWidth', 20);
        end
    end
    hold off;     
end
view(handles.azimuth, handles.elevation);
set(handles.edit_azimuth, 'String', num2str(handles.azimuth));
set(handles.edit_elevation, 'String', num2str(handles.elevation));
guidata(hObject, handles);

set(handles.text_pname, 'String', '');
set(handles.radiobutton_visible, 'Value', 1.0);
set(handles.radiobutton_visible, 'Enable', 'Off');
set(handles.radiobutton_occld, 'Enable', 'Off');
set(handles.radiobutton_occld_by, 'Enable', 'Off');
set(handles.radiobutton_trunc, 'Enable', 'Off');
set(handles.radiobutton_unknown, 'Enable', 'Off');
set(handles.pushbutton_part, 'Enable', 'Off');
set(handles.pushbutton_next_anchor, 'Enable', 'Off');
set(handles.pushbutton_prev_anchor, 'Enable', 'Off');
set(handles.pushbutton_save, 'Enable', 'Off');
set(handles.pushbutton_view, 'Enable', 'Off');
set(handles.edit1, 'String', '0');
set(handles.edit2, 'String', '0');



% --- Executes on button press in pushbutton_part.
function pushbutton_part_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_part (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% re-show the image
bbox = handles.record.objects(handles.object_index).bbox;
bbox_draw = bbox;
set(handles.axes_image, 'NextPlot', 'replacechildren');
set(handles.figure1, 'CurrentAxes', handles.axes_image);
cla;
imshow(handles.image);
hold on;
rectangle('Position', bbox_draw, 'EdgeColor', 'g');
hold off;

set(handles.figure1, 'CurrentAxes', handles.axes_image);
[x, y] = ginput(1);
hold on;
plot(x, y, 'ro', 'LineWidth', 10);
hold off;
set(handles.edit1, 'String', num2str(x));
set(handles.edit2, 'String', num2str(y));
handles.(handles.partname).location = [x y];
handles.(handles.partname).status = 1; % 1 visible
guidata(hObject, handles);
if handles.partpos ~= numel(handles.anchor_index)
    set(handles.pushbutton_next_anchor, 'Enable', 'On');
else
    set(handles.pushbutton_save, 'Enable', 'On');
end
set(handles.radiobutton_visible, 'Value', 1.0);


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_next_anchor.
function pushbutton_next_anchor_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_next_anchor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.partpos = handles.partpos + 1;
index = handles.anchor_index(handles.partpos);
handles.partname = handles.cad(handles.cad_index).pnames{index};
set(handles.text_pname, 'String', handles.partname);
guidata(hObject, handles);

% re-show the image
bbox = handles.record.objects(handles.object_index).bbox;
bbox_draw = bbox;
set(handles.axes_image, 'NextPlot', 'replacechildren');
set(handles.figure1, 'CurrentAxes', handles.axes_image);
cla;
imshow(handles.image);
hold on;
rectangle('Position', bbox_draw, 'EdgeColor', 'g');
hold off;

% display cad model
set(handles.figure1, 'CurrentAxes', handles.axes_cad);
cla;
cad = handles.cad;
trimesh(cad(handles.cad_index).faces, cad(handles.cad_index).vertices(:,1), cad(handles.cad_index).vertices(:,2), cad(handles.cad_index).vertices(:,3), 'EdgeColor', 'b');
axis equal;
hold on;

% display anchor points
X = cad(handles.cad_index).(handles.partname);
plot3(X(1), X(2), X(3), 'ro', 'LineWidth', 20);
view(handles.azimuth, handles.elevation);
hold off;

set(handles.pushbutton_next_anchor, 'Enable', 'Off');
set(handles.radiobutton_visible, 'Value', 1.0);
if handles.partpos == 2
    set(handles.pushbutton_prev_anchor, 'Enable', 'On');
end
set(handles.edit1, 'String', '0');
set(handles.edit2, 'String', '0');

%%%%%%%%%%%%%%% start anchor status %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in radiobutton_visible.
function radiobutton_visible_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_visible (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_visible
handles.(handles.partname).status = 1; % 1 visible
guidata(hObject, handles);


% --- Executes on button press in radiobutton_occld.
function radiobutton_occld_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_occld (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_occld

% re-show the image
bbox = handles.record.objects(handles.object_index).bbox;
bbox_draw = bbox;
set(handles.axes_image, 'NextPlot', 'replacechildren');
set(handles.figure1, 'CurrentAxes', handles.axes_image);
cla;
imshow(handles.image);
hold on;
rectangle('Position', bbox_draw, 'EdgeColor', 'g');
hold off;

handles.(handles.partname).status = 2; % 2 self-occluded
guidata(hObject, handles);
if handles.partpos ~= numel(handles.anchor_index)
    set(handles.pushbutton_next_anchor, 'Enable', 'On');
else
    set(handles.pushbutton_save, 'Enable', 'On');
end
set(handles.edit1, 'String', '0');
set(handles.edit2, 'String', '0');


% --- Executes on button press in radiobutton_occld_by.
function radiobutton_occld_by_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_occld_by (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_occld_by

% re-show the image
bbox = handles.record.objects(handles.object_index).bbox;
bbox_draw = bbox;
set(handles.axes_image, 'NextPlot', 'replacechildren');
set(handles.figure1, 'CurrentAxes', handles.axes_image);
cla;
imshow(handles.image);
hold on;
rectangle('Position', bbox_draw, 'EdgeColor', 'g');
hold off;

handles.(handles.partname).status = 3; % 3 occluded by other objects
guidata(hObject, handles);
if handles.partpos ~= numel(handles.anchor_index)
    set(handles.pushbutton_next_anchor, 'Enable', 'On');
else
    set(handles.pushbutton_save, 'Enable', 'On');
end
set(handles.edit1, 'String', '0');
set(handles.edit2, 'String', '0');


% --- Executes on button press in radiobutton_trunc.
function radiobutton_trunc_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_trunc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_trunc
% re-show the image
bbox = handles.record.objects(handles.object_index).bbox;
bbox_draw = bbox;
set(handles.axes_image, 'NextPlot', 'replacechildren');
set(handles.figure1, 'CurrentAxes', handles.axes_image);
cla;
imshow(handles.image);
hold on;
rectangle('Position', bbox_draw, 'EdgeColor', 'g');
hold off;

handles.(handles.partname).status = 4; % 4 truncated
guidata(hObject, handles);
if handles.partpos ~= numel(handles.anchor_index)
    set(handles.pushbutton_next_anchor, 'Enable', 'On');
else
    set(handles.pushbutton_save, 'Enable', 'On');
end
set(handles.edit1, 'String', '0');
set(handles.edit2, 'String', '0');

% --- Executes on button press in radiobutton_unknown.
function radiobutton_unknown_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_unknown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_unknown
% re-show the image
bbox = handles.record.objects(handles.object_index).bbox;
bbox_draw = bbox;
set(handles.axes_image, 'NextPlot', 'replacechildren');
set(handles.figure1, 'CurrentAxes', handles.axes_image);
cla;
imshow(handles.image);
hold on;
rectangle('Position', bbox_draw, 'EdgeColor', 'g');
hold off;

handles.(handles.partname).status = 5; % 5 unknown
guidata(hObject, handles);
if handles.partpos ~= numel(handles.anchor_index)
    set(handles.pushbutton_next_anchor, 'Enable', 'On');
else
    set(handles.pushbutton_save, 'Enable', 'On');
end
set(handles.edit1, 'String', '0');
set(handles.edit2, 'String', '0');

%%%%%%%%%%%%%%% end anchor status %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

matfile = sprintf('%s/%s.mat', handles.dest_dir, handles.name);

record = handles.record;
for i = 1:handles.part_num
    record.objects(handles.object_index).anchors.(handles.cad(handles.cad_index).pnames{i}) = handles.(handles.cad(handles.cad_index).pnames{i});
end
record.objects(handles.object_index).viewpoint.azimuth_coarse = handles.azimuth;
record.objects(handles.object_index).viewpoint.elevation_coarse = handles.elevation;
record.objects(handles.object_index).cad_index = handles.cad_index;

save(matfile, 'record');
set(handles.text_save, 'String', 'Annotation saved');

handles.record = record;
guidata(hObject, handles);


% --- Executes on button press in pushbutton_prev_anchor.
function pushbutton_prev_anchor_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_prev_anchor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.partpos = handles.partpos - 1;
index = handles.anchor_index(handles.partpos);
handles.partname = handles.cad(handles.cad_index).pnames{index};
set(handles.text_pname, 'String', handles.partname);
guidata(hObject, handles);

% re-show the image
bbox = handles.record.objects(handles.object_index).bbox;
bbox_draw = bbox;
set(handles.axes_image, 'NextPlot', 'replacechildren');
set(handles.figure1, 'CurrentAxes', handles.axes_image);
cla;
imshow(handles.image);
hold on;
rectangle('Position', bbox_draw, 'EdgeColor', 'g');

% show the annotation
switch handles.(handles.partname).status
    case 1
        x = handles.(handles.partname).location(1);
        y = handles.(handles.partname).location(2);
        plot(x, y, 'ro', 'LineWidth', 10);
        set(handles.radiobutton_visible, 'Value', 1.0);
        set(handles.edit1, 'String', num2str(x));
        set(handles.edit2, 'String', num2str(y));        
    case 2
        set(handles.radiobutton_occld, 'Value', 1.0);
        set(handles.edit1, 'String', '0');
        set(handles.edit2, 'String', '0');
    case 3
        set(handles.radiobutton_occld_by, 'Value', 1.0);
        set(handles.edit1, 'String', '0');
        set(handles.edit2, 'String', '0');        
    case 4
        set(handles.radiobutton_trunc, 'Value', 1.0);
        set(handles.edit1, 'String', '0');
        set(handles.edit2, 'String', '0');
    case 5
        set(handles.radiobutton_unknown, 'Value', 1.0);
        set(handles.edit1, 'String', '0');
        set(handles.edit2, 'String', '0');
end
        
hold off;

% display cad model
set(handles.figure1, 'CurrentAxes', handles.axes_cad);
cla;
cad = handles.cad;
trimesh(cad(handles.cad_index).faces, cad(handles.cad_index).vertices(:,1), cad(handles.cad_index).vertices(:,2), cad(handles.cad_index).vertices(:,3), 'EdgeColor', 'b');
axis equal;
hold on;

% display anchor points
X = cad(handles.cad_index).(handles.partname);
plot3(X(1), X(2), X(3), 'ro', 'LineWidth', 20);
view(handles.azimuth, handles.elevation);
hold off;

if handles.partpos == 1
    set(handles.pushbutton_prev_anchor, 'Enable', 'Off');
end
set(handles.pushbutton_next_anchor, 'Enable', 'On');
set(handles.pushbutton_save, 'Enable', 'Off');
set(handles.text_save, 'String', '');


% --- Executes on button press in pushbutton_left.
function pushbutton_left_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% display cad model
cad = handles.cad;
set(handles.figure1, 'CurrentAxes', handles.axes_cad);
cla;
trimesh(cad(handles.cad_index).faces, cad(handles.cad_index).vertices(:,1), cad(handles.cad_index).vertices(:,2), cad(handles.cad_index).vertices(:,3), 'EdgeColor', 'b');
axis equal;
hold on;

% display anchor points
for i = 1:numel(cad(handles.cad_index).pnames)
    X = cad(handles.cad_index).(cad(handles.cad_index).pnames{i});
    if isempty(X) == 0
        plot3(X(1), X(2), X(3), 'ro', 'LineWidth', 20);
    end
end
hold off;

handles.azimuth = handles.azimuth + 5;
if handles.azimuth >= 360
    handles.azimuth = handles.azimuth - 360;
end
view(handles.azimuth, handles.elevation);
guidata(hObject, handles);

set(handles.edit_azimuth, 'String', num2str(handles.azimuth));
set(handles.edit_elevation, 'String', num2str(handles.elevation));


% --- Executes on button press in pushbutton_right.
function pushbutton_right_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% display cad model
cad = handles.cad;
set(handles.figure1, 'CurrentAxes', handles.axes_cad);
cla;
trimesh(cad(handles.cad_index).faces, cad(handles.cad_index).vertices(:,1), cad(handles.cad_index).vertices(:,2), cad(handles.cad_index).vertices(:,3), 'EdgeColor', 'b');
axis equal;
hold on;

% display anchor points
for i = 1:numel(cad(handles.cad_index).pnames)
    X = cad(handles.cad_index).(cad(handles.cad_index).pnames{i});
    if isempty(X) == 0
        plot3(X(1), X(2), X(3), 'ro', 'LineWidth', 20);
    end
end
hold off;

handles.azimuth = handles.azimuth - 5;
if handles.azimuth < 0
    handles.azimuth = handles.azimuth + 360;
end
view(handles.azimuth, handles.elevation);
guidata(hObject, handles);

set(handles.edit_azimuth, 'String', num2str(handles.azimuth));
set(handles.edit_elevation, 'String', num2str(handles.elevation));


% --- Executes on button press in pushbutton_up.
function pushbutton_up_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% display cad model
cad = handles.cad;
set(handles.figure1, 'CurrentAxes', handles.axes_cad);
cla;
trimesh(cad(handles.cad_index).faces, cad(handles.cad_index).vertices(:,1), cad(handles.cad_index).vertices(:,2), cad(handles.cad_index).vertices(:,3), 'EdgeColor', 'b');
axis equal;
hold on;

% display anchor points
for i = 1:numel(cad(handles.cad_index).pnames)
    X = cad(handles.cad_index).(cad(handles.cad_index).pnames{i});
    if isempty(X) == 0
        plot3(X(1), X(2), X(3), 'ro', 'LineWidth', 20);
    end
end
hold off;

handles.elevation = handles.elevation + 2.5;
if handles.elevation > 90
    handles.elevation = 90;
end
view(handles.azimuth, handles.elevation);
guidata(hObject, handles);

set(handles.edit_azimuth, 'String', num2str(handles.azimuth));
set(handles.edit_elevation, 'String', num2str(handles.elevation));


% --- Executes on button press in pushbutton_down.
function pushbutton_down_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% display cad model
cad = handles.cad;
set(handles.figure1, 'CurrentAxes', handles.axes_cad);
cla;
trimesh(cad(handles.cad_index).faces, cad(handles.cad_index).vertices(:,1), cad(handles.cad_index).vertices(:,2), cad(handles.cad_index).vertices(:,3), 'EdgeColor', 'b');
axis equal;
hold on;

% display anchor points
for i = 1:numel(cad(handles.cad_index).pnames)
    X = cad(handles.cad_index).(cad(handles.cad_index).pnames{i});
    if isempty(X) == 0
        plot3(X(1), X(2), X(3), 'ro', 'LineWidth', 20);
    end
end
hold off;

handles.elevation = handles.elevation - 2.5;
if handles.elevation < -90
    handles.elevation = -90;
end
view(handles.azimuth, handles.elevation);
guidata(hObject, handles);

set(handles.edit_azimuth, 'String', num2str(handles.azimuth));
set(handles.edit_elevation, 'String', num2str(handles.elevation));



function edit_azimuth_Callback(hObject, eventdata, handles)
% hObject    handle to edit_azimuth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_azimuth as text
%        str2double(get(hObject,'String')) returns contents of edit_azimuth as a double


% --- Executes during object creation, after setting all properties.
function edit_azimuth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_azimuth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_elevation_Callback(hObject, eventdata, handles)
% hObject    handle to edit_elevation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_elevation as text
%        str2double(get(hObject,'String')) returns contents of edit_elevation as a double


% --- Executes during object creation, after setting all properties.
function edit_elevation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_elevation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_ok.
function pushbutton_ok_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.pushbutton_part, 'Enable', 'On');
set(handles.radiobutton_visible, 'Enable', 'On');
set(handles.radiobutton_occld, 'Enable', 'On');
set(handles.radiobutton_occld_by, 'Enable', 'On');
set(handles.radiobutton_trunc, 'Enable', 'On');
set(handles.radiobutton_unknown, 'Enable', 'On');
set(handles.radiobutton_visible, 'Value', 1.0);
set(handles.pushbutton_view, 'Enable', 'On');

% display cad model
set(handles.figure1, 'CurrentAxes', handles.axes_cad);
cla;
cad = handles.cad;
trimesh(cad(handles.cad_index).faces, cad(handles.cad_index).vertices(:,1), cad(handles.cad_index).vertices(:,2), cad(handles.cad_index).vertices(:,3), 'EdgeColor', 'b');
axis equal;
hold on;

% find the visibility index
index_a = find(cad(handles.cad_index).azimuth == handles.azimuth);
index_e = find(cad(handles.cad_index).elevation == handles.elevation);
index = (index_a - 1) * numel(cad(handles.cad_index).elevation) + index_e;
flag = cad(handles.cad_index).visibility(index).flag;
handles.anchor_index = find(flag == 1);

for i = 1:handles.part_num
    handles.(cad(handles.cad_index).pnames{i}).location = [];
    if flag(i) == 1
        handles.(cad(handles.cad_index).pnames{i}).status = 0;
    else
        handles.(cad(handles.cad_index).pnames{i}).status = 2;
    end
end
handles.partpos = 1;
handles.partname = cad(handles.cad_index).pnames{handles.anchor_index(1)};
guidata(hObject, handles);

% display the first visible anchor points
X = cad(handles.cad_index).(handles.partname);
plot3(X(1), X(2), X(3), 'ro', 'LineWidth', 20);
view(handles.azimuth, handles.elevation);
set(handles.text_pname, 'String', handles.partname);
hold off;


% --- Executes on button press in pushbutton_nextcad.
function pushbutton_nextcad_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_nextcad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cad = handles.cad;
cad_num = numel(cad);
cad_index = mod(handles.cad_index, cad_num) + 1;

% display cad model
set(handles.figure1, 'CurrentAxes', handles.axes_cad);
cla;
trimesh(cad(cad_index).faces, cad(cad_index).vertices(:,1), cad(cad_index).vertices(:,2), cad(cad_index).vertices(:,3), 'EdgeColor', 'b');
axis equal;
hold on;

% display anchor points
for i = 1:numel(cad(cad_index).pnames)
    X = cad(cad_index).(cad(cad_index).pnames{i});
    if isempty(X) == 0
        plot3(X(1), X(2), X(3), 'ro', 'LineWidth', 20);
    end
end
hold off;
view(handles.azimuth, handles.elevation);

handles.cad_index = cad_index;
guidata(hObject, handles);


% --- Executes on button press in pushbutton_prevcad.
function pushbutton_prevcad_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_prevcad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cad = handles.cad;
cad_num = numel(cad);
cad_index = handles.cad_index - 1;
if cad_index == 0
    cad_index = cad_num;
end

% display cad model
set(handles.figure1, 'CurrentAxes', handles.axes_cad);
cla;
trimesh(cad(cad_index).faces, cad(cad_index).vertices(:,1), cad(cad_index).vertices(:,2), cad(cad_index).vertices(:,3), 'EdgeColor', 'b');
axis equal;
hold on;

% display anchor points
for i = 1:numel(cad(cad_index).pnames)
    X = cad(cad_index).(cad(cad_index).pnames{i});
    if isempty(X) == 0
        plot3(X(1), X(2), X(3), 'ro', 'LineWidth', 20);
    end
end
hold off;
view(handles.azimuth, handles.elevation);

handles.cad_index = cad_index;
guidata(hObject, handles);


function ismiss = check_annotation(handles)

cad = handles.cad;
object_index = handles.object_index;
record = handles.record;

% find the visibility index
index_a = find(cad(handles.cad_index).azimuth == handles.azimuth);
index_e = find(cad(handles.cad_index).elevation == handles.elevation);
index = (index_a - 1) * numel(cad(handles.cad_index).elevation) + index_e;
flag = cad(handles.cad_index).visibility(index).flag;
handles.anchor_index = find(flag == 1);

ismiss = zeros(numel(flag), 1);
if isfield(record.objects(object_index), 'cad_index') == 1 && isempty(record.objects(object_index).cad_index) == 0
    for i = 1:numel(flag)
        if flag(i) == 1 && record.objects(object_index).anchors.(cad(handles.cad_index).pnames{i}).status == 2
            fprintf('object %d: %s missed\n', object_index, cad(handles.cad_index).pnames{i});
            ismiss(i) = 1;
        end
    end
end

%%%%%%%%%%%%%%%%% belows are functions for computing viewpoint %%%%%%%%%%%%

% --- Executes on button press in pushbutton_view.
function pushbutton_view_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% retrieve annotation
viewpoint.azimuth_coarse = handles.azimuth;
viewpoint.elevation_coarse = handles.elevation;
cad = handles.cad(handles.cad_index);

% get anchor point annotations
part_num = numel(cad.pnames);
pnames = cad.pnames;
x2d = [];
x3d = [];
for j = 1:part_num
    if handles.(pnames{j}).status == 1  % filters the point not clicked on the image
        p = handles.(pnames{j}).location;
        x2d = [x2d; p];
        x3d = [x3d; cad.(pnames{j})];
    end
end

% compute continous viewpoint
num_anch = size(x2d,1);
if num_anch < 2
      set(handles.text_filename, 'String', 'number of anchor less than 2');
else
    % inialization
    v0 = zeros(7,1);
    % azimuth
    a = viewpoint.azimuth_coarse;
    v0(1) = a*pi/180;
    if strcmp(handles.cls, 'bottle') == 1
        margin = 0;
    else
        margin = 22.5;
    end
    aextent = [max(a-margin,0)*pi/180 min(a+margin,360)*pi/180];
    % elevation
    e = viewpoint.elevation_coarse;
    v0(2) = e*pi/180;
    margin = 22.5;
    eextent = [max(e-margin,0)*pi/180 min(e+margin,90)*pi/180];        
    % distance
    dextent = [0, 100];
    v0(3) = compute_distance(v0(1), v0(2), dextent, x2d, x3d);
    d = v0(3);
    margin = 5;
    dextent = [max(d-margin,0) min(d+margin,100)];
    % focal length
    v0(4) = 1;
    fextent = [1 1];
    % principal point
    [principal_point, lbp, ubp] = compute_principal_point(v0(1), v0(2), v0(3), x2d, x3d);
    v0(5) = principal_point(1);
    v0(6) = principal_point(2);
    % in-plane rotation
    v0(7) = 0;
    rextent = [-pi, pi];
    % lower bound
    lb = [aextent(1); eextent(1); dextent(1); fextent(1); lbp(1); lbp(2); rextent(1)];
    % upper bound
    ub = [aextent(2); eextent(2); dextent(2); fextent(2); ubp(1); ubp(2); rextent(2)];

    % optimization
    v_out = zeros(10,1);
    [v_out(1), v_out(2), v_out(3), v_out(4), v_out(5), v_out(6), v_out(7), v_out(8), v_out(9), v_out(10)]...
        = compute_viewpoint_one(v0, lb, ub, x2d, x3d);

    % assign output
    azimuth = v_out(1);
    elevation = v_out(2);
    distance = v_out(3); 
    focal = v_out(4);
    px = v_out(5);
    py = v_out(6);
    theta = v_out(7);
    error = v_out(8);
    interval_azimuth = v_out(9);
    interval_elevation = v_out(10);
    str = sprintf('a=%f, e=%f, d=%f, f=%f, theta=%f\n', azimuth, elevation,...
            distance, focal, theta);
    set(handles.text_filename, 'String', str);
    set(handles.figure1, 'CurrentAxes', handles.axes_image);
    hold on;
    plot(px, py, 'bo', 'LineWidth', 20);
end

% compute the initial distance
function distance = compute_distance(azimuth, elevation, dextent, x2d, x3d)

% compute pairwise distance
n = size(x2d, 1);
num = n*(n-1)/2;
d2 = zeros(num,1);
count = 1;
for i = 1:n
    for j = i+1:n
        d2(count) = norm(x2d(i,:)-x2d(j,:));
        count = count + 1;
    end
end

% optimization
options = optimset('Algorithm', 'interior-point');
distance = fmincon(@(d)compute_error_distance(d, azimuth, elevation, d2, x3d),...
    (dextent(1)+dextent(2))/2, [], [], [], [], dextent(1), dextent(2), [], options);

function error = compute_error_distance(distance, azimuth, elevation, d2, x3d)

a = azimuth;
e = elevation;
d = distance;
f = 1;

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
P = [M*f 0 0; 0 -M*f 0; 0 0 -1] * [R -R*C];

% project
x = P*[x3d ones(size(x3d,1), 1)]';
x(1,:) = x(1,:) ./ x(3,:);
x(2,:) = x(2,:) ./ x(3,:);
x = x(1:2,:)';

% compute pairwise distance
n = size(x, 1);
num = n*(n-1)/2;
d3 = zeros(num,1);
count = 1;
for i = 1:n
    for j = i+1:n
        d3(count) = norm(x(i,:)-x(j,:));
        count = count + 1;
    end
end

% compute error
error = norm(d2-d3);

function [center, lb, ub] = compute_principal_point(a, e, d, x2d, x3d)

f = 1;
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
P = [M*f 0 0; 0 -M*f 0; 0 0 -1] * [R -R*C];

% project
x = P*[x3d ones(size(x3d,1), 1)]';
x(1,:) = x(1,:) ./ x(3,:);
x(2,:) = x(2,:) ./ x(3,:);
x = x(1:2,:)';

% project object center
c = P*[0 0 0 1]';
c = c ./ c(3);
c = c(1:2)';

% predict object center
cx2 = c(1);
cy2 = c(2);
center = [0 0];
for i = 1:size(x2d,1)
    cx1 = x(i,1);
    cy1 = x(i,2);
    dc = sqrt((cx1-cx2)*(cx1-cx2) + (cy1-cy2)*(cy1-cy2));
    ac = atan2(cy2-cy1, cx2-cx1);
    center(1) = center(1) + x2d(i,1) + dc*cos(ac);
    center(2) = center(2) + x2d(i,2) + dc*sin(ac);
end
center = center ./ size(x2d,1);

% lower bound and upper bound
width = 0;
height = 0;
for i = 1:size(x2d,1)
    w = abs(x2d(i,1)-center(1));
    if width < w
        width = w;
    end
    h = abs(x2d(i,2)-center(2));
    if height < h
        height = h;
    end
end
rescale = 50;
lb = [center(1)-width/rescale center(2)-height/rescale];
ub = [center(1)+width/rescale center(2)+height/rescale];


% compute viewpoint angle from 2D-3D correspondences
function [azimuth, elevation, distance, focal, px, py, theta, error, interval_azimuth, interval_elevation]...
    = compute_viewpoint_one(v0, lb, ub, x2d, x3d)

options = optimset('Algorithm', 'interior-point');
[vp, fval] = fmincon(@(v)compute_error(v, x2d, x3d),...
    v0, [], [], [], [], lb, ub, [], options);

viewpoint = vp;
error = fval;

azimuth = viewpoint(1)*180/pi;
if azimuth < 0
    azimuth = azimuth + 360;
end
if azimuth >= 360
    azimuth = azimuth - 360;
end
elevation = viewpoint(2)*180/pi;
distance = viewpoint(3);
focal = viewpoint(4);
px = viewpoint(5);
py = viewpoint(6);
theta = viewpoint(7)*180/pi;

% estimate confidence inteval
v = viewpoint;
v(7) = 0;
x = project(v, x3d);
% azimuth
v = viewpoint;
v(1) = v(1) + pi/180;
xprim = project(v, x3d);
error_azimuth = sum(diag((x-xprim) * (x-xprim)'));
interval_azimuth = error / error_azimuth;
% elevation
v = viewpoint;
v(2) = v(2) + pi/180;
xprim = project(v, x3d);
error_elevation = sum(diag((x-xprim) * (x-xprim)'));
interval_elevation = error / error_elevation;

function error = compute_error(v, x2d, x3d)

a = v(1);
e = v(2);
d = v(3);
f = v(4);
principal_point = [v(5) v(6)];
theta = v(7);

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
% compute error
error = normal_dist(x, x2d, principal_point);

% re-projection error
function error = normal_dist(x, x2d, p_pnt)

error = 0;
for i = 1:size(x2d, 1)
     point = x2d(i,:) - p_pnt;
     point(2) = -1 * point(2);
     error = error + (point-x(i,:))*(point-x(i,:))'/size(x2d, 1);
end

function x = project(v, x3d)

a = v(1);
e = v(2);
d = v(3);
f = v(4);
theta = v(7);

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
