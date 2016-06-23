function varargout = program(varargin)
% PROGRAM M-file for program.fig
%      PROGRAM, by itself, creates a new PROGRAM or raises the existing
%      singleton*.
%
%      H = PROGRAM returns the handle to a new PROGRAM or the handle to
%      the existing singleton*.
%
%      PROGRAM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROGRAM.M with the given input arguments.
%
%      PROGRAM('Property','Value',...) creates a new PROGRAM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before program_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to program_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help program

% Last Modified by GUIDE v2.5 24-Jun-2016 00:03:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @program_OpeningFcn, ...
                   'gui_OutputFcn',  @program_OutputFcn, ...
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


% --- Executes just before program is made visible.
function program_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to program (see VARARGIN)

% Choose default command line output for program
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes program wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = program_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function OPEN_Callback(hObject, eventdata, handles)
% hObject    handle to OPEN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file_dir = uigetdir('','Select the folder');
if length(file_dir) > 2
    set(handles.SHOWPATH,'String',file_dir); %파일경로 표시
    guidata(hObject,handles); % updates
    file_list=dir(fullfile(file_dir,'*.txt'));
    len =length(file_list);
    u_buffer = zeros(144,288,ceil(len/2)); v_buffer = zeros(144,288,ceil(len/2)); %읽어온 text file 저장.
    out_v_buffer = zeros(144,288,ceil(len/2));  out_u_buffer = zeros(144,288,ceil(len/2)); % 출력 시 저장 할 buffer.
    Result = zeros(144,288,ceil(len/2));
    h = waitbar(0/len,'     calculating      ');
    for file = 1 : len
        waitbar(file/len, h, sprintf('DB(%i / %i)',file,len));
        file_path = strcat(file_dir,'\',file_list(file).name);
        file_name = file_list(file).name; file_name = file_name(1:end-9); % 제목 추출 & 숫자 제거
        if file > ceil(file/2)
                l = file - ceil(file/2);
        else 
            l = file;
        end
        if strcmp(file_name,'MERRA_output_u')
            u_buffer(:,:,l) = load(file_path); % 읽어 온 파일을 buffer에 저장.
            out_u_buffer(:,:,l) = circshift(u_buffer(:,:,l),[0,-2])-u_buffer(:,:,l); %미분
            out_u_buffer(:,:,l) = [zeros(144,2) out_u_buffer(:,1:end-2,l)];% 미분
        else
            v_buffer(:,:,l)=load(file_path); % 읽어 온 파일을 buffer에 저장.
            out_v_buffer(:,:,l)= circshift(v_buffer(:,:,l),[0,-2])-v_buffer(:,:,l); % 미분
            out_v_buffer(:,:,l)=[zeros(144,2) out_v_buffer(:,1:end-2,l)]; % 미분
        end
    end
    dx = 2*(1.25*pi/180)*6370000; dy = 2*(1.25*pi/180)*6370000;
    close(h);
    figure(1);
    for i = 1:ceil(len/2)
        Result(:,:,i) = out_v_buffer(:,:,i)./dx - out_u_buffer(:,:,i)./dy;
        hold on;
        surf(Result(:,:,i));
    end
    colormap('hot');
    colorbar;
    %% save the file
    file = ceil(len/2);
    row = size(Result,1); 
    fid = fopen('RESULT','w');
    for i = 1 : file
        for ii = 1 : row
            fprintf(fid,'%f ',Result(ii,:,file));
            fprintf('\n');
        end
        fprintf('\n\n');
    end
    avg = zeros(1,30);
    diff = zeros(1,30);
    fclose(fid);
    for i = 1:30
        AVG = Result(:,:,i); AVG_2 = AVG.*AVG;
        avg(1,i)  = mean(AVG(:));
        diff(1,i) = avg(1,i)*avg(i)-mean(AVG_2(:));
    end
    fid = fopen('AVG_DIFF','w');
    fprintf(fid,'%d ',avg(:));
    fprintf(fid,'\n');
    fprintf(fid,'%d ',diff(:));
    fclose(fid);
end
function SHOWPATH_Callback(hObject, eventdata, handles)
% hObject    handle to SHOWPATH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes during object creation, after setting all properties.
function SHOWPATH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SHOWPATH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
