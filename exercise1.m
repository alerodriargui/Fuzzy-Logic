% exerciseSystem_matlab.m
% Sistema difuso Mamdani con 2 salidas:
% intensidad (0–100) y tiempo de entrenamiento (0–60 min),
% equivalente al sistema Python.

% ---------------------------
% 1) Crear el FIS
% ---------------------------
fis = mamfis('Name','ExerciseSystem');

% ---------------------------
% 2) Entradas
% ---------------------------
fis = addInput(fis,[0 10],'Name','fatigue');    % 0-10
fis = addInput(fis,[40 90],'Name','hr');        % 40-90
fis = addInput(fis,[0 10],'Name','sleep');      % 0-10

% ---------------------------
% 3) Salidas
% ---------------------------
fis = addOutput(fis,[0 100],'Name','intensity');
fis = addOutput(fis,[0 60],'Name','time');

% ---------------------------
% 4) Funciones de pertenencia
% ---------------------------

% --- Fatigue ---
fis = addMF(fis,'fatigue','trimf',[0 0 2],'Name','very_low');
fis = addMF(fis,'fatigue','trimf',[0 2 4],'Name','low');
fis = addMF(fis,'fatigue','trimf',[2 5 8],'Name','medium');
fis = addMF(fis,'fatigue','trimf',[6 8 10],'Name','high');
fis = addMF(fis,'fatigue','trimf',[8 10 10],'Name','very_high');

% --- HR ---
fis = addMF(fis,'hr','trimf',[40 40 60],'Name','low');
fis = addMF(fis,'hr','trimf',[50 65 80],'Name','normal');
fis = addMF(fis,'hr','trimf',[70 90 90],'Name','high');

% --- Sleep quality ---
fis = addMF(fis,'sleep','trimf',[0 0 4],'Name','poor');
fis = addMF(fis,'sleep','trimf',[2 5 8],'Name','average');
fis = addMF(fis,'sleep','trimf',[6 10 10],'Name','good');

% --- Intensity (0-100) ---
fis = addMF(fis,'intensity','trimf',[0 0 40],'Name','low');
fis = addMF(fis,'intensity','trimf',[20 40 60],'Name','low_medium');
fis = addMF(fis,'intensity','trimf',[40 60 80],'Name','medium');
fis = addMF(fis,'intensity','trimf',[60 80 100],'Name','medium_high');
fis = addMF(fis,'intensity','trimf',[80 100 100],'Name','high');

% --- Time (0–60 min) ---
fis = addMF(fis,'time','trimf',[0 0 20],'Name','short');
fis = addMF(fis,'time','trimf',[10 30 50],'Name','medium');
fis = addMF(fis,'time','trimf',[40 60 60],'Name','long');

% ---------------------------
% 5) Reglas
% ---------------------------
% Formato: [fatigue hr sleep intensity time weight operator]

ruleList = [
    2 1 3 5 3 1 1;  % Cansancio bajo, HR baja, Sueño bueno → intensidad alta, tiempo largo
    2 1 2 4 2 1 1;  % Cansancio bajo, HR baja, Sueño regular → intensidad med alta, tiempo medio
    2 2 3 4 2 1 1;  % Cansancio bajo, HR normal, Sueño bueno → intensidad med alta, tiempo medio
    3 2 2 3 2 1 1;  % Cansancio medio, HR normal, Sueño regular → intensidad media, tiempo medio
    3 3 2 2 2 1 1;  % Cansancio medio, HR alta, Sueño regular → intensidad med baja, tiempo medio
    4 3 1 1 1 1 1;  % Cansancio alto, HR alta, Sueño malo → intensidad baja, tiempo corto
    3 2 3 4 2 1 1;  % Cansancio medio, HR normal, Sueño bueno → intensidad med alta, tiempo medio
    2 3 3 3 2 1 1;  % Cansancio bajo, HR alta, Sueño bueno → intensidad media, tiempo medio
    4 1 3 3 2 1 1;  % Cansancio alto, HR baja, Sueño bueno → intensidad media, tiempo medio
    4 2 2 2 2 1 1;  % Cansancio alto, HR normal, Sueño regular → intensidad med baja, tiempo medio
    2 2 1 2 2 1 1;  % Cansancio bajo, HR normal, Sueño malo → intensidad med baja, tiempo medio
    3 1 3 4 2 1 1   % Cansancio medio, HR baja, Sueño bueno → intensidad med alta, tiempo medio
];

fis = addRule(fis,ruleList);

% ---------------------------
% 6) Guardar y visualizar
% ---------------------------
disp(fis)
save('exerciseSystem_fis.mat','fis');
writeFIS(fis,'exerciseSystem.fis');

% ---------------------------
% 7) Pruebas
% ---------------------------
test_inputs = [3 65 6; 1 50 8; 8 85 3; 0.5 45 9]; % [fatigue HR sleep]
outputs = evalfis(fis,test_inputs);               % columnas: [intensity time]

disp('Resultados de pruebas [fatigue HR sleep → intensity time]:');
disp([test_inputs outputs]);

% ---------------------------
% 8) Visualizaciones
% ---------------------------
figure; plotmf(fis,'input',1); title('Fatigue MFs');
figure; plotmf(fis,'input',2); title('HR MFs');
figure; plotmf(fis,'input',3); title('Sleep MFs');
figure; plotmf(fis,'output',1); title('Intensity MFs');
figure; plotmf(fis,'output',2); title('Time MFs');

% Superficie ejemplo (fatigue vs HR -> time)
figure; gensurf(fis,[1 2],2);
title('Surface: Fatigue vs HR → Time');
% Visualize the output surface (intensity)
figure; gensurf(fis,[1 2],1);
title('Surface: fatigue vs HR -> Intensity');
%fuzzyLogicDesigner(fis)