% exerciseIntensity_matlab.m
% Crea un Mamdani FIS que replica el sistema Python de intensidad de ejercicio.

% ---------------------------
% 1) Crear el FIS
% ---------------------------
fis = mamfis('Name','ExerciseIntensity');

% ---------------------------
% 2) Entradas (inputs)
% ---------------------------
% Fatigue (0..10)
fis = addInput(fis,[0 10],'Name','fatigue');
% HR (40..90)
fis = addInput(fis,[40 90],'Name','hr');
% Sleep quality (0..10)
fis = addInput(fis,[0 10],'Name','sleep');

% ---------------------------
% 3) Salida (output)
% ---------------------------
% Intensity (0..100)
fis = addOutput(fis,[0 100],'Name','intensity');

% ---------------------------
% 4) Membership functions (trimf) - las mismas que en Python
% ---------------------------
% Fatigue: very_low, low, medium, high, very_high
fis = addMF(fis,'fatigue','trimf',[0 0 2],'Name','very_low');
fis = addMF(fis,'fatigue','trimf',[0 2 4],'Name','low');
fis = addMF(fis,'fatigue','trimf',[2 5 8],'Name','medium');
fis = addMF(fis,'fatigue','trimf',[6 8 10],'Name','high');
fis = addMF(fis,'fatigue','trimf',[8 10 10],'Name','very_high');

% HR: low, normal, high (domain 40-90)
fis = addMF(fis,'hr','trimf',[40 40 60],'Name','low');
fis = addMF(fis,'hr','trimf',[50 65 80],'Name','normal');
fis = addMF(fis,'hr','trimf',[70 90 90],'Name','high');

% Sleep quality: poor, average, good (0-10)
fis = addMF(fis,'sleep','trimf',[0 0 4],'Name','poor');
fis = addMF(fis,'sleep','trimf',[2 5 8],'Name','average');
fis = addMF(fis,'sleep','trimf',[6 10 10],'Name','good');

% Intensity: low, low-medium, medium, medium-high, high (0-100)
fis = addMF(fis,'intensity','trimf',[0 0 40],'Name','low');
fis = addMF(fis,'intensity','trimf',[20 40 60],'Name','low_medium');
fis = addMF(fis,'intensity','trimf',[40 60 80],'Name','medium');
fis = addMF(fis,'intensity','trimf',[60 80 100],'Name','medium_high');
fis = addMF(fis,'intensity','trimf',[80 100 100],'Name','high');

% ---------------------------
% 5) Reglas
% ---------------------------
% NOTA: índices de MFs siguen el orden de addMF por variable.
% Fatigue: 1:very_low, 2:low, 3:medium, 4:high, 5:very_high
% HR: 1:low, 2:normal, 3:high
% Sleep: 1:poor, 2:average, 3:good
% Intensity (consecuente): 1:low,2:low_medium,3:medium,4:medium_high,5:high
% Formato de cada fila: [fatigue_idx hr_idx sleep_idx intensity_idx weight operator]
% operator: 1 = AND, 2 = OR

ruleList = [
    2 1 3 5 1 1;  % Cansancio bajo, HR baja, Sueño bueno → intensidad alta
    2 1 2 4 1 1;  % Cansancio bajo, HR baja, Sueño regular → intensidad media alta
    2 2 3 4 1 1;  % Cansancio bajo, HR normal, Sueño bueno → intensidad media alta
    3 2 2 3 1 1;  % Cansancio medio, HR normal, Sueño regular → intensidad media
    3 3 2 2 1 1;  % Cansancio medio, HR alta, Sueño regular → intensidad media baja
    4 3 1 1 1 1;  % Cansancio alto, HR alta, Sueño malo → intensidad baja
    3 2 3 4 1 1;  % Cansancio medio, HR normal, Sueño bueno → intensidad media alta
    2 3 3 3 1 1;  % Cansancio bajo, HR alta, Sueño bueno → intensidad media
    4 1 3 3 1 1;  % Cansancio alto, HR baja, Sueño bueno → intensidad media
    4 2 2 2 1 1;  % Cansancio alto, HR normal, Sueño regular → intensidad media baja
    2 2 1 2 1 1;  % Cansancio bajo, HR normal, Sueño malo → intensidad media baja
    3 1 3 4 1 1   % Cansancio medio, HR baja, Sueño bueno → intensidad media alta
];


% Añadir reglas al FIS
fis = addRule(fis, ruleList);

% ---------------------------
% 6) Guardar y visualizar
% ---------------------------
% Mostrar resumen
disp(fis)

% Guardar el objeto mamfis (MAT-file)
save('exerciseIntensity_fis.mat','fis');

% También escribir .fis (formato legacy) si lo deseas:
writeFIS(fis,'exerciseIntensity.fis');

% ---------------------------
% 7) Evaluación / pruebas
% ---------------------------
% Probar entradas (fatigue, hr, sleep)
% (puedes usar una matriz N x 3 de entradas)
test_inputs = [3 65 6; 1 50 8; 8 85 3; 0.5 45 9]; % ejemplo de casos
outputs = evalfis(fis,test_inputs); % devuelve vector de intensities
disp('Resultados de pruebas (Intensidad %):');
disp([test_inputs outputs]);

% ---------------------------
% 8) Visualizaciones útiles
% ---------------------------
% Plot funciones de pertenencia de cada input y output
figure; plotmf(fis,'input',1); title('Fatigue MFs');
figure; plotmf(fis,'input',2); title('HR MFs');
figure; plotmf(fis,'input',3); title('Sleep MFs');
figure; plotmf(fis,'output',1); title('Intensity MFs');

% Superficie (por ejemplo fatigue vs hr -> intensidad) con sleep fijado
% gensurf solo para sistemas simples; aquí fijamos sleep en 6 (por ejemplo)
figure; gensurf(fis,[1 2]); title('Surface fatigue vs hr (sleep var)');
% Para ver la superficie en el toolbox interactivo también puedes usar FIS Editor.
