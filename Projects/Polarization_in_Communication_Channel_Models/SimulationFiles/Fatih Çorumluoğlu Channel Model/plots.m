function varargout = plots(varargin)
% PLOTS M-file for plots.fig
%      PLOTS, by itself, creates a new PLOTS or raises the existing
%      singleton*.
%
%      H = PLOTS returns the handle to a new PLOTS or the handle to
%      the existing singleton*.
%
%      PLOTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTS.M with the given input arguments.
%
%      PLOTS('Property','Value',...) creates a new PLOTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plots_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plots_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help plots

% Last Modified by GUIDE v2.5 29-Apr-2007 20:19:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plots_OpeningFcn, ...
                   'gui_OutputFcn',  @plots_OutputFcn, ...
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


% --- Executes just before plots is made visible.
function plots_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plots (see VARARGIN)

% Choose default command line output for plots
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes plots wait for user response (see UIRESUME)
% uiwait(handles.figure1);

data=varargin{1};

%Channel fast fading
axes(handles.axes1)
plot(data{1},data{2})
xlabel('time in seconds')
ylabel('reception in dBs')
title('Channel Fast Fading')
grid on
%/Channel fast fading

%Channel fast fading (Polarized)
axes(handles.axes9)
plot(data{1},data{18})
xlabel('time in seconds')
ylabel('reception in dBs')
title('Channel Fast Fading (Polarized)')
grid on
%/Channel fast fading (Polarized)

%Spatial autocorrelation graph
axes(handles.axes3)
x1=length(data{6});
x2=[-((x1-1)/2):1:((x1-1)/2)]*data{17};
plot(x2,data{6},'b*-.')
xlabel('distance in wavelengths')
ylabel('amplitude')
title('Spatial Autocorrelation')
xlim([-0.02 4])
grid on
%/Spatial autocorrelation graph

%Spatial autocorrelation graph (Polarized)
axes(handles.axes10)
x1=length(data{19});
x2=[-((x1-1)/2):1:((x1-1)/2)]*data{17};
plot(x2,data{19},'b*-.')
xlabel('distance in wavelengths')
ylabel('amplitude')
title('Spatial Autocorrelation (Polarized)')
xlim([-0.02 4])
grid on
%/Spatial autocorrelation graph (Polarized)

%Capacity graph
axes(handles.axes7)
plot(data{1},real(data{16}),'b--.')
brob = robustfit(data{1},real(data{16}));
hold on
plot(data{1},brob(1)+brob(2)*data{1},'r-','LineWidth',2)
xlabel('time in seconds')
ylabel('Capacity in bps/Hz')
title('Channel Capacity')
grid on
hold off
%/Capacity graph

%Capacity graph (Polorized)
axes(handles.axes11)
plot(data{1},real(data{20}),'b--.')
brob = robustfit(data{1},real(data{20}));
hold on
plot(data{1},brob(1)+brob(2)*data{1},'r-','LineWidth',2)
xlabel('time in seconds')
ylabel('Capacity in bps/Hz')
title('Channel Capacity (Polarized)')
grid on
hold off
%/Capacity graph (Polorized)

%Power delay graph (for both)
axes(handles.axes2)
stem(data{3},data{4})
xlabel('delay in seconds')
ylabel('amplitude')
title('Power Delay Profile')
grid on
%/Power delay graph (for both)

