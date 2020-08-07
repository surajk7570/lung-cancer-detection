function varargout = LungCancer(varargin)
% LUNGCANCER MATLAB code for LungCancer.fig
%      LUNGCANCER, by itself, creates a new LUNGCANCER or raises the existing
%      singleton*.
%
%      H = LUNGCANCER returns the handle to a new LUNGCANCER or the handle to
%      the existing singleton*.
%
%      LUNGCANCER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LUNGCANCER.M with the given input arguments.
%
%      LUNGCANCER('Property','Value',...) creates a new LUNGCANCER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LungCancer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LungCancer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LungCancer

% Last Modified by GUIDE v2.5 28-May-2018 19:59:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LungCancer_OpeningFcn, ...
                   'gui_OutputFcn',  @LungCancer_OutputFcn, ...
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


% --- Executes just before LungCancer is made visible.
function LungCancer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LungCancer (see VARARGIN)

% Choose default command line output for LungCancer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LungCancer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LungCancer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in processBtn.
function processBtn_Callback(hObject, eventdata, handles)
% hObject    handle to processBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img;

level = graythresh(img);
img_bin = rgb2gray(img);
img_bin = imbinarize(img_bin, level);
axes(handles.axes4);
imshow(img_bin);

se = strel('diamond',3);
img_er = imerode(img_bin,se);
axes(handles.axes5);
imshow(img_er);

img_er = bwmorph(img_er,'erode',1.5);
axes(handles.axes6);
imshow(img_er);

BWr = regionprops(img_er, 'BoundingBox', 'Area', 'Image');
axes(handles.axes7);
imshow(img_er);
hold on;
pixelH = [];
pixelW = [];
for i=1:size(BWr,1)
    rectangle('Position', BWr(i).BoundingBox,'edgecolor','red');
%    pixelT = pixelT + BWr(i).Area;
    pixelH(1,i) = BWr(i).Area;
end

cc = bwconncomp(img_er);
num = cc.NumObjects;

arr = sort(pixelH, 'descend');
arrMaxP = arr(1,num);
[c_max, idx_max] = max(arrMaxP);
T = 1500;
removeMask = [BWr.Area]>T; 
BWremove2 = img_er;
BWremove2(cat(1, cc.PixelIdxList{removeMask})) = false;
BWremove2 = bwmorph(BWremove2, 'open', Inf);
axes(handles.axes8);
imshow(BWremove2);
cc_rem = bwconncomp(BWremove2);
num_canc = cc_rem.NumObjects;

cancer = regionprops(BWremove2,'BoundingBox','Area'); 
% imshow(img);title('Detected Cancer')

axes(handles.axes3);
imshow(img);
hold on ;
for cancers=1:size(cancer,1)
    size(cancer);
    rectangle('Position', cancer(cancers).BoundingBox,'edgecolor','red');
end

if (num_canc > 0)
%     fprintf('This lung have cancer (abnormal)');
    set(handles.diagnoseTxt, 'String', 'This lung have cancer (abnormal)');
else
    set(handles.diagnoseTxt, 'String', 'This lung is normal');
end

% --- Executes on button press in browseBtn.
function browseBtn_Callback(hObject, eventdata, handles)
% hObject    handle to browseBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img;
[nama_file, nama_path] = uigetfile('*.png;*.jpg;*.bmp;*.gif;*.tif','Select Image');
if ~isequal (nama_file,0)
    img = imread(fullfile(nama_path,nama_file));
    guidata(hObject,handles);
    axes(handles.axes1);
    imshow(img);

    cla(handles.axes3);
    cla(handles.axes4);
    cla(handles.axes5);
    cla(handles.axes6);
    cla(handles.axes7);
    cla(handles.axes8);
else
    return;
end
