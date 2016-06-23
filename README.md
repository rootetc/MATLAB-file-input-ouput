# MATLAB-file-input-ouput

##파일 입출력
- load('path',[size]); [size]가 설정 되어 있지 않으면 1줄에 모든 값을을 저장/ size가 설정되어있을 시 size크기의 행렬로 값을 저장
저장된 파일이 일정한 규칙으로 저장되었을 시 파일을 읽어들일 때 편한 함수이다.

- fopen('파일 명', 'mode') mode가 'r'이면 읽기 mode, 'w'이면 쓰기 mode.

- fprintf(파일, '%type ', 행렬의 첫 줄)
ex) a=[1 2 3; 1 2 3]인 경우 txt파일로 1 2 3 \n 1 2 3이 저장된다.

- fclose(파일) 파일을 닫는다.

##편한 함수들
- circshift(행렬,[row col]) row방향으로 row만큼 이동, col방향으로 col만큼 이동

##파일 선택 
- file_dir = uigetdir('','Select the folder');
- file_list = dir(fullfile(file_dir,'*.txt')); 폴더안의 txt확장자를 가진 파일들을 모두 읽는다
- file_path = strcat(file_dir,'\',file_list(index).name); 해당 파일의 절대경로를 읽는다.

